//
//  CLIErrorCollector.m
//  CLIKit
//
//  Created by Michael James on 10/4/14.
//  Copyright (c) 2014 Maple Glen Software. All rights reserved.
//

#import "CLIErrorCollector.h"
#import "CLIOptionParser.h"

@interface CLIErrorCollector ()

@property (strong, nonatomic) NSMutableArray* collectedErrors;

@end

@implementation CLIErrorCollector

@synthesize collectedErrors;

- (instancetype)init {
    if (self = [super init]) {
        collectedErrors = [[NSMutableArray alloc] initWithCapacity: 3];
        
        return self;
    }
    
    return nil;
}

- (void)addError: (NSError*)error {
    [self.collectedErrors addObject: error];
}

- (void)removeError: (NSError*)error {
    [self.collectedErrors removeObject: error];
}

- (void)clearErrors {
    [self.collectedErrors removeAllObjects];
}

- (NSError*)errorWrappingCollectedErrorsIfNecessary {
    if ([collectedErrors count] <= 0) {
        return nil;
    }
    
    if ([collectedErrors count] == 1) {
        return collectedErrors[0];
    }
    
    NSDictionary*   userInfo = @{ CLIMultipleErrorsKey: self.collectedErrors };
    NSError*        wrapperError = [NSError errorWithDomain: CLIKitErrorDomain code: kCLIMultipleErrors userInfo: userInfo];
    
    return wrapperError;
}

@end
