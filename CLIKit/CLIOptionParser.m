//
//  CLIOptionParser.m
//  CLIKit
//
//  Created by Michael James on 9/13/14.
//  Copyright (c) 2014 Michael James. All rights reserved.
//

#import "CLIOptionParser.h"
#import "CLIOptionRequirement.h"
#import "CLIStringUtils.h"
#import <unistd.h>
#import <getopt.h>

NSString* const CLIKitErrorDomain = @"CLIKitErrorDomain";

@interface CLIOptionParser ()

@property (assign, nonatomic) BOOL parseSucceeded;

@end

@implementation CLIOptionParser

@synthesize delegate, parseSucceeded;

- (instancetype)init {
    if (self = [super init]) {
        delegate = nil;
        parseSucceeded = NO;
        return self;
    }
    
    return nil;
}

- (BOOL)parseCommandLineArguments: (char* const*)arguments
                            count: (unsigned int)argumentCount
           withOptionRequirements: (NSArray*)optionRequirements
                            error: (NSError**)err {
    
    self.parseSucceeded = YES;
    
    if (nil != self.delegate && [self.delegate respondsToSelector: @selector(optionParserWillBeginParsing:)]) {
        [self.delegate optionParserWillBeginParsing: self];
    }
    
    const char* shortOptions = [self generateShortOptionsStringFromRequirements: optionRequirements];
    struct option* longOptions = [self createLongOptionsArrayFromRequirements: optionRequirements];
    int longOptionIndex = 0;
    int found_option = 0;
    
    // disable printing default error messages
    opterr = 0;
    
    // reset optind global variable (needed to allow this to work more than once during execution of a program)
    optind = 1;
    
    for (unsigned int index = 0; index < argumentCount; index++) {
        NSLog(@"argument[%d] = %s", index, arguments[index]);
    }
    NSLog(@"Before processing getopt_long, argument count = %d, shortOptions = %s, first longOptions name = %s, longOptionIndex = %d", argumentCount, shortOptions, longOptions[0].name, longOptionIndex);
    while ((found_option = getopt_long(argumentCount, arguments, shortOptions, longOptions, &longOptionIndex)) != -1) {
        NSLog(@"getopt_long found option %c", (char)found_option);
        switch (found_option) {
            case '?':
                [self processUnknownOption: err];
                break;
                
            case ':':
                [self processMissingRequiredArgument: err];
                break;
                
            default:
                [self processOptionWithValue: found_option inOptionRequirements: optionRequirements error: err];
                break;
        }
    }
    
    NSLog(@"after while loop getopt_long found option %d", found_option);
    NSLog(@"after while loop getopt_long set optind to %d", optind);
    
    free(longOptions);
    
    if (self.parseSucceeded) {
        NSMutableArray* remainingArguments = [NSMutableArray arrayWithCapacity: 4];
        
        for (int index = optind; index < argumentCount; index++) {
            [remainingArguments addObject: [NSString stringWithCString: arguments[index] encoding: NSASCIIStringEncoding]];
        }
        
        if (nil != self.delegate && [remainingArguments count] > 0) {
            [self.delegate optionParser: self didEncounterNonOptionArguments: remainingArguments];
        }
    }
    
    if (nil != self.delegate && [self.delegate respondsToSelector: @selector(optionParserDidFinishParsing:)]) {
        [self.delegate optionParserDidFinishParsing: self];
    }
    
    return self.parseSucceeded;
}

- (void)processMissingRequiredArgument: (NSError**)error {
    if (NULL != error) {
        *error = [NSError errorWithDomain: CLIKitErrorDomain code: kMissingRequiredArgument userInfo: @{ NSLocalizedDescriptionKey: [NSString stringWithFormat: @"option %c is missing a required argument", (char)optopt] }];
    }
    self.parseSucceeded = NO;
}

- (void)processUnknownOption: (NSError**)error {
    if (NULL != error) {
        *error = [NSError errorWithDomain: CLIKitErrorDomain code: kUnknownOption userInfo: @{ NSLocalizedDescriptionKey: [NSString stringWithFormat: @"unknown option: %c", (char)optopt] }];
    }
    self.parseSucceeded = NO;
}

