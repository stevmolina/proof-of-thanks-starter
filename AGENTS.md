# Agent instructions: Proof of Thanks starter

A Stellar **Testnet** dApp: one Soroban contract (`contracts/gratitude`) and a static web page (`docs/`) that talks to it through the Freighter wallet. GitHub Pages serves `docs/` from the `main` branch.

## Hard rules

- **Testnet only.** Never use mainnet, real funds, or a user's real wallet secret. RPC is `https://soroban-testnet.stellar.org`.
- **Never commit secrets.** Keys live in the Stellar CLI keystore (`stellar keys`), never in the repo. Don't print secret keys.
- Keep `docs/` static: plain HTML/JS plus the CDN builds already in `index.html`. No bundler.
- Small, reviewable commits with clear messages.

## Commands

| Task | Command |
|---|---|
| One-time setup (tools + funded `me` identity) | `bash scripts/setup.sh` |
| Contract tests | `cargo test` |
| Test, build, deploy, update `docs/config.js` | `bash scripts/deploy.sh` |
| End-to-end check of the web client on Testnet | `node scripts/smoke-test.cjs me` |
| Preview the page locally | `npx --yes serve docs` |

Always build with `stellar contract build` (the deploy script does), never with plain `cargo build`.

## Changing the idea

1. Edit `contracts/gratitude/src/lib.rs` (rename is fine; keep the crate under `contracts/`) and update `src/test.rs`.
2. Run `cargo test` until green.
3. If you rename functions or arguments, update `docs/gratitude-client.js` and `docs/index.html` to match, and `scripts/smoke-test.cjs` if `thank`/`count`/`get` changed.
4. `bash scripts/deploy.sh <crate-name>`, then the smoke test, then commit and push. GitHub Pages updates in about a minute.

## Where to learn more

Use the official Stellar skill (`stellar-dev`) and the Stellar Docs MCP (`https://developers.stellar.org/mcp`) for anything beyond this template.
