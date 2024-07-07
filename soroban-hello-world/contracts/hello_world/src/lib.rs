#![no_std]
use soroban_sdk::{contract, contractimpl, Env, Symbol};

#[contract]
pub struct HeritageContract;

#[contractimpl]
impl HeritageContract {
    fn ticket_counter_symbol(env: &Env) -> Symbol {
        Symbol::new(env, "TICKET_COUNTER")
    }

    fn donation_amount_symbol(env: &Env) -> Symbol {
        Symbol::new(env, "DONATION_AMOUNT")
    }

    /// Buy a ticket, incrementing the internal counter, and return the value.
    pub fn buy_ticket(env: Env) -> u32 {
        let counter_symbol = Self::ticket_counter_symbol(&env);
        let mut count: u32 = env.storage().instance().get(&counter_symbol).unwrap_or(0);
        count += 1;
        env.storage().instance().set(&counter_symbol, &count);
        count
    }

    /// Donate a specified amount and return the total amount.
    pub fn donate(env: Env, amount: u32) -> u32 {
        let donation_symbol = Self::donation_amount_symbol(&env);
        let mut total: u32 = env.storage().instance().get(&donation_symbol).unwrap_or(0);
        total += amount;
        env.storage().instance().set(&donation_symbol, &total);
        total
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use soroban_sdk::Env;

    #[test]
    fn test_buy_ticket() {
        let env = Env::default();
        let contract_id = env.register_contract(None, HeritageContract);
        let client = HeritageContractClient::new(&env, &contract_id);

        assert_eq!(client.buy_ticket(), 1);
        assert_eq!(client.buy_ticket(), 2);
    }

    #[test]
    fn test_donate() {
        let env = Env::default();
        let contract_id = env.register_contract(None, HeritageContract);
        let client = HeritageContractClient::new(&env, &contract_id);

        assert_eq!(client.donate(10), 10);
        assert_eq!(client.donate(20), 30);
    }
}
