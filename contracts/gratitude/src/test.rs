#![cfg(test)]

use super::*;
use soroban_sdk::{testutils::Address as _, Address, Env, String};

fn setup() -> (Env, GratitudeClient<'static>) {
    let env = Env::default();
    env.mock_all_auths();
    let id = env.register(Gratitude, ());
    let client = GratitudeClient::new(&env, &id);
    (env, client)
}

#[test]
fn thank_stores_note_and_counts() {
    let (env, client) = setup();
    let alice = Address::generate(&env);

    assert_eq!(client.count(), 0);
    let id = client.thank(
        &alice,
        &String::from_str(&env, "Elisa"),
        &String::from_str(&env, "Gracias por el Commit Club!"),
    );
    assert_eq!(id, 1);
    assert_eq!(client.count(), 1);

    let note = client.get(&1).unwrap();
    assert_eq!(note.from, alice);
    assert_eq!(note.to, String::from_str(&env, "Elisa"));
    assert!(client.get(&2).is_none());
}

#[test]
fn thank_requires_sender_auth() {
    let (env, client) = setup();
    let alice = Address::generate(&env);
    client.thank(
        &alice,
        &String::from_str(&env, "Steven"),
        &String::from_str(&env, "Thanks!"),
    );
    assert_eq!(env.auths()[0].0, alice);
}

#[test]
#[should_panic]
fn empty_message_is_rejected() {
    let (env, client) = setup();
    let alice = Address::generate(&env);
    client.thank(&alice, &String::from_str(&env, "Steven"), &String::from_str(&env, ""));
}
