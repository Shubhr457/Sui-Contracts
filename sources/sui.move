module 0x0::token {
    // No friend declaration needed
    use sui::coin::{Self, TreasuryCap};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use std::option;
   
    /// The type identifier of our token - one-time witness type
    public struct TOKEN has drop {}
   
    /// Module initializer is called once on module publish
    /// Creates the token and gives the treasury cap to the publisher
    fun init(witness: TOKEN, ctx: &mut TxContext) {
        // Create a new currency with our witness type
        let (treasury_cap, metadata) = coin::create_currency(
            witness,
            9, // decimals
            b"MYTK", // symbol
            b"MyToken", // name
            b"My custom token on Sui", // description
            option::none(), // icon url
            ctx
        );
       
        // Transfer the treasury cap to the publisher
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx));
        transfer::public_transfer(metadata, tx_context::sender(ctx));
    }
   
    /// Mint new tokens to recipient
    public fun mint(
        treasury_cap: &mut TreasuryCap<TOKEN>,
        recipient: address,
        amount: u64,
        ctx: &mut TxContext
    ) {
        // Mint tokens using the treasury cap
        let coin = coin::mint(treasury_cap, amount, ctx);
        // Transfer the minted tokens to recipient
        transfer::public_transfer(coin, recipient);
    }

    // Test helper to create a test TOKEN instance
    #[test_only]
    public fun create_test_token(): TOKEN {
        TOKEN {}
    }

    // Test helper to initialize the token module
    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(TOKEN {}, ctx)
    }
}
