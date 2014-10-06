//
//  CLIErrorCollector.h
//  CLIKit
//
//  Created by Michael James on 10/4/14.
//  Copyright (c) 2014 Maple Glen Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLIErrorCollector : NSObject

- (instancetype)init;

- (void)addError: (NSError*)error;
- (void)removeError: (NSError*)error;
- (void)clearErrors;

- (NSError*)errorWrappingCollectedErrorsIfNecessary;

@end
