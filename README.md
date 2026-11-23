# Proof of Thanks: starter de Stellar 💜

Dejá un agradecimiento público en **Stellar Testnet**, firmado con tu wallet. Sin plata real.

Hecho para **The Commit Club** de BAF × Stellar: Proof of Gratitude. Usalo tal cual o como base para tu propia idea. Cuando termines, dejá tu firma en [Proof of Gratitude](https://github.com/mariaelisaaraya/Proof-of-Gratitude).

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/stevmolina/proof-of-thanks-starter)

Demo: [stevmolina.github.io/proof-of-thanks-starter](https://stevmolina.github.io/proof-of-thanks-starter/)

## Qué trae

- `contracts/gratitude`: un contrato Soroban con `thank`, `count` y `get`.
- `docs/`: una página estática que conecta [Freighter](https://www.freighter.app) y llama al contrato. Se publica con GitHub Pages desde `/docs`.
- `scripts/`: `setup.sh` (herramientas y cuenta de Testnet fondeada), `deploy.sh` (tests, build y deploy), `smoke-test.cjs` (prueba de punta a punta).

## Inicio rápido

```bash
bash scripts/setup.sh      # una sola vez
bash scripts/deploy.sh     # despliega tu contrato en Testnet
npx --yes serve docs       # abrí la página localmente
```

Después hacé push a `main`. Para publicar la página: **Settings → Pages → Deploy from a branch → `main` / `/docs`**.

## Con un agente de IA

Instalá el kit del Commit Club y escribí `/stellarize`. Ver [stellar-commit-club](https://github.com/stevmolina/stellar-commit-club).

## Wallet

1. Instalá [Freighter](https://www.freighter.app).
2. Settings → Network → **Testnet**.
3. Fondeá tu cuenta gratis con [Friendbot](https://lab.stellar.org/account/fund).
