// Tiny client for the Gratitude contract. Works in the browser (global
// `GratitudeClient`, with the StellarSdk CDN build) and in Node (require).
// `signXdr(xdr) -> Promise<signedXdr>` is provided by Freighter in the browser
// or by a local Keypair in tests.
(function (root, factory) {
  if (typeof module === "object" && module.exports) module.exports = factory;
  else root.GratitudeClient = factory;
})(typeof self !== "undefined" ? self : this, function (StellarSdk, cfg) {
  const { rpc, Contract, TransactionBuilder, BASE_FEE, nativeToScVal, scValToNative, Address } = StellarSdk;
  const server = new rpc.Server(cfg.rpcUrl);
  const contract = new Contract(cfg.contractId);

  async function build(source, method, args) {
    const account = await server.getAccount(source);
    return new TransactionBuilder(account, { fee: BASE_FEE, networkPassphrase: cfg.networkPassphrase })
      .addOperation(contract.call(method, ...args))
      .setTimeout(60)
      .build();
  }

  // Read-only call: simulate, never submit. Any funded account works as source.
  async function read(method, args = []) {
    const tx = await build(cfg.readAccount, method, args);
    const sim = await server.simulateTransaction(tx);
    if (rpc.Api.isSimulationError(sim)) throw new Error(sim.error);
    return scValToNative(sim.result.retval);
  }

  async function count() {
    return read("count");
  }

  async function list(limit = 20) {
    const n = await count();
    const ids = [];
    for (let i = n; i >= 1 && ids.length < limit; i--) ids.push(i);
    const notes = await Promise.all(ids.map((id) => read("get", [nativeToScVal(id, { type: "u32" })])));
    return notes.map((n, i) => ({ id: ids[i], ...n, from: String(n.from) }));
  }

  // Write: build -> simulate/prepare -> sign -> send -> wait.
  async function thank(from, to, message, signXdr) {
    const tx = await build(from, "thank", [
      new Address(from).toScVal(),
      nativeToScVal(to, { type: "string" }),
      nativeToScVal(message, { type: "string" }),
    ]);
    const prepared = await server.prepareTransaction(tx);
    const signed = TransactionBuilder.fromXDR(await signXdr(prepared.toXDR()), cfg.networkPassphrase);
    const sent = await server.sendTransaction(signed);
    if (sent.status === "ERROR") throw new Error("send failed: " + JSON.stringify(sent.errorResult));
    let res = await server.getTransaction(sent.hash);
    for (let i = 0; i < 30 && res.status === "NOT_FOUND"; i++) {
      await new Promise((r) => setTimeout(r, 1000));
      res = await server.getTransaction(sent.hash);
    }
    if (res.status !== "SUCCESS") throw new Error("tx " + res.status);
    return { hash: sent.hash, id: scValToNative(res.returnValue) };
  }

  return { count, list, thank };
});
