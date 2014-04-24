//
//  Stop.m
//  Transport
//
//  Created by Chris Vanderschuere on 4/19/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import "Stop.h"

@implementation Stop

+(instancetype) stopWithDictionary:(NSDictionary *)stopDict{
    Stop* newStop = [[Stop alloc] init];
    
    newStop.name = stopDict[@"Name"];
    newStop.road = stopDict[@"Road"];
    newStop.location = [[CLLocation alloc] initWithLatitude:[stopDict[@"Lat"] doubleValue] longitude:[stopDict[@"Long"] doubleValue]];
    newStop.stopID = stopDict[@"ID"];
    newStop.distance = stopDict[@"Distance"];
    newStop.bearing = stopDict[@"Bearing"];
    
    return newStop;
}

@end
