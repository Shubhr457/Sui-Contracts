#[test_only]
module 0x0::token_tests {
    use 0x0::token::{Self, TOKEN};
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::test_scenario::{Self, next_tx, ctx};
    // tx_context is not needed
    
    #[test]
    fun mint_token() {
        // Mock sender address
        let addr1 = @0xA;

        // Start a multi-transaction scenario with addr1 as sender
        let mut scenario = test_scenario::begin(addr1);

        // Call the module init function
        {
            // Use the test_init helper function
            token::test_init(ctx(&mut scenario));
        };

        // Mint tokens to addr1
        next_tx(&mut scenario, addr1);
        {
            let mut treasury_cap = test_scenario::take_from_sender<TreasuryCap<TOKEN>>(&scenario);
            token::mint(&mut treasury_cap, addr1, 1000, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_address<TreasuryCap<TOKEN>>(addr1, treasury_cap);
        };

        // Verify that tokens were actually minted to addr1
        next_tx(&mut scenario, addr1);
        {
            // Get all coins owned by addr1
            let coins = test_scenario::take_from_sender<Coin<TOKEN>>(&scenario);
            
            // Assert that the coin exists and has the correct amount
            assert!(sui::coin::value(&coins) == 1000, 0);
            
            // Return the coin back to the sender
            test_scenario::return_to_sender(&scenario, coins);
        };

        // Clean up the scenario
        test_scenario::end(scenario);
    }
}
