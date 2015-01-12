//
//  CLIApplication.m
//  CLIKit
//
//  Created by Michael James on 10/14/14.
//  Copyright (c) 2014 Maple Glen Software. All rights reserved.
//

#import "CLIApplication.h"
#import "CLIOptionParser.h"
#import "CLIUsageMessageGenerator.h"

@interface CLIApplicationOptionParserDelegate : NSObject <CLIOptionParserDelegate>

@property (weak, readonly, nonatomic) CLIApplication* application;

- (instancetype)initWithApplication: (CLIApplication*)application;

@end

@implementation CLIApplicationOptionParserDelegate

@synthesize application;

- (instancetype)initWithApplication: (CLIApplication*)theApplication {
    if (self = [super init]) {
        application = theApplication;
        return self;
    }
    
    return nil;
}

- (void)optionParser: (CLIOptionParser*)parser didEncounterOptionWithName: (NSString*)optionName argument: (NSString*)optionArgument {
    if (nil != self.application.delegate) {
        [self.application.delegate application: self.application didEncounterOptionWithName: optionName argument: optionArgument];
    }
}

- (void)optionParser: (CLIOptionParser*)parser didEncounterNonOptionArguments: (NSArray*)remainingArguments {
    if (nil != self.application.delegate) {
        [self.application.delegate application: self.application isReadyToBeginExecutingWithRemainingArguments: remainingArguments];
    }
}

@end


@interface CLIApplication ()

@property (strong, nonatomic) CLIOptionParser*                      optionParser;
@property (strong, nonatomic) CLIUsageMessageGenerator*             usageMessageGenerator;
@property (strong, nonatomic) CLIApplicationOptionParserDelegate*   optionParserDelegate;

@property (strong, nonatomic) NSArray*                              recognizedOptions;
@property (readwrite, strong, nonatomic) NSFileHandle*              standardInput;
@property (readwrite, strong, nonatomic) NSFileHandle*              standardOutput;
@property (readwrite, strong, nonatomic) NSFileHandle*              standardError;

@end

@implementation CLIApplication

@synthesize optionParser, usageMessageGenerator, exitCode, recognizedOptions, optionParserDelegate;
@synthesize delegate = _delegate;
@synthesize standardInput, standardOutput, standardError;

- (instancetype)init {
    if (self = [super init]) {
        exitCode = 0;
        _delegate = nil;
        optionParser = [[CLIOptionParser alloc] init];
        optionParserDelegate = [[CLIApplicationOptionParserDelegate alloc] initWithApplication: self];
        optionParser.delegate = optionParserDelegate;
        usageMessageGenerator = nil;
        recognizedOptions = nil;
        standardError = nil;
        standardInput = nil;
        standardOutput = nil;
        
        return self;
    }
    
    return nil;
}

- (void)setDelegate: (id<CLIApplicationDelegate>)delegate {
    _delegate = delegate;
    
    self.usageMessageGenerator = nil;
    self.recognizedOptions = nil;
}

- (void)runWithCommandlineArguments: (char* const*)argsFromMain count: (int)argumentCount {
    @try {
        self.standardError = [NSFileHandle fileHandleWithStandardError];
        self.standardOutput = [NSFileHandle fileHandleWithStandardOutput];
        self.standardInput = [NSFileHandle fileHandleWithStandardInput];
        
        if (nil != self.delegate && [self.delegate respondsToSelector: @selector(applicationWillBeginRunning:)]) {
            [self.delegate applicationWillBeginRunning: self];
        }
        
        if (nil != self.delegate) {
            self.recognizedOptions = [self.delegate recognizedOptionsForApplication: self];
            
            NSError*    err = nil;
            
            [self.optionParser parseCommandLineArguments: argsFromMain count: argumentCount optionsToRecognize: self.recognizedOptions error: &err];
            
            if (nil != err) {
                [self.delegate application: self didFailOptionParsingWithError: err];
            }
        }
        
        if (nil != self.delegate && [self.delegate respondsToSelector: @selector(applicationWillEndRunning:)]) {
            [self.delegate applicationWillEndRunning: self];
        }
    } @finally {
        self.standardInput = nil;
        self.standardOutput = nil;
        self.standardError = nil;
    }
}

- (NSString*)generateUsageMessage {
    [self ensureRecognizedOptions];
    
    if (nil == self.usageMessageGenerator) {
        self.usageMessageGenerator = [[CLIUsageMessageGenerator alloc] initWithCommandLineOptions: self.recognizedOptions];
        self.usageMessageGenerator.delegate = self.delegate;
    }
    
    return [self.usageMessageGenerator generateUsageMessage];
}

- (void)writeUseageMessage {
    NSString *usage = [self generateUsageMessage];
    [self writeStdErrorString:[NSString stringWithFormat:@"%@%@", usage ?: @"", usage ? @"\n" : @""]];
}

- (void)writeError:(NSError *)error {
    NSString *errorDesc = [error localizedDescription];
    [self writeStdErrorString:[NSString stringWithFormat:@"%@%@", errorDesc ?: @"", errorDesc ? @"\n" : @""]];
}

- (void)writeStdErrorString:(NSString *)string {
    [self writeString:string isError:YES];
}

- (void)writeStdOutString:(NSString *)string {
    [self writeString:string isError:NO];
}

- (void)writeString:(NSString *)string isError:(BOOL)isError {
    NSFileHandle *fileHandle = isError ? self.standardError : self.standardOutput;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    if (data) {
        @try {
            [fileHandle writeData:data];
        }
        @catch (NSException *exception) {
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Could not write '%@' to %@. Exception: %@", nil), string, isError ? @"stderr" : @"stdout", exception];
            if (isError) {
                NSLog(@"%@", message);
            } else {
                [self writeString:message isError:YES];
            }
        }
    }
}

- (void)ensureRecognizedOptions {
    if (nil == self.recognizedOptions) {
        if (nil != self.delegate) {
            self.recognizedOptions = [self.delegate recognizedOptionsForApplication: self];
        } else {
            self.recognizedOptions = @[];
        }
    }
}

@end

int CLIApplicationMain(NSString* delegateClassName, char* const* argv, int argc) {
    Class delegateClass = NSClassFromString(delegateClassName);
    
    id<CLIApplicationDelegate>  applicationDelegate = [[delegateClass alloc] init];
    CLIApplication*             application = [[CLIApplication alloc] init];
    
    application.delegate = applicationDelegate;
    
    [application runWithCommandlineArguments: argv count: argc];
    
    return application.exitCode;
}
