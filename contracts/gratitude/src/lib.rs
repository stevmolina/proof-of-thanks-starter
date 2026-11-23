#![no_std]
//! Gratitude: a tiny "Proof of Thanks" contract for Stellar Testnet.
//!
//! Anyone can leave a public thank-you note. The sender signs it with their
//! wallet, so every note is a verifiable on-chain proof of gratitude.
//! This is the starting point that `/stellarize` adapts to each idea.

use soroban_sdk::{contract, contractevent, contractimpl, contracttype, Address, Env, String};

const DAY_IN_LEDGERS: u32 = 17_280;
const BUMP_THRESHOLD: u32 = 7 * DAY_IN_LEDGERS;
const BUMP_TO: u32 = 30 * DAY_IN_LEDGERS;

#[contracttype]
#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Thanks {
    pub from: Address,
    pub to: String,
    pub message: String,
    pub ledger: u32,
}

#[contracttype]
#[derive(Clone)]
pub enum DataKey {
    Count,
    Thanks(u32),
}

#[contractevent]
#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Thanked {
    #[topic]
    pub from: Address,
    pub id: u32,
}

#[contract]
pub struct Gratitude;

#[contractimpl]
impl Gratitude {
    /// Leave a thank-you note. Returns the note id (starts at 1).
    pub fn thank(env: Env, from: Address, to: String, message: String) -> u32 {
        from.require_auth();
        if to.len() == 0 || to.len() > 64 {
            panic!("`to` must be 1-64 chars");
        }
        if message.len() == 0 || message.len() > 280 {
            panic!("`message` must be 1-280 chars");
        }

        let id: u32 = env.storage().instance().get(&DataKey::Count).unwrap_or(0) + 1;
        let note = Thanks {
            from: from.clone(),
            to,
            message,
            ledger: env.ledger().sequence(),
        };
        let key = DataKey::Thanks(id);
        env.storage().persistent().set(&key, &note);
        env.storage().persistent().extend_ttl(&key, BUMP_THRESHOLD, BUMP_TO);
        env.storage().instance().set(&DataKey::Count, &id);
        env.storage().instance().extend_ttl(BUMP_THRESHOLD, BUMP_TO);

        Thanked { from, id }.publish(&env);
        id
    }

    /// How many notes exist.
    pub fn count(env: Env) -> u32 {
        env.storage().instance().get(&DataKey::Count).unwrap_or(0)
    }

    /// Read one note by id.
    pub fn get(env: Env, id: u32) -> Option<Thanks> {
        env.storage().persistent().get(&DataKey::Thanks(id))
    }
}

mod test;
