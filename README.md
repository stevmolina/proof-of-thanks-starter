# Proof of Thanks: Stellar starter 💜

Leave a public thank-you note on **Stellar Testnet**, signed with your wallet. No real money.

Built for **The Commit Club** at BAF × Stellar: Proof of Gratitude. Use it as-is or as the base for your own idea.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/stevmolina/proof-of-thanks-starter)

## What's inside

- `contracts/gratitude`: a Soroban smart contract with `thank`, `count` and `get`.
- `docs/`: a static page that connects [Freighter](https://www.freighter.app) and calls the contract. Published with GitHub Pages from `/docs`.
- `scripts/`: `setup.sh` (tools + funded Testnet account), `deploy.sh` (test, build, deploy), `smoke-test.cjs` (end-to-end check).

## Quick start

```bash
bash scripts/setup.sh      # once
bash scripts/deploy.sh     # deploy your contract to Testnet
npx --yes serve docs        # open the page locally
```

Then push to `main`. To publish the page: **Settings → Pages → Deploy from a branch → `main` / `/docs`** (or run `gh api -X POST repos/OWNER/REPO/pages -f "source[branch]=main" -f "source[path]=/docs"`).

## With an AI agent

Install the Commit Club kit and run `/stellarize`. See [stellar-commit-club](https://github.com/stevmolina/stellar-commit-club).

## Wallet setup

1. Install [Freighter](https://www.freighter.app).
2. Settings → Network → **Testnet**.
3. Fund your account for free with [Friendbot](https://lab.stellar.org/account/fund).
