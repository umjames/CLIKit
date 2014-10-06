//
//  CLIUsageMessageGeneratorTest.m
//  CLIKit
//
//  Created by Michael James on 10/5/14.
//  Copyright (c) 2014 Maple Glen Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "CLIOption.h"
#import "CLIUsageMessageGenerator.h"

@interface CLIUsageMessageGeneratorTest : XCTestCase
{
    CLIUsageMessageGenerator*   _messageGenerator;
    NSArray*                    _commandlineOptions;
}

@end

@implementation CLIUsageMessageGeneratorTest

- (void)setUp {
    [super setUp];
    
    _commandlineOptions = [self sampleOptions];
    _messageGenerator = [[CLIUsageMessageGenerator alloc] initWithCommandLineOptions: _commandlineOptions];
}

- (void)tearDown {
    [super tearDown];
}

- (NSArray*)sampleOptions {
    NSMutableArray* options = [[NSMutableArray alloc] initWithCapacity: 4];
    
    [options addObject: [CLIOption shortOptionWithName: @"f" canHaveArgument: YES thatIsRequired: YES aliases: @[@"filename"] usageDescription: @"processes file" usageDescriptionArgumentName: @"FILE"]];
    [options addObject: [CLIOption longOptionWithName: @"version" canHaveArgument: NO thatIsRequired: NO aliases: @[@"v"] usageDescription: @"prints version number" usageDescriptionArgumentName: nil]];
    
    return options;
}

- (void)testCanCreateGeneratorWithOptions {
    XCTAssertNotNil(_messageGenerator);
}

- (void)testUsageMessageGenerationDelegateMethods {
    id delegateMock = OCMProtocolMock(@protocol(CLIUsageMessageGeneratorDelegate));
    
    _messageGenerator.delegate = delegateMock;
    
    OCMExpect([delegateMock programDescriptionText]);
    OCMExpect([delegateMock programUsageExamples]);
    OCMExpect([delegateMock usageTextForOption: _commandlineOptions[0]]);
    OCMExpect([delegateMock usageTextForOption: _commandlineOptions[1]]);
    
    NSString* usageMessage = [_messageGenerator generateUsageMessage];
    
    XCTAssertNotNil(usageMessage);
    OCMVerifyAll(delegateMock);
}

- (void)testCanGenerateUsageMessage {
    id delegateMock = OCMProtocolMock(@protocol(CLIUsageMessageGeneratorDelegate));
    
    _messageGenerator.delegate = delegateMock;
    
    OCMStub([delegateMock programDescriptionText]).andReturn(@"Test program description");
    OCMStub([delegateMock programUsageExamples]).andReturn(([NSArray arrayWithObjects: @"progname --filename=FILE", @"progname -v", nil]));
    OCMStub([delegateMock usageTextForOption: _commandlineOptions[0]]).andReturn(nil);
    OCMStub([delegateMock usageTextForOption: _commandlineOptions[1]]).andReturn(nil);
    
    NSString*   usageMessage = [_messageGenerator generateUsageMessage];
    
    NSLog(@"%@", usageMessage);
    XCTAssertNotNil(usageMessage);
}

@end
