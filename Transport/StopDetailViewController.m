//
//  StopDetailViewController.m
//  Transport
//
//  Created by Chris Vanderschuere on 4/24/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import "StopDetailViewController.h"

@interface StopDetailViewController ()

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
