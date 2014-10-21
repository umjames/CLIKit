//
//  CLIApplicationTest.m
//  CLIKit
//
//  Created by Michael James on 10/19/14.
//  Copyright (c) 2014 Maple Glen Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "CLIApplication.h"
#import "CLIOption.h"
#import "CLIArrayUtils.h"
#import "CLIStringUtils.h"

static id mockDelegateForCLIApplicationMain = nil;

@interface CLIApplicationMainTestDelegate : NSObject <CLIApplicationDelegate>

- (instancetype)init;

@end

@implementation CLIApplicationMainTestDelegate

- (instancetype)init {
    if (self = [super init]) {
        if (nil == mockDelegateForCLIApplicationMain) {
            mockDelegateForCLIApplicationMain = OCMProtocolMock(@protocol(CLIApplicationDelegate));
        }
        return self;
    }
    
    return nil;
}

- (void)applicationWillBeginRunning: (CLIApplication*)application {
    [mockDelegateForCLIApplicationMain applicationWillBeginRunning: application];
}

- (void)applicationWillEndRunning: (CLIApplication*)application {
    [mockDelegateForCLIApplicationMain applicationWillEndRunning: application];
}

- (NSArray*)recognizedOptionsForApplication: (CLIApplication*)application {
    return [mockDelegateForCLIApplicationMain recognizedOptionsForApplication: application];
}

- (void)application: (CLIApplication*)application didEncounterOptionWithName: (NSString*)optionName argument: (NSString*)optionArgument {
    [mockDelegateForCLIApplicationMain application: application didEncounterOptionWithName: optionName argument: optionArgument];
}

- (void)application: (CLIApplication*)application isReadyToBeginExecutingWithRemainingArguments: (NSArray*)arguments {
    [mockDelegateForCLIApplicationMain application: application isReadyToBeginExecutingWithRemainingArguments: arguments];
}

- (void)application: (CLIApplication*)application didFailOptionParsingWithError: (NSError*)error {
    [mockDelegateForCLIApplicationMain application: application didFailOptionParsingWithError: error];
}

- (NSArray*)programUsageExamples {
    return [mockDelegateForCLIApplicationMain programUsageExamples];
}

- (NSString*)programDescriptionText {
    return [mockDelegateForCLIApplicationMain programDescriptionText];
}

- (NSString*)usageTextForOption: (CLIOption*)option {
    return [mockDelegateForCLIApplicationMain usageTextForOption: option];
}

@end

@interface CLIApplicationTest : XCTestCase
{
    CLIApplication*     _application;
}

@end

@implementation CLIApplicationTest

- (void)setUp {
    [super setUp];
    _application = [[CLIApplication alloc] init];
}

- (void)tearDown {
    mockDelegateForCLIApplicationMain = nil;
    [super tearDown];
}

- (id)mockDelegateWithRecognizedOptions: (NSArray*)options {
    id mockDelegate = OCMProtocolMock(@protocol(CLIApplicationDelegate));
    
    OCMExpect([mockDelegate recognizedOptionsForApplication: [OCMArg isKindOfClass: [CLIApplication class]]]).andReturn(options);
    
    return mockDelegate;
}

