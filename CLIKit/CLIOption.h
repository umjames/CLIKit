                                                                                                                                                                                                                                                                                               //
//  CLIOption.h
//  CLIKit
//
//  Created by Michael James on 9/20/14.
//  Copyright (c) 2014 Maple Glen Software. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 CLIOption encapsulates the attributes of a command-line option
 
 You pass an array of these objects to CLIOptionParser's parsing method to indicate which options it should parse
 */
@interface CLIOption : NSObject <NSCopying>

/** @name Properties */

/** Is the option short (eg. -v) or long (eg. --version)? */
@property (assign, readonly, nonatomic) BOOL      isShortOption;

/** Can this option take an argument? */
@property (assign, readonly, nonatomic) BOOL      canHaveArgument;

/** If the option can take an argument, is that argument required? */
@property (assign, readonly, nonatomic) BOOL      isArgumentRequired;

/** The name of the option (will be the first letter of this value if this is a short option, the entire string is this is a long option) */
@property (copy, readonly, nonatomic) NSString*   optionName;

/** An array of strings that are alternative names for this option */
@property (strong, readonly, nonatomic) NSArray*  aliases;

/**
 *  A short description of what the option does (used in usage message generation)
 */
@property (copy, readonly, nonatomic) NSString*   usageDescription;

/**
 *  The name used for the option's argument (if one exists) in generated usage messages
 */
@property (copy, readonly, nonatomic) NSString*   argumentNameForUsageDescription;

/** @name Convenience creation methods */

/**
 Create an instance for a short option
 
 @param optionName Name of option (without the '-')
 @param canHaveArg YES if option can have an argument associated with it, NO otherwise
 @param argIsRequired YES is this option's argument is required, NO if it is optional
 @param aliases An array of strings that serve as alternative names for this option
 
 @return A configured CLIOption instance
 */
+ (instancetype)shortOptionWithName: (NSString*)optionName
                    canHaveArgument: (BOOL)canHaveArg
                     thatIsRequired: (BOOL)argIsRequired
                            aliases: (NSArray*)aliases;

/**
 *  Create an instance for a short option with data for usage message generation
 *
 *  @param optionName       Name of option (without the '-')
 *  @param canHaveArg       YES if option can have an argument associated with it, NO otherwise
 *  @param argIsRequired    YES is this option's argument is required, NO if it is optional
 *  @param aliases          An array of strings that serve as alternative names for this option
 *  @param usageDesc        A short string describing the option's purpose (used in usage message generation)
 *  @param usageDescArgName The name to use for option's argument (if any) in usage message generation
 *
 *  @return A configured CLIOption instance
 */
+ (instancetype)shortOptionWithName: (NSString*)optionName
                    canHaveArgument: (BOOL)canHaveArg
                     thatIsRequired: (BOOL)argIsRequired
                            aliases: (NSArray*)aliases
                   usageDescription: (NSString*)usageDesc
       usageDescriptionArgumentName: (NSString*)usageDescArgName;

/**
 Create an instance for a long option
 
 @param optionName Name of option (without the '--')
 @param canHaveArg YES if option can have an argument associated with it, NO otherwise
 @param argIsRequired YES is this option's argument is required, NO if it is optional
 @param aliases An array of strings that serve as alternative names for this option
 
 @return A configured CLIOption instance
 */
+ (instancetype)longOptionWithName: (NSString*)optionName
                   canHaveArgument: (BOOL)canHaveArg
                    thatIsRequired: (BOOL)argIsRequired
                           aliases: (NSArray*)aliases;

/**
 *  Create an instance for a long option with data for usage message generation
 *
 *  @param optionName       Name of option (without the '--')
 *  @param canHaveArg       YES if option can have an argument associated with it, NO otherwise
 *  @param argIsRequired    YES is this option's argument is required, NO if it is optional
 *  @param aliases          An array of strings that serve as alternative names for this option
 *  @param usageDesc        A short string describing the option's purpose (used in usage message generation)
 *  @param usageDescArgName The name to use for option's argument (if any) in usage message generation
 *
 *  @return A configured CLIOption instance
 */
+ (instancetype)longOptionWithName: (NSString*)optionName
                   canHaveArgument: (BOOL)canHaveArg
                    thatIsRequired: (BOOL)argIsRequired
                           aliases: (NSArray*)aliases
                  usageDescription: (NSString*)usageDesc
      usageDescriptionArgumentName: (NSString*)usageDescArgName;

@end
