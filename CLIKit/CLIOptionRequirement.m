//
//  CLIOptionRequirement.m
//  CLIKit
//
//  Created by Michael James on 9/20/14.
//  Copyright (c) 2014 Maple Glen Software. All rights reserved.
//

#import "CLIOptionRequirement.h"
#import "CLIStringUtils.h"

@interface CLIOptionRequirement ()

@property (assign, readwrite, nonatomic) BOOL      isShortOption;
@property (assign, readwrite, nonatomic) BOOL      canHaveArgument;
@property (assign, readwrite, nonatomic) BOOL      isArgumentRequired;
@property (copy, readwrite, nonatomic) NSString*   optionName;
@property (assign, readwrite, nonatomic) char      valueIfOptionUsed;

@end

@implementation CLIOptionRequirement

@synthesize canHaveArgument, isArgumentRequired, isShortOption, optionName, valueIfOptionUsed;

- (instancetype)init {
    if (self = [super init]) {
        optionName = nil;
        canHaveArgument = NO;
        isArgumentRequired = NO;
        isShortOption = NO;
        valueIfOptionUsed = '0';
        
        return self;
    }
    
    return nil;
}

+ (instancetype)optionRequirementForShortOption: (NSString*)optionName canHaveArgument: (BOOL)canHaveArg thatIsRequired: (BOOL)argIsRequired {
    if ([CLIStringUtils isBlank: optionName]) {
        return nil;
    }
    
    unichar firstChar = [optionName characterAtIndex: 0];
    
    CLIOptionRequirement*   optionRequirement = [[CLIOptionRequirement alloc] init];
    
    optionRequirement.optionName = [NSString stringWithCharacters: &firstChar length: 1];
    optionRequirement.isShortOption = YES;
    optionRequirement.canHaveArgument = canHaveArg;
    optionRequirement.isArgumentRequired = argIsRequired;
    optionRequirement.valueIfOptionUsed = firstChar;
    
    return optionRequirement;
}

+ (instancetype)optionRequirementForLongOption: (NSString*)optionName
                               canHaveArgument: (BOOL)canHaveArg
                                thatIsRequired: (BOOL)argIsRequired
                             valueIfOptionUsed: (char)valueIfUsed {
    if ([CLIStringUtils isBlank: optionName]) {
        return nil;
    }
    
    CLIOptionRequirement*   optionRequirement = [[CLIOptionRequirement alloc] init];
    
    optionRequirement.optionName = optionName;
    optionRequirement.isShortOption = NO;
    optionRequirement.canHaveArgument = canHaveArg;
    optionRequirement.isArgumentRequired = argIsRequired;
    optionRequirement.valueIfOptionUsed = valueIfUsed;
    
    return optionRequirement;
}

@end