- (char* const*)argvForString: (NSString*)commandlineString {
    NSArray*    arguments = [commandlineString componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSArray*    filteredArguments = [CLIArrayUtils objectsFromArray: arguments passingTest: ^BOOL(NSString* string, NSUInteger index, BOOL *stop) {
        return ![CLIStringUtils isBlank: string];
    }];
    
    char**    result = malloc([filteredArguments count] * sizeof(char*));
    
    for (int index = 0; index < [filteredArguments count]; index++) {
        result[index] = (char*)[filteredArguments[index] cStringUsingEncoding: NSASCIIStringEncoding];
    }
    
    return result;
}

- (void)testCanCreateApplication {
    XCTAssertNotNil(_application);
}

- (void)testDelegateMethodsOnSuccessfulApplicationRun {
    NSArray* options = @[ [CLIOption shortOptionWithName: @"v" canHaveArgument: NO thatIsRequired: NO aliases: @[@"version"]],
                          [CLIOption shortOptionWithName: @"o" canHaveArgument: YES thatIsRequired: YES aliases: @[@"output"]] ];
    
    id delegate = [self mockDelegateWithRecognizedOptions: options];
    
    _application.delegate = delegate;
    
    OCMExpect([delegate applicationWillBeginRunning: _application]);
    OCMExpect([delegate application: _application didEncounterOptionWithName: @"o" argument: @"outputfile"]);
    OCMExpect([delegate application: _application isReadyToBeginExecutingWithRemainingArguments: @[@"inputfile"]]);
    OCMExpect([delegate applicationWillEndRunning: _application]);
    
    char* const* commandlineArgs = [self argvForString: @"progname -o outputfile inputfile"];
    
    [_application runWithCommandlineArguments: commandlineArgs count: 4];
    XCTAssertEqual(0, _application.exitCode);
    
    OCMVerifyAll(delegate);
    
    free((char**)commandlineArgs);
}

- (void)testDelegateMethodsOnFailingApplicationRun {
    NSArray* options = @[ [CLIOption shortOptionWithName: @"v" canHaveArgument: NO thatIsRequired: NO aliases: @[@"version"]],
                          [CLIOption shortOptionWithName: @"o" canHaveArgument: YES thatIsRequired: YES aliases: @[@"output"]] ];
    
    id delegate = [self mockDelegateWithRecognizedOptions: options];
    
    _application.delegate = delegate;
    
    OCMExpect([delegate applicationWillBeginRunning: _application]);
    OCMExpect([delegate application: _application didFailOptionParsingWithError: [OCMArg isKindOfClass: [NSError class]]]);
    OCMExpect([delegate applicationWillEndRunning: _application]);
    
    char* const* commandlineArgs = [self argvForString: @"progname -k outputfile inputfile"];
    
    [_application runWithCommandlineArguments: commandlineArgs count: 4];
    
    OCMVerifyAll(delegate);
    
    free((char**)commandlineArgs);
}

- (void)testUsageMessageGenerationWithoutDelegateGeneratesBlankString {
    XCTAssertNil(_application.delegate);
    
    XCTAssertTrue([CLIStringUtils isBlank: [_application generateUsageMessage]]);
}

- (void)testUsageMessageGenerationWithDelegate {
    NSArray* options = @[ [CLIOption longOptionWithName: @"help" canHaveArgument: NO thatIsRequired: NO aliases: @[@"h"]],
                          [CLIOption shortOptionWithName: @"v" canHaveArgument: NO thatIsRequired: NO aliases: @[@"version"]] ];
    
    id mockDelegte = [self mockDelegateWithRecognizedOptions: options];
    
    _application.delegate = mockDelegte;
    
    OCMExpect([mockDelegte programDescriptionText]).andReturn(@"Test program description");
    OCMExpect([mockDelegte programUsageExamples]).andReturn(([NSArray arrayWithObjects: @"progname -h", @"progname -v", nil]));
    OCMExpect([mockDelegte usageTextForOption: options[0]]).andReturn(nil);
    OCMExpect([mockDelegte usageTextForOption: options[1]]).andReturn(nil);
    
    NSString* usageMessage = [_application generateUsageMessage];
    
    OCMVerifyAll(mockDelegte);
    
    XCTAssertFalse([CLIStringUtils isBlank: usageMessage]);
}

- (void)testCLIApplicationMain {
    NSArray* options = @[ [CLIOption shortOptionWithName: @"v" canHaveArgument: NO thatIsRequired: NO aliases: @[@"version"]],
                          [CLIOption shortOptionWithName: @"o" canHaveArgument: YES thatIsRequired: YES aliases: @[@"output"]] ];
    
    mockDelegateForCLIApplicationMain = OCMProtocolMock(@protocol(CLIApplicationDelegate));
    
    OCMExpect([mockDelegateForCLIApplicationMain recognizedOptionsForApplication: [OCMArg isKindOfClass: [CLIApplication class]]]).andReturn(options);
    
    OCMExpect([mockDelegateForCLIApplicationMain applicationWillBeginRunning: [OCMArg isKindOfClass: [CLIApplication class]]]);
    OCMExpect([mockDelegateForCLIApplicationMain application: [OCMArg isKindOfClass: [CLIApplication class]] didEncounterOptionWithName: @"o" argument: @"outputfile"]);
    OCMExpect([mockDelegateForCLIApplicationMain application: [OCMArg isKindOfClass: [CLIApplication class]] isReadyToBeginExecutingWithRemainingArguments: @[@"inputfile"]]);
    OCMExpect([mockDelegateForCLIApplicationMain applicationWillEndRunning: [OCMArg isKindOfClass: [CLIApplication class]]]);
    
    char* const* commandlineArgs = [self argvForString: @"progname -o outputfile inputfile"];
    
    int returnCode = CLIApplicationMain(@"CLIApplicationMainTestDelegate", commandlineArgs, 4);
    
    XCTAssertEqual(0, returnCode);
    XCTAssertNotNil(mockDelegateForCLIApplicationMain);
    OCMVerifyAll(mockDelegateForCLIApplicationMain);
    
    free((char**)commandlineArgs);
}

@end
