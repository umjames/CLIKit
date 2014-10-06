//
//  CLIUsageMessageGenerator.h
//  CLIKit
//
//  Created by Michael James on 10/6/14.
//  Copyright (c) 2014 Maple Glen Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLIOption;

/**
 * Delegate used by CLIUsageMessageGenerator to generate the text for different sections of the usage message
 */
@protocol CLIUsageMessageGeneratorDelegate <NSObject>

@required

/**
 *  Generate an array of strings that represent the different usage examples for this program
 *
 *  @return an array of strings, one per usage example
 */
- (NSArray*)programUsageExamples;

@optional

/**
 *  Generate the text used in the overall description of the application's functionality.
 *  This text occurs before the usage examples and options section
 *
 *  @return The text for the command-line program's overall functionality
 */
- (NSString*)programDescriptionText;

/**
 *  Generate the usage text for a specific option in the options section of the usage message
 *
 *  @param option The CLIOption whose usage text is being generated
 *
 *  @return The usage text to use for the option argument (or nil for the default usage text for the option)
 */
- (NSString*)usageTextForOption: (CLIOption*)option;

@end


/**
 Class used to generate usage text for command-line applications
 */
@interface CLIUsageMessageGenerator : NSObject

/** @name Properties */

/**
 *  Delegate used to supply different sections of the ussage message
 */
@property (weak, nonatomic) id<CLIUsageMessageGeneratorDelegate>    delegate;

/** @name Initialization */

/**
 *  Create
 *
 *  @param options An array of CLIOption objects to be used in the options section of the usage message generation
 *
 *  @return A new instance of this class
 */
- (instancetype)initWithCommandLineOptions: (NSArray*)options;

/** @name Usage message generation */

/**
 *  Generate a usage message.
 *
 *  @return The usage message
 */
- (NSString*)generateUsageMessage;

@end
