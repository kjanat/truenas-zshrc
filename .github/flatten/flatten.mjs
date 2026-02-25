// @ts-check
/** @typedef {import('@actions/github-script').AsyncFunctionArguments} AsyncFunctionArguments */

import { readFileSync, writeFileSync } from 'node:fs';

const SOURCE_RE = /^source "\$\{0:A:h\}\/lib\/(.+\.zsh)"$/;

/**
 * Build the auto-generated header for the flat file.
 * @param {string} repoUrl
 * @returns {readonly string[]}
 */
function headerLines(repoUrl) {
	const rawUrl = `${repoUrl.replace('https://github.com/', 'https://raw.githubusercontent.com/')}/flat/truenas.zsh`;
	return [
		'# ============================================================================',
		'# This file is AUTO-GENERATED — do not edit.',
		`# Source: ${repoUrl}`,
		`# Install: fetch -qo ~/.zshrc.truenas ${rawUrl}`,
		'# ============================================================================',
	];
}

/**
 * Run a shell command via `exec`, return trimmed stdout.
 * @param {AsyncFunctionArguments['exec']} exec
 * @param {string} cmd
 * @param {string[]} args
 * @returns {Promise<string>}
 */
async function run(exec, cmd, args) {
	let stdout = '';
	await exec.exec(cmd, args, {
		silent: true,
		listeners: {
			stdout: (/** @type {Buffer} */ data) => {
				stdout += data.toString('utf8');
			},
		},
	});
	return stdout.trim();
}

/**
 * Read `truenas.zsh` and inline all `source` directives from `lib/`.
 * @param {AsyncFunctionArguments['core']} core
 * @param {string} repoUrl
 * @returns {string} Flattened file content
 */
function flatten(core, repoUrl) {
	const entry = readFileSync('truenas.zsh', 'utf8');
	const lines = entry.split('\n');
	/** @type {string[]} */
	const out = [...headerLines(repoUrl)];

	for (const line of lines) {
		const m = SOURCE_RE.exec(line);
		if (!m) {
			out.push(line);
			continue;
		}
		const name = /** @type {string} */ (m[1]);
		try {
			const content = readFileSync(`lib/${name}`, 'utf8');
			out.push('');
			out.push(`# ======================================== ${name} ========================================`);
			out.push(content.replace(/\n$/, ''));
		} catch {
			core.warning(`lib/${name} not found, keeping source line`);
			out.push(line);
		}
	}

	core.info(`Flattened: ${out.length} lines`);
	return out.join('\n') + '\n';
}

/**
 * Build the flat-branch README with source SHA link.
 * @param {string} repoUrl
 * @param {string} owner
 * @param {string} repo
 * @param {string} sha
 * @returns {string}
 */
function buildReadme(repoUrl, owner, repo, sha) {
	return [
		'# truenas-zshrc (flat)',
		'',
		`Single-file build of [truenas-zshrc](${repoUrl}) — auto-generated from \`master\` by CI.`,
		'',
		'## Usage',
		'',
		'```sh',
		`fetch -qo ~/.zshrc.truenas https://raw.githubusercontent.com/${owner}/${repo}/flat/truenas.zsh`,
		"echo 'source ~/.zshrc.truenas' >> ~/.zshrc",
		'```',
		'',
		'## About',
		'',
		'This branch contains a single `truenas.zsh` with all `lib/*.zsh` modules inlined.',
		`Do not edit this branch directly — changes are overwritten on every push to [\`master\`](${repoUrl}/tree/master).`,
		'',
		`Built from [\`${sha}\`](${repoUrl}/commit/${sha}).`,
		'',
	].join('\n');
}

/**
 * Deploy flat file and README to the orphan `flat` branch.
 * @param {AsyncFunctionArguments['exec']} exec
 * @param {AsyncFunctionArguments['core']} core
 * @param {string} sha  - Short source SHA
 * @param {string} msg  - Source commit message
 */
async function deployFlatBranch(exec, core, sha, msg) {
	await run(exec, 'git', ['config', 'user.name', 'github-actions[bot]']);
	await run(exec, 'git', ['config', 'user.email', '41898282+github-actions[bot]@users.noreply.github.com']);

	try {
		await run(exec, 'git', ['fetch', 'origin', 'flat:flat']);
	} catch {
		// branch may not exist yet
	}

	try {
		await run(exec, 'git', ['checkout', 'flat']);
	} catch {
		await run(exec, 'git', ['checkout', '--orphan', 'flat']);
		try {
			await run(exec, 'git', ['rm', '-rf', '.']);
		} catch {
			// empty repo
		}
	}

	await run(exec, 'mv', ['truenas.zsh.flat', 'truenas.zsh']);
	await run(exec, 'mv', ['README.md.flat', 'README.md']);
	await run(exec, 'git', ['add', 'truenas.zsh', 'README.md']);

	// Check if there are changes to commit
	try {
		await run(exec, 'git', ['diff', '--cached', '--quiet']);
		core.info('No changes to flat branch');
	} catch {
		await run(exec, 'git', ['commit', '-m', `Flatten ${sha}: ${msg}`]);
		await run(exec, 'git', ['push', 'origin', 'flat']);
		core.info(`Deployed to flat branch: ${sha}`);
	}
}

/**
 * Sync flattened file to a GitHub Gist.
 * @param {AsyncFunctionArguments['github']} github
 * @param {AsyncFunctionArguments['core']} core
 * @param {string} gistId
 * @param {string} sha
 */
async function syncGist(github, core, gistId, sha) {
	const content = readFileSync('truenas.zsh', 'utf8');
	await github.rest.gists.update({
		gist_id: gistId,
		description: `TrueNAS CORE ZSH config (flat build from ${sha})`,
		files: { 'truenas.zsh': { content } },
	});
	core.info(`Gist ${gistId} updated from ${sha}`);
}

/**
 * Main entry point — flatten, deploy to flat branch, sync gist.
 * @param {Pick<AsyncFunctionArguments, 'github' | 'context' | 'core' | 'exec'>} args
 */
export default async function main({ github, context, core, exec }) {
	const { owner, repo } = context.repo;
	const repoUrl = `https://github.com/${owner}/${repo}`;

	// Capture source info before switching branches
	const sha = await run(exec, 'git', ['rev-parse', '--short', 'HEAD']);
	const msg = await run(exec, 'git', ['log', '-1', '--format=%s']);
	core.info(`Source: ${sha} — ${msg}`);

	// Flatten
	const flat = flatten(core, repoUrl);
	writeFileSync('truenas.zsh.flat', flat);

	// Build README
	const readme = buildReadme(repoUrl, owner, repo, sha);
	writeFileSync('README.md.flat', readme);

	// Deploy to flat branch
	await deployFlatBranch(exec, core, sha, msg);

	// Sync to gist
	const gistPat = process.env.GIST_PAT;
	const gistId = process.env.GIST_ID;
	if (!gistPat) throw new Error('GIST_PAT is required');
	if (!gistId) throw new Error('GIST_ID is required');
	await syncGist(github, core, gistId, sha);
}
