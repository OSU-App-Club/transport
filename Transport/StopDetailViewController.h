//
//  StopDetailViewController.h
//  Transport
//
//  Created by Chris Vanderschuere on 4/24/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Stop.h"

@interface StopDetailViewController : UIViewController

@property (nonatomic, strong) Stop *currentStop;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

- (IBAction)doneButtonPressed:(id)sender;

@end
