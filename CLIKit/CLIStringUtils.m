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

@end
