//
//  DSRemoteSendTests.m
//  DocuSign iOS SDK
//
//  Created by Mike Borozdin on 7/28/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DSSessionManager.h"
#import "DSTabs.h"
#import "DSSignHereTab.h"
#import "DSCreateEnvelopeResponse.h"

@interface DSRemoteSendTests : XCTestCase <DSSessionManagerAuthenticationDelegate>

@property DSLoginAccount* dsAccount;
- (void)sessionManager:(DSSessionManager *)sessionManager authenticationSucceededWithAccount:(DSLoginAccount *)account;
- (void)sessionManager:(DSSessionManager *)sessionManager authenticationFailedWithError:(NSError *)error;

@end

@implementation DSRemoteSendTests

// TOOD: clean up after checking in.
NSString * const TEST_IK = @"<your-docusign-integrator-key>";
NSString * const TEST_LOGIN = @"<your-login-email>";
NSString * const TEST_PASSWORD = @"<your-login-password>";
NSString * const TEST_RECIPIENT_EMAIL = @"<test-recipient-email>";

- (void)sessionManager:(DSSessionManager *)sessionManager authenticationSucceededWithAccount:(DSLoginAccount *)account
{
    NSLog(@"got logged in");
    self.dsAccount = account;
}

- (void)sessionManager:(DSSessionManager *)sessionManager authenticationFailedWithError:(NSError *)error
{
    NSLog(@"%s error %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
}


- (void)testSendTestDoc
{
    __block NSString* envelopeID;
    //
    // load file data
    NSBundle *myBundle = [NSBundle bundleForClass: [self class]];

    
    DSSessionManager* manager = [[DSSessionManager alloc] initWithIntegratorKey:TEST_IK forEnvironment:DSRestAPIEnvironmentDemo username:TEST_LOGIN password:TEST_PASSWORD authDelegate:self];
    [manager authenticate];
    
    // put this thread to sleep for a couple of seconds
    NSDate* timeLapse =[[NSDate new] initWithTimeIntervalSinceNow:5.0];
    [[NSRunLoop currentRunLoop] runUntilDate:timeLapse];
    
    XCTAssertNotNil(self.dsAccount);
    
    DSEnvelopeRecipient* recipient = [[DSEnvelopeRecipient alloc] init];
    recipient.name = @"Joe Doe";
    recipient.email = TEST_RECIPIENT_EMAIL;
    recipient.recipientID = @"1";
    recipient.routingOrder = 1;
    DSTabs* tabs = [[DSTabs alloc] init];
    DSSignHereTab* signHereTab = [[DSSignHereTab alloc] init];
    signHereTab.xPosition = @100;
    signHereTab.yPosition = @100;
    signHereTab.recipientId = @"1";
    signHereTab.documentId = @"1";
    signHereTab.pageNumber = @1;
    signHereTab.scaleValue = @"1.0";  // weird that this can't be null, but it is what it is.
    tabs.signHereTabs = [[NSArray alloc] initWithObjects:signHereTab, nil];
    recipient.tabs = tabs;
    
    [manager startRemoteSignEnvelopeTaskWithFileName:@"SalesOrder.pdf" fileURL:[[NSURL alloc] initFileURLWithPath:[myBundle pathForResource:@"Sales Order" ofType:@"pdf"]] recipient:recipient completionHandler:^(DSCreateEnvelopeResponse *response, NSError *error) {
        XCTAssertNil(error, @"%s error %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
        envelopeID = response.envelopeID;
        NSLog(@"Status %d, envelope ID is %@", response.status, response.envelopeID);
    }];
    
    // put this thread to sleep for a couple of seconds
    timeLapse =[[NSDate new] initWithTimeIntervalSinceNow:10.0];
    [[NSRunLoop currentRunLoop] runUntilDate:timeLapse];
    
    XCTAssertNotNil(envelopeID, @"Should have an envelope ID");
}

@end
