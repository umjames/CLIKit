//
//  CLIOptionUtils.h
//  CLIKit
//
//  Created by Michael James on 10/8/14.
//  Copyright (c) 2014 Maple Glen Software. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const CLIShortOptionsKey;
extern NSString* const CLILongOptionsKey;

@interface CLIOptionUtils : NSObject

+ (NSDictionary*)normalizeOptions: (NSArray*)options;

@end
