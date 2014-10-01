//
//  CLIOptionParser.m
//  CLIKit
//
//  Created by Michael James on 9/13/14.
//  Copyright (c) 2014 Michael James. All rights reserved.
//

#import "CLIOptionParser.h"
#import "CLIOption.h"
#import "CLIStringUtils.h"
#import "CLIArrayUtils.h"
#import <unistd.h>
#import <getopt.h>

NSString* const CLIKitErrorDomain = @"CLIKitErrorDomain";

@interface CLIOptionParser ()

@property (assign, nonatomic) BOOL parseSucceeded;
@property (strong, nonatomic) NSArray*  shortOptions;
@property (strong, nonatomic) NSArray*  longOptions;

@end

@implementation CLIOptionParser

@synthesize delegate, parseSucceeded, shortOptions, longOptions;

- (instancetype)init {
    if (self = [super init]) {
        delegate = nil;
        parseSucceeded = NO;
        shortOptions = nil;
        longOptions = nil;
        return self;
    }
    
    return nil;
}

- (BOOL)parseCommandLineArguments: (char* const*)arguments
                            count: (unsigned int)argumentCount
               optionsToRecognize: (NSArray*)optionsToRecognize
                            error: (NSError**)err {
    
    self.parseSucceeded = YES;
    
    self.shortOptions = [CLIArrayUtils objectsFromArray: optionsToRecognize passingTest: ^BOOL(CLIOption* option, NSUInteger index, BOOL *stop) {
        return option.isShortOption;
    }];
    
    self.longOptions = [CLIArrayUtils objectsFromArray: optionsToRecognize passingTest: ^BOOL(CLIOption* option, NSUInteger index, BOOL *stop) {
        return !(option.isShortOption);
    }];
    
    if (nil != self.delegate && [self.delegate respondsToSelector: @selector(optionParserWillBeginParsing:)]) {
        [self.delegate optionParserWillBeginParsing: self];
    }
    
    const char* shortOptionString = [self generateShortOptionsString];
    struct option* longGetOptOptions = [self createLongOptionsArray];
    int longOptionIndex = 0;
    int found_option = 0;
    
    // disable printing default error messages
    opterr = 0;
    
    // reset optind global variable (needed to allow this to work more than once during execution of a program)
    optind = 1;
    
    for (unsigned int index = 0; index < argumentCount; index++) {
        NSLog(@"argument[%d] = %s", index, arguments[index]);
    }
    NSLog(@"Before processing getopt_long, argument count = %d, shortOptions = %s, first longOptions name = %s, longOptionIndex = %d", argumentCount, shortOptionString, longGetOptOptions[0].name, longOptionIndex);
    while ((found_option = getopt_long(argumentCount, arguments, shortOptionString, longGetOptOptions, &longOptionIndex)) != -1) {
        NSLog(@"getopt_long found option %c", (char)found_option);
        switch (found_option) {
            case '?':
                [self processUnknownOption: err];
                break;
                
            case ':':
                [self processMissingRequiredArgument: err];
                break;
                
            default:
                [self processOptionWithValue: found_option longOptionIndex: &longOptionIndex optionsToRecognize: optionsToRecognize error: err];
                break;
        }
    }
    
    NSLog(@"after while loop getopt_long found option %d", found_option);
    NSLog(@"after while loop getopt_long set optind to %d", optind);
    
    free(longGetOptOptions);
    
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

- (void)processOptionWithValue: (int)optionValue longOptionIndex: (int*)longOptionIndex optionsToRecognize: (NSArray*)optionsToRecognize error: (NSError**)err {
    if (nil == optionsToRecognize || [optionsToRecognize count] <= 0) {
        NSLog(@"No option requirements to process option values with");
        return;
    }
    
    if (nil != self.delegate) {
        CLIOption* matchingOption = nil;
        NSString*   argumentValue = nil;
        
        if (NULL == longOptionIndex || [self.longOptions count] <= 0) {
            NSUInteger shortOptionIndex = [self.shortOptions indexOfObjectPassingTest: ^BOOL(CLIOption* option, NSUInteger idx, BOOL *stop) {
                return ([option.optionName characterAtIndex: 0] == optionValue);
            }];
    
            if (NSNotFound == shortOptionIndex) {
                NSLog(@"Could not find an option requirement with value '%c'", optionValue);
                return;
            }

            matchingOption = self.shortOptions[shortOptionIndex];
        } else {
            matchingOption = self.longOptions[*longOptionIndex];
        }
        
        if (matchingOption.canHaveArgument && NULL != optarg) {
            argumentValue = [NSString stringWithCString: optarg encoding: NSASCIIStringEncoding];
        }
        
        if ([@"--" isEqualToString: argumentValue]) {
            [self processMissingRequiredArgument: err];
            return;
        }
        
        NSLog(@"argument value for encountered option %@: %@", matchingOption.optionName, argumentValue);
        
        [self.delegate optionParser: self didEncounterOptionWithName: matchingOption.optionName argument: argumentValue];
    }
}

- (const char*)generateShortOptionsString {
    __block NSMutableString* shortOptionString = [[NSMutableString alloc] initWithCapacity: 6];
    
    [self.shortOptions enumerateObjectsUsingBlock:^(CLIOption* obj, NSUInteger idx, BOOL *stop) {
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

- (struct option*)createLongOptionsArray {
    __block struct option* longGetOptOptions = (struct option*)malloc(([self.longOptions count] + 1) * sizeof(struct option));
    
    [self.longOptions enumerateObjectsUsingBlock: ^(CLIOption* obj, NSUInteger idx, BOOL *stop) {
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
            longOption.val = 0;
            
            longGetOptOptions[idx] = longOption;
        }
    }];
    
    struct option terminator;
    
    terminator.name = NULL;
    terminator.has_arg = 0;
    terminator.flag = NULL;
    terminator.val = 0;
    
    longGetOptOptions[([self.longOptions count])] = terminator;
    
    return longGetOptOptions;
}

@end
