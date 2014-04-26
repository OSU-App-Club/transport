//
//  RouteDetailViewController.h
//  Transport
//
//  Created by Chris Vanderschuere on 4/25/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteDetailViewController : UIViewController <GMSMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *mapDoneButton;
@property (nonatomic, strong) NSArray *routes;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@property BOOL showStops;

- (IBAction)doneButtonPressed:(id)sender;

@end
