#!/usr/bin/env bash
# One-time setup: checks tools, installs what's missing (no sudo needed),
# and creates a funded Testnet identity called "me".
# Safe to run again: it skips anything already done.
set -euo pipefail

say() { printf '\n\033[1;35m▸ %s\033[0m\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

say "Checking git, gh and node"
for t in git gh node; do
  if ! have "$t"; then echo "Missing: $t. Install it (or open this repo in GitHub Codespaces, where everything is preinstalled)."; exit 1; fi
done
node -e 'const [a,b]=process.versions.node.split(".").map(Number); if(a<22||(a===22&&b<12)){console.error("Node 22.12+ needed, found "+process.versions.node);process.exit(1)}'

say "Checking Rust"
if ! have cargo; then
  curl -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
  export PATH="$HOME/.cargo/bin:$PATH"
fi
rustup target add wasm32v1-none >/dev/null

say "Checking Stellar CLI"
if ! have stellar; then
  os=$(uname -s); arch=$(uname -m)
  case "$os-$arch" in
    Linux-x86_64) triple=x86_64-unknown-linux-gnu ;;
    Linux-aarch64) triple=aarch64-unknown-linux-gnu ;;
    Darwin-arm64) triple=aarch64-apple-darwin ;;
    Darwin-x86_64) triple=x86_64-apple-darwin ;;
    *) echo "Unsupported platform $os-$arch. Use Codespaces."; exit 1 ;;
  esac
  tag=$(curl -sSf https://api.github.com/repos/stellar/stellar-cli/releases/latest | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>console.log(JSON.parse(s).tag_name))')
  mkdir -p "$HOME/.local/bin"
  curl -sSfL "https://github.com/stellar/stellar-cli/releases/download/$tag/stellar-cli-${tag#v}-$triple.tar.gz" | tar -xz -C "$HOME/.local/bin" stellar
fi
stellar --version | head -1

say "Checking C linker (needed by Rust)"
if ! have cc; then
  echo "No C compiler found. On macOS run: xcode-select --install. On Ubuntu: sudo apt install build-essential. Or use Codespaces."
  exit 1
fi

say "Testnet identity 'me'"
if stellar keys address me >/dev/null 2>&1; then
  echo "Already exists: $(stellar keys address me)"
else
  stellar keys generate me --network testnet --fund
fi
# Top up if Friendbot funding failed earlier (harmless if already funded).
stellar keys fund me --network testnet >/dev/null 2>&1 || true
echo "Address: $(stellar keys address me)"

say "Installing JS dev dependency"
npm install --silent

say "Setup complete ✅"
