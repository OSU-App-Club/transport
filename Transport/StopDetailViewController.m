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
@property (nonatomic, strong) NSDictionary *route;
@property (nonatomic, strong) GMSPolyline *routePolyline;

@end

@implementation StopDetailViewController

- (void) setRoute:(NSDictionary *)route{
    _route = route;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.routePolyline.map = nil;
        
        GMSPath *path = [GMSPath pathFromEncodedPath:self.route[@"Polyline"]];
        self.routePolyline = [GMSPolyline polylineWithPath:path];
        
        // Add polyline to map
        self.routePolyline.strokeWidth = 5.f;
        self.routePolyline.strokeColor = self.currentArrival.routeColor;
        self.routePolyline.map = self.mapView;
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mapView.mapType = kGMSTypeNormal;
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    
    // Zoom map
    GMSCameraPosition *pos = [GMSCameraPosition cameraWithLatitude:self.currentArrival.stop.location.coordinate.latitude longitude:self.currentArrival.stop.location.coordinate.longitude zoom:17 bearing:self.currentArrival.stop.bearing.doubleValue viewingAngle:0];
    
    [self.mapView setCamera:pos];
    
    // Add marker
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = self.currentArrival.stop.location.coordinate;
    marker.snippet = self.currentArrival.stop.name;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.icon = [GMSMarker markerImageWithColor:self.currentArrival.routeColor];
    marker.map = self.mapView;
    
    self.mapDoneButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Black" size:18.0];
    self.mapDoneButton.titleLabel.textColor = [UIColor colorWithRed:(0) green:(.764) blue:(.972) alpha:(.6)];
    self.mapDoneButton.layer.cornerRadius = 5;
    self.mapDoneButton.layer.borderWidth = 1.5;
    self.mapDoneButton.layer.borderColor = [[UIColor colorWithRed:(0) green:(.764) blue:(.972) alpha:(.6)] CGColor];
    self.mapDoneButton.layer.backgroundColor = [[UIColor colorWithRed:(1) green:(1.0) blue:(1.0) alpha:(1.0)] CGColor];
    
    // Load route path
    NSArray *routes = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedRoutes"];
    if (routes != nil) {
        
        for (NSDictionary *route in routes) {
            if ([route[@"Name"] isEqualToString:self.currentArrival.routeName]) {
                // Use saved route
                self.route = route;
            }
        }
    }else{
        NSURLSession *session = [NSURLSession sharedSession];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.corvallis-bus.appspot.com/routes?names=%@",self.currentArrival.routeName]];
        [[session dataTaskWithURL: url
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    
                    // Parse JSON result and store in dictionary (self.routes)
                    NSArray *routes = [[NSJSONSerialization JSONObjectWithData:data
                                                              options:NSJSONReadingAllowFragments
                                                                error:nil] objectForKey:@"routes"];
                    if (routes.count != 0) {
                        self.route = routes.firstObject;
                    }
                }] resume];
    }
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
    return UIStatusBarStyleDefault;
}
@end
