//
//  RouteDetailViewController.m
//  Transport
//
//  Created by Chris Vanderschuere on 4/25/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import "RouteDetailViewController.h"
#import "UIColor+Utils.h"

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
    
    // Initialize the map
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude: CORVALLIS_LAT
                                                            longitude: CORVALLIS_LONG zoom:12];
    [self.mapView clear];
    [self.mapView setCamera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.delegate = self;
    self.mapView.settings.myLocationButton = YES;
    
    NSMutableArray *routeNames = [NSMutableArray array];

    for (NSDictionary* route in self.routes) {
        [routeNames addObject:route[@"Name"]];
        
        GMSPath *path = [GMSPath pathFromEncodedPath:route[@"Polyline"]];
        GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
        
        // Add polyline to map
        polyline.strokeWidth = 5.f;
        polyline.strokeColor = [UIColor colorFromHex:route[@"Color"]];
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
    
    [[Mixpanel sharedInstance] track:@"Route Detail" properties:@{
                                                                 @"routes":routeNames,
                                                                 }
     ];

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
