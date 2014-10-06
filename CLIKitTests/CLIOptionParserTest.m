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

#import "CLIKit.h"

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

- (void)testCanCreate {
    _optionParser = [[CLIOptionParser alloc] init];
    XCTAssertNotNil(_optionParser);
}

- (void)testCanReadShortOptionsWithNoArguments {
    char* const*    cliArgs = [self createCommandlineArgumentsFromString: @"progname -xvf"];
    id              delegateMock = OCMProtocolMock(@protocol(CLIOptionParserDelegate));
    NSError*        error = nil;
    NSArray*        optionRequirements = @[ [CLIOption shortOptionWithName: @"v" canHaveArgument: NO thatIsRequired: NO aliases: nil],
                                            [CLIOption shortOptionWithName: @"x" canHaveArgument: NO thatIsRequired: NO aliases: nil],
                                            [CLIOption shortOptionWithName: @"f" canHaveArgument: NO thatIsRequired: NO aliases: nil]];
    
    _optionParser = [[CLIOptionParser alloc] init];
    OCMExpect([delegateMock optionParserWillBeginParsing: _optionParser]);
    OCMExpect([delegateMock optionParser: _optionParser didEncounterOptionWithName: @"x" argument: nil]);
    OCMExpect([delegateMock optionParser: _optionParser didEncounterOptionWithName: @"v" argument: nil]);
    OCMExpect([delegateMock optionParser: _optionParser didEncounterOptionWithName: @"f" argument: nil]);
    OCMExpect([delegateMock optionParserDidFinishParsing: _optionParser]);
    
    _optionParser.delegate = delegateMock;
    BOOL resultSucceeded = [_optionParser parseCommandLineArguments: cliArgs count: 2 optionsToRecognize: optionRequirements error: &error];
    XCTAssertTrue(resultSucceeded, @"parseCommandLineArguments:count:error: returned NO");
    
    OCMVerifyAll(delegateMock);
    
    free((char**)cliArgs);
}

- (void)testCanReadShortOptionsWithArguments {
    char* const*    cliArgs = [self createCommandlineArgumentsFromString: @"progname -f filename -o output"];
    id              delegateMock = OCMProtocolMock(@protocol(CLIOptionParserDelegate));
    NSError*        error = nil;
    NSArray*        optionRequirements = @[ [CLIOption shortOptionWithName: @"f" canHaveArgument: YES thatIsRequired: YES aliases: nil],
                                            [CLIOption shortOptionWithName: @"o" canHaveArgument: YES thatIsRequired: NO aliases: nil] ];
    
    _optionParser = [[CLIOptionParser alloc] init];
    OCMExpect([delegateMock optionParserWillBeginParsing: _optionParser]);
    OCMExpect([delegateMock optionParser: _optionParser didEncounterOptionWithName: @"f" argument: @"filename"]);
    OCMExpect([delegateMock optionParser: _optionParser didEncounterOptionWithName: @"o" argument: @"output"]);
    OCMExpect([delegateMock optionParserDidFinishParsing: _optionParser]);
    
    _optionParser.delegate = delegateMock;
    BOOL resultSucceeded = [_optionParser parseCommandLineArguments: cliArgs count: 5 optionsToRecognize: optionRequirements error: &error];
    XCTAssertTrue(resultSucceeded, @"parseCommandLineArguments:count:error: returned NO");
    
    OCMVerifyAll(delegateMock);
    
    free((char**)cliArgs);
    
    cliArgs = [self createCommandlineArgumentsFromString: @"progname -f filename -o"];
    
    OCMExpect([delegateMock optionParserWillBeginParsing: _optionParser]);
    OCMExpect([delegateMock optionParser: _optionParser didEncounterOptionWithName: @"f" argument: @"filename"]);
    OCMExpect([delegateMock optionParser: _optionParser didEncounterOptionWithName: @"o" argument: nil]);
    OCMExpect([delegateMock optionParserDidFinishParsing: _optionParser]);
    
    resultSucceeded = [_optionParser parseCommandLineArguments: cliArgs count: 4 optionsToRecognize: optionRequirements error: &error];
    XCTAssertTrue(resultSucceeded, @"parseCommandLineArguments:count:error: returned NO");
    
    OCMVerifyAll(delegateMock);
    
    free((char**)cliArgs);
}

