//
//  CLIStringUtils.m
//  CLIKit
//
//  Created by Michael James on 9/22/14.
//  Copyright (c) 2014 Maple Glen Software. All rights reserved.
//

#import "CLIStringUtils.h"

@implementation CLIStringUtils

+ (BOOL)isBlank: (NSString*)str {
    return (nil == str || [[str stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] length] <= 0);
}

+ (NSString*)extractBareOptionNameFromString: (NSString*)str {
    NSError*    err = nil;
    NSString*   optionNamePattern = @"^-{0,2}([^=\\s]+)";
    NSRegularExpression*    regex = [NSRegularExpression regularExpressionWithPattern: optionNamePattern options: 0 error: &err];
    
    if (nil != err) {
        NSLog(@"error creating regular expression with pattern \"%@\": %@", optionNamePattern, err);
        return str;
    }
    
    NSTextCheckingResult*   firstMatch = [regex firstMatchInString: str options: 0 range: NSMakeRange(0, [str length])];
    
    if (nil == firstMatch || NSEqualRanges(firstMatch.range, NSMakeRange(NSNotFound, 0))) {
        NSLog(@"cannot extract option name: %@ does not match regular expression: %@", str, regex.pattern);
        return str;
    }
    
    return [str substringWithRange: [firstMatch rangeAtIndex: 1]];
}

@end
