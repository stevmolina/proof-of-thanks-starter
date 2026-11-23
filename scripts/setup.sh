#!/usr/bin/env bash
# One-time setup: checks tools, installs what's missing (no sudo needed),
# and creates a funded Testnet identity called "me".
# Safe to run again: it skips anything already done.
# Exit codes: 0 ok, 1 fixable problem (message says how), 2 use Codespaces.
set -euo pipefail

STELLAR_CLI_VERSION="30.0.1"   # pinned: tested with this template

say() { printf '\n\033[1;35m▸ %s\033[0m\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

os=$(uname -s); arch=$(uname -m)
case "$os" in
  MINGW*|MSYS*|CYGWIN*) echo "Windows detected: use GitHub Codespaces (or WSL) for this project."; exit 2 ;;
esac
if [ "$os" = Darwin ] && ! xcode-select -p >/dev/null 2>&1; then
  echo "macOS needs the Xcode command line tools. Run: xcode-select --install  (accept the popup, ~5 min), then run this again."
  exit 1
fi

say "Checking git, gh and node"
for t in git gh node; do
  if ! have "$t"; then
    case "$t" in
      gh) echo "Missing gh. macOS: brew install gh · Windows: winget install GitHub.cli · Linux: https://github.com/cli/cli/releases" ;;
      node) echo "Missing node. Install Node 22.12+ from https://nodejs.org (or: brew install node)." ;;
      git) echo "Missing git." ;;
    esac
    exit 1
  fi
done
node -e 'const [a,b]=process.versions.node.split(".").map(Number); if(a<22||(a===22&&b<12)){console.error("Node 22.12+ needed, found "+process.versions.node+". Install from https://nodejs.org");process.exit(1)}'

say "Checking C linker (needed by Rust)"
if ! have cc; then
  echo "No C compiler. Ubuntu/Debian: sudo apt install build-essential. Or use Codespaces."
  exit 2
fi

say "Checking Rust (first time downloads ~200 MB)"
if ! have cargo; then
  curl -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
  export PATH="$HOME/.cargo/bin:$PATH"
fi
rustup target add wasm32v1-none >/dev/null

say "Checking Stellar CLI"
if ! have stellar; then
  case "$os-$arch" in
    Linux-x86_64) triple=x86_64-unknown-linux-gnu ;;
    Linux-aarch64) triple=aarch64-unknown-linux-gnu ;;
    Darwin-arm64) triple=aarch64-apple-darwin ;;
    Darwin-x86_64) triple=x86_64-apple-darwin ;;
    *) echo "Unsupported platform $os-$arch. Use Codespaces."; exit 2 ;;
  esac
  mkdir -p "$HOME/.local/bin"
  # Direct release download: not subject to the GitHub API rate limit.
  curl -sSfL --retry 3 "https://github.com/stellar/stellar-cli/releases/download/v$STELLAR_CLI_VERSION/stellar-cli-$STELLAR_CLI_VERSION-$triple.tar.gz" \
    | tar -xz -C "$HOME/.local/bin" stellar
fi
stellar --version | head -1

say "Testnet identity 'me'"
stellar keys address me >/dev/null 2>&1 || stellar keys generate me --network testnet >/dev/null
funded=no
for i in 1 2 3; do
  if stellar keys fund me --network testnet >/dev/null 2>&1; then funded=yes; break; fi
  echo "Friendbot busy, retrying in 10 s ($i/3)…"; sleep 10
done
echo "Address: $(stellar keys address me) (funded: $funded)"
[ "$funded" = yes ] || echo "Funding failed for now. Retry later with: stellar keys fund me --network testnet"

say "Installing JS dev dependency"
npm install --silent

say "Setup complete ✅"
