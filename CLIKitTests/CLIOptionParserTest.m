//
//  CLIOptionParserTest.m
//  CLIKit
//
//  Created by Michael James on 9/17/14.
//  Copyright (c) 2014 Maple Glen Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "CLIOptionParser.h"
#import <string.h>

@interface CLIOptionParserTest : XCTestCase
{
    CLIOptionParser*    _optionParser;
}

@end

@implementation CLIOptionParserTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCanCreateWithArgumentsFromMain {
    const char** mainArgs = (const char**)malloc(4 * sizeof(const char*));
    
    mainArgs[0] = "progname";
    mainArgs[1] = "-f";
    mainArgs[2] = "filename";
    mainArgs[3] = "--long-option";
    
    _optionParser = [[CLIOptionParser alloc] initWithArgumentsFromMain: mainArgs count: 4];
    XCTAssertNotNil(_optionParser);
    
    free(mainArgs);
}

//- (void)testExample {
//    // This is an example of a functional test case.
//    XCTAssert(YES, @"Pass");
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}}

@end
