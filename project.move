module MyModule::TokenWhitelist {
    use aptos_framework::signer;
    use std::vector;
    
    /// Error codes
    const E_NOT_AUTHORIZED: u64 = 1;
    const E_ALREADY_WHITELISTED: u64 = 2;
    const E_NOT_WHITELISTED: u64 = 3;
    
    /// Struct representing the token whitelist system
    struct Whitelist has store, key {
        admin: address,              // Admin who can manage the whitelist
        whitelisted_tokens: vector<address>,  // List of whitelisted token addresses
    }
    
    /// Function to initialize the whitelist system
    public fun initialize_whitelist(admin: &signer) {
        let admin_address = signer::address_of(admin);
        let whitelist = Whitelist {
            admin: admin_address,
            whitelisted_tokens: vector::empty<address>(),
        };
        move_to(admin, whitelist);
    }
    
    /// Function to add a token to the whitelist (only admin can call)
    public fun add_token_to_whitelist(
        admin: &signer, 
        token_address: address
    ) acquires Whitelist {
        let admin_address = signer::address_of(admin);
        let whitelist = borrow_global_mut<Whitelist>(admin_address);
        
        // Check if caller is the admin
        assert!(whitelist.admin == admin_address, E_NOT_AUTHORIZED);
        
        // Check if token is already whitelisted
        assert!(
            !vector::contains(&whitelist.whitelisted_tokens, &token_address), 
            E_ALREADY_WHITELISTED
        );
        
        // Add token to whitelist
        vector::push_back(&mut whitelist.whitelisted_tokens, token_address);
    }
    
    /// Function to check if a token is whitelisted
    public fun is_token_whitelisted(
        admin_address: address, 
        token_address: address
    ): bool acquires Whitelist {
        let whitelist = borrow_global<Whitelist>(admin_address);
        vector::contains(&whitelist.whitelisted_tokens, &token_address)
    }
}