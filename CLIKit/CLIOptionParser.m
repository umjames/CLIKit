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
#import "CLIErrorCollector.h"
#import "CLIOptionUtils.h"
#import <unistd.h>
#import <getopt.h>

NSString* const CLIKitErrorDomain = @"CLIKitErrorDomain";

NSString* const CLIOptionNameKey = @"CLIOptionNameKey";
NSString* const CLIMultipleErrorsKey = @"CLIMultipleErrorsKey";

@interface CLIOptionParser ()

@property (assign, nonatomic) BOOL                  parseSucceeded;
@property (strong, nonatomic) NSArray*              shortOptions;
@property (strong, nonatomic) NSArray*              longOptions;
@property (strong, nonatomic) CLIErrorCollector*    errorCollector;

@end

@implementation CLIOptionParser

@synthesize delegate, parseSucceeded, shortOptions, longOptions, errorCollector;

- (instancetype)init {
    if (self = [super init]) {
        delegate = nil;
        parseSucceeded = NO;
        shortOptions = nil;
        longOptions = nil;
        errorCollector = [[CLIErrorCollector alloc] init];
        return self;
    }
    
    return nil;
}

- (BOOL)parseCommandLineArguments: (char* const*)arguments
                            count: (unsigned int)argumentCount
               optionsToRecognize: (NSArray*)optionsToRecognize
                            error: (NSError**)err {
    
    self.parseSucceeded = YES;
    
    NSDictionary*   normalizedOptions = [CLIOptionUtils normalizeOptions: optionsToRecognize];
    
    self.shortOptions = [CLIArrayUtils objectsFromArray: normalizedOptions[CLIShortOptionsKey] passingTest: ^BOOL(CLIOption* option, NSUInteger index, BOOL *stop) {
        return option.isShortOption;
    }];
    
    self.longOptions = [CLIArrayUtils objectsFromArray: normalizedOptions[CLILongOptionsKey] passingTest: ^BOOL(CLIOption* option, NSUInteger index, BOOL *stop) {
        return !(option.isShortOption);
    }];
    
    if (nil != self.delegate && [self.delegate respondsToSelector: @selector(optionParserWillBeginParsing:)]) {
        [self.delegate optionParserWillBeginParsing: self];
    }
    
    const char* shortOptionString = [self generateShortOptionsString];
    struct option* longGetOptOptions = [self createLongOptionsArray];
    int longOptionIndex = -1;
    int found_option = 0;
    
    [self.errorCollector clearErrors];
    
    // disable printing default error messages
    opterr = 0;
    
    // reset optind global variable (needed to allow this to work more than once during execution of a program)
    optreset = 1;
    optind = 1;
    
#ifdef DEBUG
    for (unsigned int index = 0; index < argumentCount; index++) {
        NSLog(@"argument[%d] = %s", index, arguments[index]);
    }
    NSLog(@"Before processing getopt_long, argument count = %d, shortOptions = %s, first longOptions name = %s, longOptionIndex = %d", argumentCount, shortOptionString, longGetOptOptions[0].name, longOptionIndex);
#endif
    while ((found_option = getopt_long(argumentCount, arguments, shortOptionString, longGetOptOptions, &longOptionIndex)) != -1) {
#ifdef DEBUG
        NSLog(@"getopt_long found option %c", (char)found_option);
        NSLog(@"long option index for option: %d", longOptionIndex);
        NSLog(@"optopt = %d, (%c)", optopt, (char)optopt);
        NSLog(@"optind = %d", optind);
#endif
        switch (found_option) {
            case '?':
                [self processUnknownOptionInArguments: arguments count: argumentCount];
                break;
                
            case ':':
                if (![self processShortOptionWithOptionalArgumentMissing: optopt]) {
                    [self processMissingRequiredArgumentForOption: nil];
                }
                break;
                
            default:
                [self processOptionWithValue: found_option longOptionIndex: &longOptionIndex optionsToRecognize: optionsToRecognize];
                break;
        }
        
        // reset long option index so we can tell if next iteration finds a short option
        longOptionIndex = -1;
    }
    
#ifdef DEBUG
    NSLog(@"after while loop getopt_long found option %d", found_option);
    NSLog(@"after while loop getopt_long set optind to %d", optind);
#endif

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
    
    if (NULL != err) {
        *err = [self.errorCollector errorWrappingCollectedErrorsIfNecessary];
    }
    
    return self.parseSucceeded;
}

