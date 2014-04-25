//
//  StopDetailViewController.h
//  Transport
//
//  Created by Chris Vanderschuere on 4/24/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Arrival.h"

@interface StopDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *mapDoneButton;
@property (nonatomic, strong) Stop *currentStop;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

- (IBAction)doneButtonPressed:(id)sender;

@end
