//
//  CLIArrayUtils.h
//  CLIKit
//
//  Created by Michael James on 9/30/14.
//  Copyright (c) 2014 Maple Glen Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLIArrayUtils : NSObject

+ (NSArray*)objectsFromArray: (NSArray*)array passingTest: (BOOL (^)(id obj, NSUInteger index, BOOL* stop))predicate;
+ (id)firstObjectFromArray: (NSArray*)array passingTest: (BOOL (^)(id obj, NSUInteger index, BOOL* stop))predicate;

@end
