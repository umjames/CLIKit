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

@end

@implementation CLIOption

@synthesize canHaveArgument, isArgumentRequired, isShortOption, optionName;

- (instancetype)init {
    if (self = [super init]) {
        optionName = nil;
        canHaveArgument = NO;
        isArgumentRequired = NO;
        isShortOption = NO;
        
        return self;
    }
    
    return nil;
}

+ (instancetype)shortOptionWithName: (NSString*)optionName canHaveArgument: (BOOL)canHaveArg thatIsRequired: (BOOL)argIsRequired {
    if ([CLIStringUtils isBlank: optionName]) {
        return nil;
    }
    
    unichar firstChar = [optionName characterAtIndex: 0];
    
    CLIOption*   optionRequirement = [[CLIOption alloc] init];
    
    optionRequirement.optionName = [NSString stringWithCharacters: &firstChar length: 1];
    optionRequirement.isShortOption = YES;
    optionRequirement.canHaveArgument = canHaveArg;
    optionRequirement.isArgumentRequired = argIsRequired;
    
    return optionRequirement;
}

+ (instancetype)longOptionWithName: (NSString*)optionName
                   canHaveArgument: (BOOL)canHaveArg
                    thatIsRequired: (BOOL)argIsRequired {
    if ([CLIStringUtils isBlank: optionName]) {
        return nil;
    }
    
    CLIOption*   optionRequirement = [[CLIOption alloc] init];
    
    optionRequirement.optionName = optionName;
    optionRequirement.isShortOption = NO;
    optionRequirement.canHaveArgument = canHaveArg;
    optionRequirement.isArgumentRequired = argIsRequired;
    
    return optionRequirement;
}

@end
