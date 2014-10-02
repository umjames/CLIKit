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
@interface CLIOption : NSObject

/** @name Properties */

/** Is the option short (eg. -v) or long (eg. --version)? */
@property (assign, readonly, nonatomic) BOOL      isShortOption;

/** Can this option take an argument? */
@property (assign, readonly, nonatomic) BOOL      canHaveArgument;

/** If the option can take an argument, is that argument required? */
@property (assign, readonly, nonatomic) BOOL      isArgumentRequired;

/** The name of the option (will be the first letter of this value if this is a short option, the entire string is this is a long option) */
@property (copy, readonly, nonatomic) NSString*   optionName;

/** @name Convenience creation methods */

/**
 Create an instance for a short option
 
 @param optionName Name of option (without the '-')
 @param canHaveArg YES if option can have an argument associated with it, NO otherwise
 @param argIsRequired YES is this option's argument is required, NO if it is optional
 
 @return A configured CLIOption instance
 */
+ (instancetype)shortOptionWithName: (NSString*)optionName
                    canHaveArgument: (BOOL)canHaveArg
                     thatIsRequired: (BOOL)argIsRequired;

/**
 Create an instance for a long option
 
 @param optionName Name of option (without the '--')
 @param canHaveArg YES if option can have an argument associated with it, NO otherwise
 @param argIsRequired YES is this option's argument is required, NO if it is optional
 
 @return A configured CLIOption instance
 */
+ (instancetype)longOptionWithName: (NSString*)optionName
                   canHaveArgument: (BOOL)canHaveArg
                    thatIsRequired: (BOOL)argIsRequired;

@end