- (void)testCanReadLongOptionsWithNoArguments {
    char* const*    cliArgs = [self createCommandlineArgumentsFromString: @"progname --version --no-ff"];
    id              delegateMock = OCMProtocolMock(@protocol(CLIOptionParserDelegate));
    NSError*        error = nil;
    NSArray*        optionRequirements = @[ [CLIOption longOptionWithName: @"version" canHaveArgument: NO thatIsRequired: NO aliases: nil],
                                            [CLIOption longOptionWithName: @"no-ff" canHaveArgument: NO thatIsRequired: NO aliases: nil]];
    
    _optionParser = [[CLIOptionParser alloc] init];
    OCMExpect([delegateMock optionParserWillBeginParsing: _optionParser]);
    OCMExpect([delegateMock optionParser: _optionParser didEncounterOptionWithName: @"version" argument: nil]);
    OCMExpect([delegateMock optionParser: _optionParser didEncounterOptionWithName: @"no-ff" argument: nil]);
    OCMExpect([delegateMock optionParserDidFinishParsing: _optionParser]);
    
    _optionParser.delegate = delegateMock;
    BOOL resultSucceeded = [_optionParser parseCommandLineArguments: cliArgs count: 3 optionsToRecognize: optionRequirements error: &error];
    XCTAssertTrue(resultSucceeded, @"parseCommandLineArguments:count:error: returned NO");
    
    OCMVerifyAll(delegateMock);
    
    free((char**)cliArgs);
}

- (void)testCanReadLongOptionsWithArguments {
    char* const*    cliArgs = [self createCommandlineArgumentsFromString: @"progname --file filename --log-level=debug"];
    id              delegateMock = OCMProtocolMock(@protocol(CLIOptionParserDelegate));
    NSError*        error = nil;
    NSArray*        optionRequirements = @[ [CLIOption longOptionWithName: @"file" canHaveArgument: YES thatIsRequired: YES aliases: nil],
                                            [CLIOption longOptionWithName: @"log-level" canHaveArgument: YES thatIsRequired: NO aliases: nil]];
    
    _optionParser = [[CLIOptionParser alloc] init];
    OCMExpect([delegateMock optionParserWillBeginParsing: _optionParser]);
    OCMExpect([delegateMock optionParser: _optionParser didEncounterOptionWithName: @"file" argument: @"filename"]);
    OCMExpect([delegateMock optionParser: _optionParser didEncounterOptionWithName: @"log-level" argument: @"debug"]);
    OCMExpect([delegateMock optionParserDidFinishParsing: _optionParser]);
    
    _optionParser.delegate = delegateMock;
    BOOL resultSucceeded = [_optionParser parseCommandLineArguments: cliArgs count: 4 optionsToRecognize: optionRequirements error: &error];
    XCTAssertTrue(resultSucceeded, @"parseCommandLineArguments:count:error: returned NO");
    
    OCMVerifyAll(delegateMock);
    
    free((char**)cliArgs);
}

- (void)testCanLeaveRemainingCommandlineArgumentsUntouched {
    char* const*    cliArgs = [self createCommandlineArgumentsFromString: @"progname --file filename arg1 arg2 arg3"];
    id              delegateMock = OCMProtocolMock(@protocol(CLIOptionParserDelegate));
    NSError*        error = nil;
    NSArray*        optionRequirements = @[ [CLIOption longOptionWithName: @"file" canHaveArgument: YES thatIsRequired: YES aliases: nil] ];
    NSArray*        remainingArguments = @[@"arg1", @"arg2", @"arg3"];
    
    _optionParser = [[CLIOptionParser alloc] init];
    OCMExpect([delegateMock optionParserWillBeginParsing: _optionParser]);
    OCMExpect([delegateMock optionParser: _optionParser didEncounterOptionWithName: @"file" argument: @"filename"]);
    OCMExpect([delegateMock optionParser: _optionParser didEncounterNonOptionArguments: remainingArguments]);
    OCMExpect([delegateMock optionParserDidFinishParsing: _optionParser]);
    
    _optionParser.delegate = delegateMock;
    BOOL resultSucceeded = [_optionParser parseCommandLineArguments: cliArgs count: 6 optionsToRecognize: optionRequirements error: &error];
    XCTAssertTrue(resultSucceeded, @"parseCommandLineArguments:count:error: returned NO");
    
    OCMVerifyAll(delegateMock);
    
    free((char**)cliArgs);
}

- (void)testReportsErrorWhenOptionMissingArgument {
    char* const*    cliArgs = [self createCommandlineArgumentsFromString: @"progname --file -- arg1 arg2 arg3"];
    id              delegateMock = OCMProtocolMock(@protocol(CLIOptionParserDelegate));
    NSError*        error = nil;
    NSArray*        optionRequirements = @[ [CLIOption longOptionWithName: @"file" canHaveArgument: YES thatIsRequired: YES aliases: nil] ];
    
    _optionParser = [[CLIOptionParser alloc] init];
    OCMExpect([delegateMock optionParserWillBeginParsing: _optionParser]);
    OCMExpect([delegateMock optionParserDidFinishParsing: _optionParser]);
    
    _optionParser.delegate = delegateMock;
    BOOL resultSucceeded = [_optionParser parseCommandLineArguments: cliArgs count: 6 optionsToRecognize: optionRequirements error: &error];
    XCTAssertFalse(resultSucceeded, @"parseCommandLineArguments:count:error: returned YES");
    XCTAssertNotNil(error, @"No error returned");
    XCTAssertEqualObjects(CLIKitErrorDomain, error.domain);
    XCTAssertEqual(kCLIMissingRequiredArgument, error.code);
    XCTAssertEqualObjects(@"file", error.userInfo[CLIOptionNameKey]);
    
    OCMVerifyAll(delegateMock);
    
    free((char**)cliArgs);
}

