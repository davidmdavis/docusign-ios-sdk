//
//  JsonTests.m
//  DocuSign iOS SDK
//
//  Created by Mike Borozdin on 7/25/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DSTabs.h"
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

@end
