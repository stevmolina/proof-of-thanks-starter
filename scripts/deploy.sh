#!/usr/bin/env bash
# Test, build and deploy every contract change to Testnet, then point the web
# page at the new contract. Usage: scripts/deploy.sh [contract-name]
set -euo pipefail
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
name="${1:-gratitude}"
cd "$(dirname "$0")/.."

echo "▸ Running contract tests"
cargo test --quiet

echo "▸ Building WASM"
stellar contract build --package "$name" >/dev/null

echo "▸ Deploying to Testnet"
id=$(stellar contract deploy \
  --wasm "target/wasm32v1-none/release/${name//-/_}.wasm" \
  --source-account me --network testnet --alias "$name" 2>/dev/null | tail -1)
case "$id" in C*) ;; *) echo "Deploy failed"; exit 1 ;; esac
me=$(stellar keys address me)

cat > docs/config.js <<EOF
// Written by scripts/deploy.sh. Testnet only.
window.CONFIG = {
  contractId: "$id",
  rpcUrl: "https://soroban-testnet.stellar.org",
  networkPassphrase: "Test SDF Network ; September 2015",
  // Any funded Testnet account, used only as the source for read-only simulations.
  readAccount: "$me",
};
EOF

echo "CONTRACT_ID=$id"
echo "Explorer: https://stellar.expert/explorer/testnet/contract/$id"
