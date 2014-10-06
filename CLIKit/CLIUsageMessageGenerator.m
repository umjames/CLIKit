//
//  CLIUsageMessageGenerator.m
//  CLIKit
//
//  Created by Michael James on 10/6/14.
//  Copyright (c) 2014 Maple Glen Software. All rights reserved.
//

#import "CLIUsageMessageGenerator.h"
#import "CLIOption.h"

@interface CLIUsageMessageGenerator ()

@property (strong, nonatomic) NSArray*              commandlineOptions;
@property (strong, nonatomic) NSMutableDictionary*  defaultOptionTextLengths;

@end

@implementation CLIUsageMessageGenerator

@synthesize commandlineOptions, delegate, defaultOptionTextLengths;

- (instancetype)initWithCommandLineOptions: (NSArray*)options {
    if (self = [super init]) {
        commandlineOptions = options;
        defaultOptionTextLengths = [NSMutableDictionary dictionaryWithCapacity: [options count]];
        [self calculateDefaultOptionTextLengths];
        return self;
    }
    
    return nil;
}

- (void)calculateDefaultOptionTextLengths {
    __block CLIUsageMessageGenerator*   blockSelf = self;
    
    [blockSelf.commandlineOptions enumerateObjectsUsingBlock: ^(CLIOption* option, NSUInteger idx, BOOL *stop) {
        blockSelf.defaultOptionTextLengths[option] = @([[blockSelf defaultOptionSectionTextForOption: option] length]);
    }];
}

- (NSString*)generateUsageMessage {
    __block NSMutableString*            usageMessage = [NSMutableString stringWithCapacity: 100];
    __block CLIUsageMessageGenerator*   blockSelf = self;
    
    if (nil != self.delegate && [self.delegate respondsToSelector: @selector(programDescriptionText)]) {
        [usageMessage appendFormat: @"%@\n\n", [self.delegate programDescriptionText]];
    }
    
    if (nil != self.delegate && [self.delegate respondsToSelector: @selector(programUsageExamples)]) {
        [usageMessage appendString: @"usage:\n"];
        
        NSArray* usageExamples = [self.delegate programUsageExamples];
        [usageExamples enumerateObjectsUsingBlock: ^(NSString* example, NSUInteger idx, BOOL *stop) {
            [usageMessage appendFormat: @"\t%@\n", example];
        }];
    }
    
    if ([self.commandlineOptions count] > 0) {
        [usageMessage appendString: @"\noptions:\n"];
        
        [self.commandlineOptions enumerateObjectsUsingBlock: ^(CLIOption* option, NSUInteger idx, BOOL *stop) {
            if (nil != blockSelf.delegate && [blockSelf.delegate respondsToSelector: @selector(usageTextForOption:)]) {
                NSString*   delegateOptionUsageText = [blockSelf.delegate usageTextForOption: option];
                
                if (nil != delegateOptionUsageText) {
                    [usageMessage appendFormat: @"\t%@\n", delegateOptionUsageText];
                } else {
                    [usageMessage appendFormat: @"\t%@\n", [blockSelf defaultUsageTextForOption: option]];
                }
            } else {
                [usageMessage appendFormat: @"\t%@\n", [blockSelf defaultUsageTextForOption: option]];
            }
        }];
    }
    
    [usageMessage appendString: @"\n"];
    
    return usageMessage;
}

- (NSString*)defaultUsageTextForOption: (CLIOption*)option {
    NSMutableString*    optionUsageText = [NSMutableString  stringWithCapacity: 30];
    
    int maxLength = [[[[self.defaultOptionTextLengths allValues] sortedArrayUsingComparator: ^NSComparisonResult(NSNumber* obj1, NSNumber* obj2) {
        return [obj1 compare: obj2];
    }] lastObject] intValue];
    
    NSString*   optionTextFormat = [NSString stringWithFormat: @"%%-%ds", maxLength];
    
    [optionUsageText appendFormat: @"\t%@\t%@", [NSString stringWithFormat: optionTextFormat, [[self defaultOptionSectionTextForOption: option] UTF8String]], option.usageDescription];
    
    return optionUsageText;
}

- (NSString*)defaultOptionSectionTextForOption: (CLIOption*)option {
    NSArray*     optionNames = [self formattedOptionNamesForOption: option];
    
    return [optionNames componentsJoinedByString: @", "];
}

- (NSArray*)formattedOptionNamesForOption: (CLIOption*)option {
    __block NSMutableArray* formattedOptionNames = [NSMutableArray arrayWithCapacity: 3];
    NSMutableArray* optionNames = [NSMutableArray arrayWithCapacity: 3];
    
    [optionNames addObject: option.optionName];
    [optionNames addObjectsFromArray: option.aliases];
    
    [optionNames enumerateObjectsUsingBlock: ^(NSString* optionName, NSUInteger idx, BOOL *stop) {
        NSMutableString* formatOptionString = [NSMutableString stringWithCapacity: 50];
        
        if ([optionName length] > 1) {
            [formatOptionString appendFormat: @"--%@", optionName];
            if (option.canHaveArgument) {
                [formatOptionString appendFormat: @"=%@", option.argumentNameForUsageDescription];
            }
        } else {
            [formatOptionString appendFormat: @"-%@", optionName];
            if (option.canHaveArgument) {
                [formatOptionString appendFormat: @" %@", option.argumentNameForUsageDescription];
            }
        }
        
        [formattedOptionNames addObject: formatOptionString];
    }];
    
    return formattedOptionNames;
}

@end
