//
//  BalancedTests.m
//  BalancedTests
//
//  Created by Ben Mills on 3/9/13.
//

#import "BalancedTests.h"
#import "Balanced.h"
#import "BPCard.h"
#import "BPUtilities.h"

@implementation BalancedTests


// Tokenize cards

- (void)testTokenizeCard {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSDictionary *response;
    BPCard *card = [[BPCard alloc] initWithNumber:@"4242424242424242" andExperationMonth:@"8" andExperationYear:@"2025" andSecurityCode:@"123"];
    Balanced *balanced = [[Balanced alloc] initWithMarketplaceURI:@"/v1/marketplaces/TEST-MP2BTDSHT7BYTjxlhdWtXWNN"];
    [balanced tokenizeCard:card onSuccess:^(NSDictionary *responseParams) {
        response = responseParams;
        dispatch_semaphore_signal(semaphore);
    } onError:^(NSError *error) {
        dispatch_semaphore_signal(semaphore);
    }];
    
    while(dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    STAssertNotNil(response, @"Response should not be nil");
    STAssertNotNil([response valueForKey:@"uri"], @"Card URI should not be nil");
}

- (void)testTokenizeCardWithOptionalFields {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSDictionary *response;
    NSDictionary *optionalFields = @{
                                     BPCardOptionalParamNameKey:@"Johann Bernoulli",
                                     };
    BPCard *card = [[BPCard alloc] initWithNumber:@"4242424242424242" andExperationMonth:@"8" andExperationYear:@"2025" andSecurityCode:@"123" andOptionalFields:optionalFields];
    Balanced *balanced = [[Balanced alloc] initWithMarketplaceURI:@"/v1/marketplaces/TEST-MP2BTDSHT7BYTjxlhdWtXWNN"];
    [balanced tokenizeCard:card onSuccess:^(NSDictionary *responseParams) {
        response = responseParams;
        dispatch_semaphore_signal(semaphore);
    } onError:^(NSError *error) {
        dispatch_semaphore_signal(semaphore);
    }];
    
    while(dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    STAssertNotNil(response, @"Response should not be nil");
    STAssertNotNil([response valueForKey:@"uri"], @"Card URI should not be nil");
    STAssertNotNil([response valueForKey:@"name"], @"Name should not be nil");
    STAssertTrue([[response valueForKey:@"name"] isEqualToString:[optionalFields objectForKey:@"name"]], @"Name should be %@", [optionalFields objectForKey:@"name"]);
    //TODO: according to Balance's API docs, street_address is required when optional fields are also submitted
}


// Tokenize bank accounts

- (void)testTokenizeBankAccount {
    NSError *error;
    Balanced *balanced = [[Balanced alloc] initWithMarketplaceURI:@"/v1/marketplaces/TEST-MP2autgNHAZxRWZs76RriOze"];
    BPBankAccount *ba = [[BPBankAccount alloc] initWithRoutingNumber:@"053101273" andAccountNumber:@"111111111111" andAccountType:@"checking" andName:@"Johann Bernoulli"];
    NSDictionary *response = [balanced tokenizeBankAccount:ba error:&error];
    
    if (error != NULL) { STFail(@"Response should not have an error"); }
    
    STAssertNotNil(response, @"Response should not be nil");
    STAssertNotNil([response valueForKey:@"uri"], @"Bank account URI should not be nil");
}

- (void)testTokenizeBankAccountWithOptionalFields {
    NSError *error;
    Balanced *balanced = [[Balanced alloc] initWithMarketplaceURI:@"/v1/marketplaces/TEST-MP2autgNHAZxRWZs76RriOze"];
    NSDictionary *optionalFields = [[NSDictionary alloc] initWithObjectsAndKeys:@"Testing", @"meta", nil];
    BPBankAccount *ba = [[BPBankAccount alloc] initWithRoutingNumber:@"053101273" andAccountNumber:@"111111111111" andAccountType:@"checking" andName:@"Johann Bernoulli" andOptionalFields:optionalFields];
    NSDictionary *response = [balanced tokenizeBankAccount:ba error:&error];
    
    if (error != NULL) { STFail(@"Response should not have an error"); }
    
    STAssertNotNil(response, @"Response should not be nil");
}

@end
