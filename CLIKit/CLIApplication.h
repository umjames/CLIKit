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
 Delegate class for CLIApplication
 
 The delegate is used to provide the CLIApplication object the CLIOptions that will be used to parse command-line options when the application runs.
 
 It is also used to provide programs the opportunity to respond to the following events during the running of a CLIApplication object:
 
 - When a recognized CLIOption is encountered during parsing of the arguments supplied on the commandline.
 - When an error occurs during the parsing of command-line arguments.
 - After the command-line arguments have been successfully parsed and the application should now execute its functionality.
 - The events of the CLIUsageMessageGenerateDelegate during usage message generation
 */
@protocol CLIApplicationDelegate <CLIUsageMessageGeneratorDelegate>

@optional
/**
 *  Called before the application begins running (before parsing command-line arguments)
 *
 *  @param application the CLIApplication object that is about to start
 */
- (void)applicationWillBeginRunning: (CLIApplication*)application;

/**
 *  Called before the application finishes running (after the application has executed its functionality)
 *
 *  @param application the CLIApplication object that is about to end
 */
- (void)applicationWillEndRunning: (CLIApplication*)application;

@required
/**
 *  Called by a CLIApplication object to provide the CLIOptions the application should use for parsing command-line
 *  arguments and for usage message generation
 *
 *  @param application the CLIApplication object that needs CLIOptions
 *
 *  @return an array of CLIOption objects
 */
- (NSArray*)recognizedOptionsForApplication: (CLIApplication*)application;

/**
 *  Called while the CLIApplication object is parsing command-line arguments when it finds a recognized option
 *
 *  @param application    the CLIApplication object that encountered the option
 *  @param optionName     the name of the encountered option
 *  @param optionArgument the option's argument (if any)
 */
- (void)application: (CLIApplication*)application didEncounterOptionWithName: (NSString*)optionName argument: (NSString*)optionArgument;

/**
 *  Called after the CLIApplication has finished parsing command-line options and is ready to execute its functionality
 *
 *  @param application the CLIApplication object that is about to start executing
 *  @param arguments   an array of NSStrings representing each remaining command-line argument (if any) after parsing options
 */
- (void)application: (CLIApplication*)application isReadyToBeginExecutingWithRemainingArguments: (NSArray*)arguments;

/**
 *  Called when an error occurs during command-line option parsing
 *
 *  @param application the CLIApplication object that produced the error
 *  @param error       the NSError produced during command-line option parsing
 */
- (void)application: (CLIApplication*)application didFailOptionParsingWithError: (NSError*)error;

@end

/**
 *  A convenience object that encapsulates command-line option parsing and usage message generation
 *
 *  It uses a delegate object (CLIApplicationDelegate) to respond to the events encountered during option-parsing, 
 *  usage message generation and error reporting.
 */
@interface CLIApplication : NSObject

/** @name Properties */

/**
 *  The application's delegate
 */
@property (weak, nonatomic) id <CLIApplicationDelegate> delegate;

/**
 *  The application's exit code (0 for success, non-zero for failure) to be set after executing the application's functionality
 */
@property (assign, nonatomic) int                       exitCode;

/**
 *  A file handle to the Unix standard input file descriptor
 */
@property (readonly, nonatomic) NSFileHandle*           standardInput;

/**
 *  A file handle to the Unix standard output file descriptor
 */
@property (readonly, nonatomic) NSFileHandle*           standardOutput;

/**
 *  A file handle to the Unix standard error file descriptor
 */
@property (readonly, nonatomic) NSFileHandle*           standardError;

/** @name Methods */

/**
 *  Standard initializer
 *
 *  @return an initialized instance
 */
- (instancetype)init;

/**
 *  Run the application (parse its arguments and execute its functionality)
 *
 *  @param argsFromMain  the arguments passed into the application's main() function
 *  @param argumentCount the number of arguments (also passed into the application's main() function)
 */
- (void)runWithCommandlineArguments: (char* const*)argsFromMain count: (int)argumentCount;

/**
 *  Generate a usage message.
 *
 *  It uses the delegate's CLIUsageMessageGeneratorDelegate methods to customize the message
 *
 *  @return the generated usage message
 */
- (NSString*)generateUsageMessage;

/**
 * Writes the usage message returned by `generateUsageMessage` to stderr.
 */
- (void)writeUseageMessage;

/**
 * Writes the localized description from the given error to stderr.
 *
 * @param error The error whose localized description to write to standard error.
 */
- (void)writeError:(NSError *)error;

/**
 * Write a given string to stderr.
 *
 * @param string The string to write to standard error.
 */
- (void)writeStdErrorString:(NSString *)string;

/**
 * Write a given string to stdout.
 *
 * @param string The string to write to standard out.
 */
- (void)writeStdOutString:(NSString *)string;

@end

/**
 *  Convenience function that will instantiate a CLIApplication object, 
 *  instantiate an object of the specified delegate class and assign it to the application object,
 *  and then run that application with the provided command-line arguments,
 *  and finally return the application's exitCode.
 *
 *  This function should be wrapped in an autorelease pool if used in the main() function.
 *
 *  @param delegateClassName the name of the delegate's class to instantiate
 *  @param argv the command-line arguments as provided in the application's main method
 *  @param argc the number of command-line arguments in argv.
 *
 *  @return the exit code value of the internally created CLIApplication object
 */
int CLIApplicationMain(NSString* delegateClassName, char* const* argv, int argc);