- (void)testReportsErrorWhenUnknownOptionEncountered {
    char* const*    cliArgs = [self createCommandlineArgumentsFromString: @"progname -files --unknown-option=true"];
    id              delegateMock = OCMProtocolMock(@protocol(CLIOptionParserDelegate));
    NSError*        error = nil;
    NSArray*        optionRequirements = @[ [CLIOption shortOptionWithName: @"f" canHaveArgument: NO thatIsRequired: NO aliases: nil],
                                            [CLIOption shortOptionWithName: @"i" canHaveArgument: NO thatIsRequired: NO aliases: nil] ];
    
    _optionParser = [[CLIOptionParser alloc] init];
    OCMExpect([delegateMock optionParserWillBeginParsing: _optionParser]);
    OCMExpect([delegateMock optionParserDidFinishParsing: _optionParser]);
    
    _optionParser.delegate = delegateMock;
    BOOL resultSucceeded = [_optionParser parseCommandLineArguments: cliArgs count: 3 optionsToRecognize: optionRequirements error: &error];
    XCTAssertFalse(resultSucceeded, @"parseCommandLineArguments:count:error: returned YES");
    XCTAssertNotNil(error, @"No error returned");
    XCTAssertEqualObjects(CLIKitErrorDomain, error.domain);
    XCTAssertEqual(kCLIMultipleErrors, error.code);
    XCTAssertNotNil(error.userInfo[CLIMultipleErrorsKey]);
    
    NSArray* multipleErrors = error.userInfo[CLIMultipleErrorsKey];
    
    XCTAssertEqual(4, [multipleErrors count]);
    [@[@"l", @"e", @"s", @"unknown-option"] enumerateObjectsUsingBlock: ^(NSString* unknownOptionName, NSUInteger index, BOOL *stop) {
        XCTAssertEqualObjects(CLIKitErrorDomain, [multipleErrors[index] domain]);
        XCTAssertEqual(kCLIUnknownOption, [multipleErrors[index] code]);
        XCTAssertEqualObjects(unknownOptionName, [multipleErrors[index] userInfo][CLIOptionNameKey]);
    }];
    
    OCMVerifyAll(delegateMock);
    
    free((char**)cliArgs);
}

- (void)testCanParseOptionsWithAliases {
    char* const*    cliArgs = [self createCommandlineArgumentsFromString: @"progname --file filename --log-level=debug"];
    id              delegateMock = OCMProtocolMock(@protocol(CLIOptionParserDelegate));
    NSError*        error = nil;
    NSArray*        optionRequirements = @[ [CLIOption shortOptionWithName: @"f" canHaveArgument: YES thatIsRequired: YES aliases: @[@"file"]],
                                            [CLIOption shortOptionWithName: @"l" canHaveArgument: YES thatIsRequired: NO aliases: @[@"log-level"]] ];
    
    _optionParser = [[CLIOptionParser alloc] init];
    OCMExpect([delegateMock optionParserWillBeginParsing: _optionParser]);
    OCMExpect([delegateMock optionParser: _optionParser didEncounterOptionWithName: @"file" argument: @"filename"]);
    OCMExpect([delegateMock optionParser: _optionParser didEncounterOptionWithName: @"log-level" argument: @"debug"]);
    OCMExpect([delegateMock optionParserDidFinishParsing: _optionParser]);
    
    _optionParser.delegate = delegateMock;
    BOOL resultSucceeded = [_optionParser parseCommandLineArguments: cliArgs count: 4 optionsToRecognize: optionRequirements error: &error];
    XCTAssertTrue(resultSucceeded, @"parseCommandLineArguments:count:error: returned NO");
    
    OCMVerifyAll(delegateMock);
    
    free((char**)cliArgs);
}

- (char* const*)createCommandlineArgumentsFromString: (NSString*)commandString {
    NSArray* parts = [commandString componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    NSUInteger argCount = [parts count];
    
    char** args = (char**)malloc(argCount * sizeof(char*));
    
    for (NSUInteger index = 0; index < argCount; index++) {
        NSLog(@"command line part: %@", parts[index]);
        args[index] = (char*)[parts[index] cStringUsingEncoding: NSASCIIStringEncoding];
    }
    
    return args;
}

@end
