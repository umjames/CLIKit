//
//  CLIOptionParser.h
//  CLIKit
//
//  Created by Michael James on 9/13/14.
//  Copyright (c) 2014 Michael James. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLIOptionParser : NSObject

- (instancetype)initWithArgumentsFromMain: (const char**)args count: (unsigned int)count;

@end
