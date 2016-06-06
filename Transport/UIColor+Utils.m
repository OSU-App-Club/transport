//
//  UIColor+Utils.m
//  Transport
//
//  Created by Christopher Vanderschuere on 6/5/16.
//  Copyright © 2016 OSU App Club. All rights reserved.
//

#import "UIColor+Utils.h"

@implementation UIColor (Utils)

+ (UIColor*) colorForRoute:(NSString*)route{
    NSArray* routes = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedRoutes"];
    for(NSDictionary* r in routes){
        if([route isEqualToString:[r objectForKey:@"Name"]]){
            return [UIColor colorFromHex:r[@"Color"]];
        }
    }

    return [UIColor blackColor];
}


+ (UIColor*)colorFromHex:(NSString*)hexColor
{
    hexColor = hexColor.length == 8 ? hexColor : [hexColor stringByAppendingString:@"FF"];
    
    unsigned int result;
    NSScanner* scanner = [NSScanner scannerWithString:hexColor];
    
    [scanner scanHexInt:&result];
    
    NSInteger red = (result >> 24) & 0xff;
    NSInteger green = (result >> 16) & 0xff;
    NSInteger blue = (result >> 8) & 0xff;
    NSInteger alpha = result & 0xff;
    
    return [UIColor colorWithRed:(CGFloat)red / 255.0
                           green:(CGFloat)green / 255.0
                            blue:(CGFloat)blue / 255.0
                           alpha:(CGFloat)alpha / 255.0];
}

@end
