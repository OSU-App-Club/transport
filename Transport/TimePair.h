//
//  TimePair.h
//  Transport
//
//  Created by Chris Vanderschuere on 4/19/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimePair : NSObject

@property (nonatomic, strong) NSDate *scheduled;
@property (nonatomic, strong) NSDate *expected;

@end
