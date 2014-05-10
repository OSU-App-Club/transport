//
//  StopTimesTableViewController.h
//  Transport
//
//  Created by Chris Vanderschuere on 4/24/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StopTimesTableViewController : UITableViewController <UIActionSheetDelegate>

@property (nonatomic, strong) NSString *stopID;
@property (nonatomic, strong) NSString *routeFilter;

@end
