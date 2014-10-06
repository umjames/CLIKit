//
//  CLIOptionRequirement.m
//  CLIKit
//
//  Created by Michael James on 9/20/14.
//  Copyright (c) 2014 Maple Glen Software. All rights reserved.
//

#import "CLIOption.h"
#import "CLIStringUtils.h"

@interface CLIOption ()

@property (assign, readwrite, nonatomic) BOOL      isShortOption;
@property (assign, readwrite, nonatomic) BOOL      canHaveArgument;
@property (assign, readwrite, nonatomic) BOOL      isArgumentRequired;
@property (copy, readwrite, nonatomic) NSString*   optionName;
@property (strong, readwrite, nonatomic) NSArray*  aliases;
@property (copy, readwrite, nonatomic) NSString*   usageDescription;
@property (copy, readwrite, nonatomic) NSString*   argumentNameForUsageDescription;

@end

@implementation CLIOption

@synthesize canHaveArgument, isArgumentRequired, isShortOption, optionName, aliases, usageDescription, argumentNameForUsageDescription;

- (instancetype)init {
    if (self = [super init]) {
        optionName = nil;
        canHaveArgument = NO;
        isArgumentRequired = NO;
        isShortOption = NO;
        aliases = nil;
        usageDescription = nil;
        argumentNameForUsageDescription = nil;
        
        return self;
    }
    
    return nil;
}

- (id)copyWithZone: (NSZone*)zone {
    CLIOption* copy = [[CLIOption alloc] init];
    
    copy.optionName = self.optionName;
    copy.canHaveArgument = self.canHaveArgument;
    copy.isArgumentRequired = self.isArgumentRequired;
    copy.isShortOption = self.isShortOption;
    copy.aliases = self.aliases;
    copy.usageDescription = self.usageDescription;
    copy.argumentNameForUsageDescription = self.argumentNameForUsageDescription;
    
    return copy;
}

+ (instancetype)shortOptionWithName: (NSString*)optionName
                    canHaveArgument: (BOOL)canHaveArg
                     thatIsRequired: (BOOL)argIsRequired
                            aliases: (NSArray*)aliases
                   usageDescription: (NSString*)usageDesc
       usageDescriptionArgumentName: (NSString*)usageDescArgName {
    if ([CLIStringUtils isBlank: optionName]) {
        return nil;
    }
    
    unichar firstChar = [optionName characterAtIndex: 0];
    
    CLIOption*   option = [[CLIOption alloc] init];
    
    option.optionName = [NSString stringWithCharacters: &firstChar length: 1];
    option.isShortOption = YES;
    option.canHaveArgument = canHaveArg;
    option.isArgumentRequired = argIsRequired;
    option.aliases = aliases;
    option.usageDescription = usageDesc;
    option.argumentNameForUsageDescription = usageDescArgName;
    
    return option;
}

+ (instancetype)shortOptionWithName: (NSString*)optionName
                    canHaveArgument: (BOOL)canHaveArg
                     thatIsRequired: (BOOL)argIsRequired
                            aliases: (NSArray*)aliases {
    return [self shortOptionWithName: optionName
                     canHaveArgument: canHaveArg
                      thatIsRequired: argIsRequired
                             aliases: aliases
                    usageDescription: nil
        usageDescriptionArgumentName: nil];
}

+ (instancetype)longOptionWithName: (NSString*)optionName
                   canHaveArgument: (BOOL)canHaveArg
                    thatIsRequired: (BOOL)argIsRequired
                           aliases: (NSArray*)aliases {
    return [self longOptionWithName: optionName
                    canHaveArgument: canHaveArg
                     thatIsRequired: argIsRequired
                            aliases: aliases
                   usageDescription: nil
       usageDescriptionArgumentName: nil];
}

+ (instancetype)longOptionWithName: (NSString*)optionName
                   canHaveArgument: (BOOL)canHaveArg
                    thatIsRequired: (BOOL)argIsRequired
                           aliases: (NSArray*)aliases
                  usageDescription: (NSString*)usageDesc
      usageDescriptionArgumentName: (NSString*)usageDescArgName {
    if ([CLIStringUtils isBlank: optionName]) {
        return nil;
    }
    
    CLIOption*   option = [[CLIOption alloc] init];
    
    option.optionName = optionName;
    option.isShortOption = NO;
    option.canHaveArgument = canHaveArg;
    option.isArgumentRequired = argIsRequired;
    option.aliases = aliases;
    option.usageDescription = usageDesc;
    option.argumentNameForUsageDescription = usageDescArgName;
    
    return option;
}

@end
