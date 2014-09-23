//
//  CLIOptionRequirement.h
//  CLIKit
//
//  Created by Michael James on 9/20/14.
//  Copyright (c) 2014 Maple Glen Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLIOptionRequirement : NSObject

@property (assign, readonly, nonatomic) BOOL      isShortOption;
@property (assign, readonly, nonatomic) BOOL      canHaveArgument;
@property (assign, readonly, nonatomic) BOOL      isArgumentRequired;
@property (copy, readonly, nonatomic) NSString*   optionName;
@property (assign, readonly, nonatomic) char      valueIfOptionUsed;

+ (instancetype)optionRequirementForShortOption: (NSString*)optionName
                                canHaveArgument: (BOOL)canHaveArg
                                 thatIsRequired: (BOOL)argIsRequired;

+ (instancetype)optionRequirementForLongOption: (NSString*)optionName
                               canHaveArgument: (BOOL)canHaveArg
                                thatIsRequired: (BOOL)argIsRequired
                             valueIfOptionUsed: (char)valueIfUsed;

@end
