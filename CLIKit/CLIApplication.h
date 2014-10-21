//
//  CLIApplication.h
//  CLIKit
//
//  Created by Michael James on 10/14/14.
//  Copyright (c) 2014 Maple Glen Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLIOptionParser.h"
#import "CLIUsageMessageGenerator.h"

@class CLIApplication;

/**
 *  
 */
@protocol CLIApplicationDelegate <CLIUsageMessageGeneratorDelegate>

@optional
- (void)applicationWillBeginRunning: (CLIApplication*)application;
- (void)applicationWillEndRunning: (CLIApplication*)application;

@required
- (NSArray*)recognizedOptionsForApplication: (CLIApplication*)application;
- (void)application: (CLIApplication*)application didEncounterOptionWithName: (NSString*)optionName argument: (NSString*)optionArgument;

- (void)application: (CLIApplication*)application isReadyToBeginExecutingWithRemainingArguments: (NSArray*)arguments;
- (void)application: (CLIApplication*)application didFailOptionParsingWithError: (NSError*)error;

@end

@interface CLIApplication : NSObject

@property (weak, nonatomic) id <CLIApplicationDelegate> delegate;

@property (assign, nonatomic) int                       exitCode;

- (instancetype)init;

- (void)runWithCommandlineArguments: (char* const*)argsFromMain count: (int)argumentCount;

- (NSString*)generateUsageMessage;

@end

/**
 *
 */
int CLIApplicationMain(NSString* delegateClassName, char* const* argv, int argc);