//
//  Arrival.h
//  Transport
//
//  Created by Chris Vanderschuere on 4/19/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stop.h"
#import "TimePair.h"

@interface Arrival : NSObject

@property (nonatomic, strong) Stop *stop;
@property (nonatomic, strong) NSString *routeName;
@property (nonatomic, strong) UIColor *routeColor;


@property (nonatomic, weak,readonly) NSDate *nextTime; // Used for sorting

// Array of TimePair for current day -- future only
@property (nonatomic, strong) NSArray *times;

@end