- (BOOL)processShortOptionWithOptionalArgumentMissing: (int)shortOptionEncountered {
    NSString*   shortOptionName = [NSString stringWithFormat: @"%c", shortOptionEncountered];
    CLIOption*  option = [CLIArrayUtils firstObjectFromArray: self.shortOptions passingTest: ^BOOL(CLIOption* optionObj, NSUInteger index, BOOL *stop) {
        if ([shortOptionName isEqualToString: optionObj.optionName]) {
            if (optionObj.canHaveArgument && !optionObj.isArgumentRequired) {
                return YES;
            }
        }
        
        return NO;
    }];
    
    if (nil == option) {
#ifdef DEBUG
        NSLog(@"Couldn't find short option '%c' that takes an optional argument", shortOptionEncountered);
#endif
        return NO;
    }
    
    if (nil != self.delegate) {
        [self.delegate optionParser: self didEncounterOptionWithName: shortOptionName argument: nil];
    }
    
    return YES;
}

- (void)processMissingRequiredArgumentForOption: (CLIOption*)option {
    NSError* error = [NSError errorWithDomain: CLIKitErrorDomain code: kCLIMissingRequiredArgument userInfo: @{ NSLocalizedDescriptionKey: [NSString stringWithFormat: @"option %@ is missing a required argument", option.optionName], CLIOptionNameKey: option.optionName }];
    
    [self.errorCollector addError: error];
    
    self.parseSucceeded = NO;
}



- (void)processUnknownOptionInArguments: (char* const*)arguments count: (unsigned int)argumentCount {
    NSString*   optionName = nil;
    
    if (0 == optopt) {
        if (optind > 0 && optind <= argumentCount) {
            optionName = [CLIStringUtils extractBareOptionNameFromString: [NSString stringWithCString: arguments[optind - 1] encoding: NSASCIIStringEncoding]];
        }
    }
    
    if (nil == optionName) {
        optionName = [NSString stringWithFormat: @"%c", (char)optopt];
    }
    
    NSError*    error = [NSError errorWithDomain: CLIKitErrorDomain code: kCLIUnknownOption userInfo: @{ NSLocalizedDescriptionKey: [NSString stringWithFormat: @"unknown option: %@", optionName], CLIOptionNameKey: optionName }];
    
    [self.errorCollector addError: error];
    
    self.parseSucceeded = NO;
}

- (void)processOptionWithValue: (int)optionValue longOptionIndex: (int*)longOptionIndex optionsToRecognize: (NSArray*)optionsToRecognize {
    if (nil == optionsToRecognize || [optionsToRecognize count] <= 0) {
#ifdef DEBUG
        NSLog(@"No option requirements to process option values with");
#endif
        return;
    }
    
    if (nil != self.delegate) {
        CLIOption* matchingOption = nil;
        NSString*   argumentValue = nil;
        
        if (NULL == longOptionIndex || -1 == *longOptionIndex || [self.longOptions count] <= 0) {
            NSUInteger shortOptionIndex = [self.shortOptions indexOfObjectPassingTest: ^BOOL(CLIOption* option, NSUInteger idx, BOOL *stop) {
                return ([option.optionName characterAtIndex: 0] == optionValue);
            }];
    
            if (NSNotFound == shortOptionIndex) {
#ifdef DEBUG
                NSLog(@"Could not find an option requirement with value '%c'", optionValue);
#endif
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
            [self processMissingRequiredArgumentForOption: matchingOption];
            return;
        }
        
#ifdef DEBUG
        NSLog(@"argument value for encountered option %@: %@", matchingOption.optionName, argumentValue);
#endif

        [self.delegate optionParser: self didEncounterOptionWithName: matchingOption.optionName argument: argumentValue];
    }
}

- (const char*)generateShortOptionsString {
    __block NSMutableString* shortOptionString = [[NSMutableString alloc] initWithString: @":"];
    
    [self.shortOptions enumerateObjectsUsingBlock:^(CLIOption* obj, NSUInteger idx, BOOL *stop) {
        if (![CLIStringUtils isBlank: obj.optionName]) {
            [shortOptionString appendString: [obj.optionName substringWithRange: NSMakeRange(0, 1)]];
            
            if (obj.canHaveArgument) {
                [shortOptionString appendString: @":"];
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
