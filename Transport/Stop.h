//
//  Stop.h
//  Transport
//
//  Created by Chris Vanderschuere on 4/19/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stop : NSObject

@property (nonatomic,strong) NSString* name;
@property (nonatomic, strong) NSString* road;
@property (nonatomic, strong) NSNumber* stopID;
@property (nonatomic, strong) CLLocation* location;
@property (nonatomic, strong) NSNumber* bearing;

@property (nonatomic, strong) NSNumber* distance;

+(instancetype) stopWithDictionary:(NSDictionary*)stopDict;

@end