- (void)processOptionWithValue: (int)optionValue inOptionRequirements: (NSArray*)optionRequirements error: (NSError**)err {
    if (nil == optionRequirements || [optionRequirements count] <= 0) {
        NSLog(@"No option requirements to process option values with");
        return;
    }
    
    NSUInteger optionIndex = [optionRequirements indexOfObjectPassingTest: ^BOOL(CLIOptionRequirement* optionRequirement, NSUInteger idx, BOOL *stop) {
        return (optionValue == optionRequirement.valueIfOptionUsed);
    }];
    
    if (NSNotFound == optionIndex) {
        NSLog(@"Could not find an option requirement with value '%c'", optionValue);
        return;
    }
    
    if (nil != self.delegate) {
        CLIOptionRequirement* matchingOptionRequirement = optionRequirements[optionIndex];
        NSString*   argumentValue = nil;
        
        if (matchingOptionRequirement.canHaveArgument && NULL != optarg) {
            argumentValue = [NSString stringWithCString: optarg encoding: NSASCIIStringEncoding];
        }
        
        if ([@"--" isEqualToString: argumentValue]) {
            [self processMissingRequiredArgument: err];
            return;
        }
        
        NSLog(@"argument value for encountered option %@: %@", matchingOptionRequirement.optionName, argumentValue);
        
        [self.delegate optionParser: self didEncounterOptionWithFlagName: matchingOptionRequirement.optionName flagValue: (char)optionValue argument: argumentValue];
    }
}

- (const char*)generateShortOptionsStringFromRequirements: (NSArray*)optionRequirements {
    __block NSMutableString* shortOptionString = [[NSMutableString alloc] initWithCapacity: 6];
    
    NSIndexSet* shortOptionIndexes = [optionRequirements indexesOfObjectsPassingTest: ^BOOL(CLIOptionRequirement* obj, NSUInteger idx, BOOL* stop) {
        return (YES == obj.isShortOption);
    }];
    
    NSArray* shortOptions = [optionRequirements objectsAtIndexes: shortOptionIndexes];
    
    [shortOptions enumerateObjectsUsingBlock:^(CLIOptionRequirement* obj, NSUInteger idx, BOOL *stop) {
        if (![CLIStringUtils isBlank: obj.optionName]) {
            [shortOptionString appendString: [obj.optionName substringWithRange: NSMakeRange(0, 1)]];
            
            if (obj.canHaveArgument && obj.isArgumentRequired) {
                [shortOptionString appendString: @":"];
            } else if (obj.canHaveArgument && !obj.isArgumentRequired) {
                [shortOptionString appendString: @"::"];
            }
        }
    }];
    
    return [shortOptionString cStringUsingEncoding: NSASCIIStringEncoding];
}

- (struct option*)createLongOptionsArrayFromRequirements: (NSArray*)optionRequirements {
    NSIndexSet* longOptionIndexes = [optionRequirements indexesOfObjectsPassingTest: ^BOOL(CLIOptionRequirement* obj, NSUInteger idx, BOOL* stop) {
        return (NO == obj.isShortOption);
    }];
    
    NSArray* longOptionsRequirements = [optionRequirements objectsAtIndexes: longOptionIndexes];
    __block struct option* longOptions = (struct option*)malloc(([longOptionsRequirements count] + 1) * sizeof(struct option));
    
    [longOptionsRequirements enumerateObjectsUsingBlock: ^(CLIOptionRequirement* obj, NSUInteger idx, BOOL *stop) {
        if (![CLIStringUtils isBlank: obj.optionName]) {
            struct option longOption;
            
            longOption.name = [obj.optionName cStringUsingEncoding: NSASCIIStringEncoding];
            
            if (!obj.canHaveArgument) {
                longOption.has_arg = no_argument;
            } else if (obj.isArgumentRequired) {
                longOption.has_arg = required_argument;
            } else {
                longOption.has_arg = optional_argument;
            }
            
            longOption.flag = NULL;
            longOption.val = obj.valueIfOptionUsed;
            
            longOptions[idx] = longOption;
        }
    }];
    
    struct option terminator;
    
    terminator.name = NULL;
    terminator.has_arg = 0;
    terminator.flag = NULL;
    terminator.val = 0;
    
    longOptions[([longOptionsRequirements count])] = terminator;
    
    return longOptions;
}

@end
