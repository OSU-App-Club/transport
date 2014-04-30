//
//  RouteDetailViewController.m
//  Transport
//
//  Created by Chris Vanderschuere on 4/25/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import "RouteDetailViewController.h"

#define CORVALLIS_LAT 44.567
#define CORVALLIS_LONG -123.278

@interface RouteDetailViewController ()

@end

@implementation RouteDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSDictionary *routeColorDict = @{
                            @"1":[UIColor colorWithRed:0.0/255.0 green:173.0/255.0 blue:238.0/255.0 alpha:1.0],
                            @"2":[UIColor colorWithRed:136.0/255.0 green:39.0/255.0 blue:144.0/255.0 alpha:1.0],
                            @"3":[UIColor colorWithRed:136.0/255.0 green:101.0/255.0 blue:144.0/255.0 alpha:1.0],
                            @"4":[UIColor colorWithRed:140.0/255.0 green:197.0/255.0 blue:144.0/255.0 alpha:1.0],
                            @"5":[UIColor colorWithRed:189.0/255.0 green:85.0/255.0 blue:144.0/255.0 alpha:1.0],
                            @"6":[UIColor colorWithRed:3.0/255.0 green:77.0/255.0 blue:144.0/255.0 alpha:1.0],
                            @"7":[UIColor colorWithRed:215.0/255.0 green:24.0/255.0 blue:144.0/255.0 alpha:1.0],
                            @"8":[UIColor colorWithRed:0.0/255.0 green:133.0/255.0 blue:64.0/255.0 alpha:1.0],
                            @"BBN":[UIColor colorWithRed:76.0/255.0 green:229.0/255.0 blue:0.0/255.0 alpha:1.0],
                            @"BBSE":[UIColor colorWithRed:255.0/255.0 green:170.0/255.0 blue:0.0/255.0 alpha:1.0],
                            @"BBSW":[UIColor colorWithRed:0.0/255.0 green:91.0/255.0 blue:229.0/255.0 alpha:1.0],
                            @"C1":[UIColor colorWithRed:97.0/255.0 green:70.0/255.0 blue:48.0/255.0 alpha:1.0],
                            @"C2":[UIColor colorWithRed:0.0/255.0 green:118.0/255.0 blue:163.0/255.0 alpha:1.0],
                            @"C3":[UIColor colorWithRed:236.0/255.0 green:12.0/255.0 blue:108.0/255.0 alpha:1.0],
                            @"CVA":[UIColor colorWithRed:63.0/255.0 green:40.0/255.0 blue:133.0/255.0 alpha:1.0],
                            };
    
    // Initialize the map
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude: CORVALLIS_LAT
                                                            longitude: CORVALLIS_LONG zoom:12];
    [self.mapView clear];
    [self.mapView setCamera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.delegate = self;
    self.mapView.settings.myLocationButton = YES;

    for (NSDictionary* route in self.routes) {
        GMSPath *path = [GMSPath pathFromEncodedPath:route[@"Polyline"]];
        GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
        
        // Add polyline to map
        polyline.strokeWidth = 5.f;
        polyline.strokeColor = routeColorDict[route[@"Name"]];
        polyline.map = self.mapView;
        
        if (self.showStops) {
            for (NSDictionary *stop in route[@"Path"]) {
                CLLocationCoordinate2D circleCenter = CLLocationCoordinate2DMake([stop[@"Lat"] doubleValue], [stop[@"Long"] doubleValue]);
                
                GMSCircle *circ = [GMSCircle circleWithPosition:circleCenter
                                                         radius:10];
                circ.title = stop[@"Name"];
                circ.fillColor = [UIColor colorWithWhite:0.0 alpha:.25];
                circ.strokeWidth = 2.0f;
                circ.tappable = YES;
                circ.map = self.mapView;
            }
        }
    }
    
    self.mapDoneButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Black" size:18.0];
    self.mapDoneButton.titleLabel.textColor = [UIColor colorWithRed:(0) green:(.764) blue:(.972) alpha:(.6)];
    self.mapDoneButton.layer.cornerRadius = 5;
    self.mapDoneButton.layer.borderWidth = 1.5;
    self.mapDoneButton.layer.borderColor = [[UIColor colorWithRed:(0) green:(.764) blue:(.972) alpha:(.6)] CGColor];
    self.mapDoneButton.layer.backgroundColor = [[UIColor colorWithRed:(1) green:(1.0) blue:(1.0) alpha:(1.0)] CGColor];
    
}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
}


@end
