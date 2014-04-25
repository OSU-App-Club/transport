//
//  StopDetailViewController.m
//  Transport
//
//  Created by Chris Vanderschuere on 4/24/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import "StopDetailViewController.h"

@interface StopDetailViewController ()

@property CGColorRef *doneButtonBGColor;

@end

@implementation StopDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mapView.mapType = kGMSTypeHybrid;
    self.mapView.myLocationEnabled = YES;
    
    // Zoom map
    GMSCameraPosition *pos = [GMSCameraPosition cameraWithLatitude:self.currentStop.location.coordinate.latitude longitude:self.currentStop.location.coordinate.longitude zoom:17 bearing:self.currentStop.bearing.doubleValue viewingAngle:0];
    
    [self.mapView setCamera:pos];
    
    // Add marker
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = self.currentStop.location.coordinate;
    marker.snippet = self.currentStop.name;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = self.mapView;
    
    self.mapDoneButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Black" size:18.0];
    self.mapDoneButton.titleLabel.textColor = [UIColor colorWithRed:(0) green:(.764) blue:(.972) alpha:(.6)];
    self.mapDoneButton.layer.cornerRadius = 5;
    self.mapDoneButton.layer.borderWidth = 1.5;
    self.mapDoneButton.layer.borderColor = [[UIColor colorWithRed:(0) green:(.764) blue:(.972) alpha:(.6)] CGColor];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Preferences
- (UIStatusBarStyle) preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
@end
