// End-to-end check of the web client against the deployed contract, using a
// local Testnet key instead of Freighter. Usage:
//   node scripts/smoke-test.cjs <stellar-key-alias>
const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");
const StellarSdk = require("@stellar/stellar-sdk");
const makeClient = require("../docs/gratitude-client.js");

const alias = process.argv[2] || "me";
const cfgSrc = fs.readFileSync(path.join(__dirname, "../docs/config.js"), "utf8");
const window = {};
new Function("window", cfgSrc)(window);
const cfg = window.CONFIG;

const secret = execSync(`stellar keys secret ${alias}`).toString().trim();
const kp = StellarSdk.Keypair.fromSecret(secret);
const sign = async (xdr) => {
  const tx = StellarSdk.TransactionBuilder.fromXDR(xdr, cfg.networkPassphrase);
  tx.sign(kp);
  return tx.toXDR();
};

(async () => {
  const client = makeClient(StellarSdk, cfg);
  const before = await client.count();
  const { hash, id } = await client.thank(kp.publicKey(), "Commit Club", "smoke test " + new Date().toISOString(), sign);
  const after = await client.count();
  const [latest] = await client.list(1);
  if (after !== before + 1 || id !== after || latest.id !== id) throw new Error(`unexpected state before=${before} after=${after} id=${id}`);
  console.log(`OK count ${before} -> ${after}, note #${id}`);
  console.log(`Proof: https://stellar.expert/explorer/testnet/tx/${hash}`);
})().catch((e) => { console.error("FAIL", e.message); process.exit(1); });
