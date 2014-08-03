//
//  JsonTests.m
//  DocuSign iOS SDK
//
//  Created by Mike Borozdin on 7/25/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DSTabs.h"
#import "DSEnvelopeSigner.h"
#import "DSSignHereTab.h"
#import <Mantle/Mantle.h>

@interface JsonTests : XCTestCase

@end

@implementation JsonTests

- (void)testFileDataExists
{
    NSBundle *myBundle = [NSBundle bundleForClass: [self class]];
    NSString *path = [myBundle pathForResource:@"tabs" ofType:@"json"];
    XCTAssertNotNil(path, @"should get a path to the tabs JSON file");
    NSLog(@"path to JSON file is: %@", path);
    NSData *fileData = [NSData dataWithContentsOfFile:path];
    XCTAssertNotNil(fileData, @"should have file data");
}


- (void)testLoadTabs
{
    //
    // load file data
    NSBundle *myBundle = [NSBundle bundleForClass: [self class]];
    NSString *path = [myBundle pathForResource:@"tabs" ofType:@"json"];
    NSData *fileData = [NSData dataWithContentsOfFile:path];

    //
    // parse it
    NSError *error;
    NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:fileData options:0 error:&error];
    if (error) {
        XCTFail(@"Couldn't deserealize app info data into JSON from NSData: %@", error);
    }
    
    DSTabs *tabs = [MTLJSONAdapter modelOfClass:[DSTabs class] fromJSONDictionary:jsonArray error:&error];
    if (error) {
        XCTFail(@"Couldn't convert app infos JSON to DSTabs models: %@", error);
    }
    
    XCTAssertNotNil(tabs, @"Should have received a tabs object");
}

- (void)testLoadSigner
{
    //
    // load file data
    NSBundle *myBundle = [NSBundle bundleForClass: [self class]];
    NSString *path = [myBundle pathForResource:@"signer" ofType:@"json"];
    NSData *fileData = [NSData dataWithContentsOfFile:path];
    
    //
    // parse it
    NSError *error;
    NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:fileData options:0 error:&error];
    if (error) {
        XCTFail(@"Couldn't deserealize app info data into JSON from NSData: %@", error);
    }
    
    DSEnvelopeSigner *recipient = [MTLJSONAdapter modelOfClass:[DSEnvelopeSigner class] fromJSONDictionary:jsonArray error:&error];
    if (error) {
        XCTFail(@"Couldn't convert app infos JSON to DSEnvelopeRecipient models: %@", error);
    }
    
    XCTAssertNotNil(recipient, @"Should have received a recipient object");
    XCTAssertNotNil(recipient.name, @"Should have a name");
    XCTAssertTrue([recipient.name isEqualToString:@"Joe Doe"], "the name should match" );
}


- (void)testLoadSignerNoTabs
{
    //
    // load file data
    NSBundle *myBundle = [NSBundle bundleForClass: [self class]];
    NSString *path = [myBundle pathForResource:@"signer-no-tabs" ofType:@"json"];
    NSData *fileData = [NSData dataWithContentsOfFile:path];
    
    //
    // parse it
    NSError *error;
    NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:fileData options:0 error:&error];
    if (error) {
        XCTFail(@"Couldn't deserealize app info data into JSON from NSData: %@", error);
    }
    
    DSEnvelopeSigner *recipient = [MTLJSONAdapter modelOfClass:[DSEnvelopeSigner class] fromJSONDictionary:jsonArray error:&error];
    if (error) {
        XCTFail(@"Couldn't convert app infos JSON to DSEnvelopeRecipient models: %@", error);
    }
    
    XCTAssertNotNil(recipient, @"Should have received a recipient object");
    XCTAssertNotNil(recipient.name, @"Should have a name");
    XCTAssertTrue([recipient.name isEqualToString:@"Joe Doe"], "the name should match");
}

-(void)testSerializeRecipient
{
    DSEnvelopeRecipient* recipient = [[DSEnvelopeRecipient alloc] init];
    recipient.name = @"Joe Doe";
    recipient.email = @"todo@email.com";
    recipient.recipientID = @"1";
    DSTabs* tabs = [[DSTabs alloc] init];
    DSSignHereTab* signHereTab = [[DSSignHereTab alloc] init];
    signHereTab.xPosition = @100;
    signHereTab.yPosition = @100;
    signHereTab.recipientId = @"1";
    signHereTab.documentId = @"1";
    tabs.signHereTabs = [[NSArray alloc] initWithObjects:signHereTab, nil];
    recipient.tabs = tabs;
    
    NSDictionary *jsonDictionary = [MTLJSONAdapter JSONDictionaryFromModel:recipient];
    XCTAssertNotNil(jsonDictionary, @"Should get jsonDictionary back");
    NSData* encodedData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:nil];
    XCTAssertNotNil(encodedData, @"Should get encodedData back");
    NSString* jsonString =[[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];
    XCTAssertNotNil(jsonString, @"Should be getting a non-empty string back");
    NSLog(@"JSON:\n%@", jsonString);
}

@end
