#[cfg(test)]
mod test {
    use super::*;
    use soroban_sdk::testutils::Env as TestEnv;

    #[test]
    fn test_buy_ticket() {
        let env = TestEnv::default();
        let contract_id = env.register_contract(None, CulturalHeritageContract);
        let client = CulturalHeritageContractClient::new(&env, &contract_id);

        assert_eq!(client.buy_ticket(), 1);
        assert_eq!(client.buy_ticket(), 2);
    }

    #[test]
    fn test_donate() {
        let env = TestEnv::default();
        let contract_id = env.register_contract(None, CulturalHeritageContract);
        let client = CulturalHeritageContractClient::new(&env, &contract_id);

        assert_eq!(client.donate(10), 10);
        assert_eq!(client.donate(20), 30);
    }
}
