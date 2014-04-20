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
    NSDate *nextDate = [self.times.firstObject expected];
    
    // Check if this data should be deleted
    if ([nextDate timeIntervalSinceNow]<0.0) {
        // Remove date
        NSMutableArray *mutableTimes = [NSMutableArray arrayWithArray:self.times];
        [mutableTimes removeObjectAtIndex:0];
        self.times = mutableTimes;
        nextDate = [self.times.firstObject expected];
    }
    
    return nextDate;
}

@end
