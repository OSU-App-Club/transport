//
//  UIColor+Utils.h
//  Transport
//
//  Created by Christopher Vanderschuere on 6/5/16.
//  Copyright © 2016 OSU App Club. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Utils)

+ (UIColor*)colorFromHex:(NSString*)hexColor;
+ (UIColor*) colorForRoute:(NSString*)route;

@end
