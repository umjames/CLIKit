//
//  CLIOptionParser.h
//  CLIKit
//
//  Created by Michael James on 9/13/14.
//  Copyright (c) 2014 Michael James. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const CLIKitErrorDomain;

typedef enum {
    kMissingRequiredArgument = 1,
    kUnknownOption
} CLIKitErrorCode;

@class CLIOptionParser;

@protocol CLIOptionParserDelegate <NSObject>

@required

- (void)optionParser: (CLIOptionParser*)parser didEncounterOptionWithFlagName: (NSString*)optionFlag flagValue: (char)flagValue argument: (NSString*)optionArgument;
- (void)optionParser: (CLIOptionParser*)parser didEncounterNonOptionArguments: (NSArray*)remainingArguments;

@optional

- (void)optionParserWillBeginParsing: (CLIOptionParser*)parser;
- (void)optionParserDidFinishParsing: (CLIOptionParser*)parser;

@end

@interface CLIOptionParser : NSObject

@property (weak, nonatomic) id<CLIOptionParserDelegate> delegate;

- (instancetype)init;

- (BOOL)parseCommandLineArguments: (char* const*)arguments
                            count: (unsigned int)argumentCount
           withOptionRequirements: (NSArray*)optionRequirements
                            error: (NSError**)err;

@end

