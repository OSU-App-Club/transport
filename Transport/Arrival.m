//
//  Arrival.m
//  Transport
//
//  Created by Chris Vanderschuere on 4/19/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import "Arrival.h"

@implementation Arrival

- (NSDate *) nextTime{
    return [self.times.firstObject expected];
}

@end