//
//  CLIOptionUtilsTest.m
//  CLIKit
//
//  Created by Michael James on 10/8/14.
//  Copyright (c) 2014 Maple Glen Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "CLIOptionUtils.h"
#import "CLIOption.h"

@interface CLIOptionUtilsTest : XCTestCase

@end

@implementation CLIOptionUtilsTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCanNormalizeOptionsWithAliases {
    NSArray*    options = @[ [CLIOption shortOptionWithName: @"f" canHaveArgument: YES thatIsRequired: YES aliases: @[@"filename", @"file"]],
                             [CLIOption longOptionWithName: @"version" canHaveArgument: NO thatIsRequired: NO aliases: @[@"v", @"V"]] ];
    
    NSDictionary* normalizedOptions = [CLIOptionUtils normalizeOptions: options];
    
    XCTAssertNotNil(normalizedOptions);
    XCTAssertEqual(2, [normalizedOptions count]);
    
    NSArray* longOptions = normalizedOptions[CLILongOptionsKey];
    NSMutableSet* longOptionNames = [NSMutableSet setWithArray: @[@"filename", @"version", @"file"]];
    
    XCTAssertNotNil(longOptions);
    XCTAssertEqual(3, [longOptions count]);
    [longOptions enumerateObjectsUsingBlock: ^(CLIOption* option, NSUInteger index, BOOL *stop) {
        XCTAssertTrue([longOptionNames containsObject: option.optionName]);
        XCTAssertFalse(option.isShortOption);
        NSString* matchingOptionName = [longOptionNames member: option.optionName];
        [longOptionNames removeObject: matchingOptionName];
        
        if ([@"version" isEqualToString: matchingOptionName]) {
            XCTAssertFalse(option.canHaveArgument);
            XCTAssertFalse(option.isArgumentRequired);
        } else if ([@"filename" isEqualToString: matchingOptionName]) {
            XCTAssertTrue(option.canHaveArgument);
            XCTAssertTrue(option.isArgumentRequired);
        }
        
        XCTAssertNil(option.aliases);
    }];
    
    NSArray* shortOptions = normalizedOptions[CLIShortOptionsKey];
    NSMutableSet* shortOptionNames = [NSMutableSet setWithArray: @[@"f", @"v", @"V"]];
    
    XCTAssertNotNil(shortOptions);
    XCTAssertEqual(3, [shortOptions count]);
    [shortOptions enumerateObjectsUsingBlock: ^(CLIOption* option, NSUInteger index, BOOL *stop) {
        XCTAssertTrue([shortOptionNames containsObject: option.optionName]);
        XCTAssertTrue(option.isShortOption);
        NSString* matchingOptionName = [shortOptionNames member: option.optionName];
        [shortOptionNames removeObject: matchingOptionName];
        
        if ([@"v" isEqualToString: matchingOptionName]) {
            XCTAssertFalse(option.canHaveArgument);
            XCTAssertFalse(option.isArgumentRequired);
        } else if ([@"f" isEqualToString: matchingOptionName]) {
            XCTAssertTrue(option.canHaveArgument);
            XCTAssertTrue(option.isArgumentRequired);
        }
        
        XCTAssertNil(option.aliases);
    }];
}

@end
