//
//  CLIArrayUtils.m
//  CLIKit
//
//  Created by Michael James on 9/30/14.
//  Copyright (c) 2014 Maple Glen Software. All rights reserved.
//

#import "CLIArrayUtils.h"

@implementation CLIArrayUtils

+ (NSArray*)objectsFromArray: (NSArray*)array passingTest: (BOOL (^)(id obj, NSUInteger index, BOOL* stop))predicate {
    NSIndexSet* indicesPassingTest = [array indexesOfObjectsPassingTest: predicate];
    
    return [array objectsAtIndexes: indicesPassingTest];
}

+ (id)firstObjectFromArray: (NSArray*)array passingTest: (BOOL (^)(id obj, NSUInteger index, BOOL* stop))predicate {
    NSUInteger  firstIndexPassingTest = [array indexOfObjectPassingTest: predicate];
    
    if (NSNotFound == firstIndexPassingTest) {
        return nil;
    }
    
    return array[firstIndexPassingTest];
}

@end
