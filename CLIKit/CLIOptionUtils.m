//
//  CLIOptionUtils.m
//  CLIKit
//
//  Created by Michael James on 10/8/14.
//  Copyright (c) 2014 Maple Glen Software. All rights reserved.
//

#import "CLIOptionUtils.h"
#import "CLIOption.h"

NSString* const CLIShortOptionsKey = @"CLIShortOptionsKey";
NSString* const CLILongOptionsKey = @"CLILongOptionsKey";

@implementation CLIOptionUtils

+ (NSDictionary*)normalizeOptions: (NSArray*)options {
    NSMutableDictionary*    normalizedOptions = [NSMutableDictionary dictionaryWithCapacity: 3];
    
    normalizedOptions[CLIShortOptionsKey] = [NSMutableArray arrayWithCapacity: 3];
    normalizedOptions[CLILongOptionsKey] = [NSMutableArray arrayWithCapacity: 3];
    
    for (id obj in options) {
        if ([obj isKindOfClass: [CLIOption class]]) {
            CLIOption* option = (CLIOption*)obj;
            
            if (option.isShortOption) {
                [normalizedOptions[CLIShortOptionsKey] addObject: [CLIOption shortOptionWithName: option.optionName canHaveArgument: option.canHaveArgument thatIsRequired: option.isArgumentRequired aliases: nil]];
            } else {
                [normalizedOptions[CLILongOptionsKey] addObject: [CLIOption longOptionWithName: option.optionName canHaveArgument: option.canHaveArgument thatIsRequired: option.isArgumentRequired aliases: nil]];
            }
            
            if (nil != option.aliases) {
                for (NSString* aliasName in option.aliases) {
                    if ([aliasName length] > 1) {
                        [normalizedOptions[CLILongOptionsKey] addObject: [CLIOption longOptionWithName: aliasName canHaveArgument: option.canHaveArgument thatIsRequired: option.isArgumentRequired aliases: nil]];
                    } else {
                        [normalizedOptions[CLIShortOptionsKey] addObject: [CLIOption shortOptionWithName: aliasName canHaveArgument: option.canHaveArgument thatIsRequired: option.isArgumentRequired aliases: nil]];
                    }
                }
            }

        }
    }
    
    return normalizedOptions;
}

@end
