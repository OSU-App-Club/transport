//
//  AppDelegate.m
//  Transport
//
//  Created by Chris Vanderschuere on 4/19/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//  Carly carly carly

#import "AppDelegate.h"
#import "StopsViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //Authorize Google Maps
    [GMSServices provideAPIKey:@"AIzaSyCC8uhRO960wAErUp8WyLE9n7NnFmq3Aek"];
    [Mixpanel sharedInstanceWithToken:@"3733fd953730250288a417e9f7522751"];
    
    // Setup location monitoring
    if ([CLLocationManager locationServicesEnabled]) {
        self.locManager = [[CLLocationManager alloc] init];
        self.locManager.delegate = self;
        
        self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locManager.distanceFilter = 100;
        [self.locManager startUpdatingLocation];
    }
    
    [self setupColors:application];

    return YES;
}

- (void) setupColors:(UIApplication*) application{
    //[UIColor colorWithRed:(.996) green:(.88) blue:(.1) alpha:(1)];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:(0) green:(.764) blue:(.972) alpha:(.6)]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]]; // text color
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSFontAttributeName : [UIFont fontWithName:@"Avenir-Black" size:22.0],
                                                           NSForegroundColorAttributeName:[UIColor whiteColor]
                                                           }
     ];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    [self.locManager stopUpdatingLocation];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.d
    
    UINavigationController *rootNav = (UINavigationController *) self.window.rootViewController;
    
    // Reload main screen
    if ([rootNav.viewControllers.firstObject isKindOfClass:[StopsViewController class]]) {
        StopsViewController* stopVC = (StopsViewController *) rootNav.viewControllers.firstObject;
        if (stopVC.nearbyStops.count > 0) {
            [stopVC updateArrivalsForStops:stopVC.nearbyStops];
        }
    }
    
    [self.locManager startUpdatingLocation];
    
    // Send app open info
    [[Mixpanel sharedInstance] track:@"appOpen" properties:@{@"Last Location":self.locManager.location?self.locManager.location:@"Unknown"}];

    // Simulate location for app.io
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isAppio"] boolValue]) {
        self.currentLocation = [[CLLocation alloc] initWithLatitude:44.567 longitude:-123.278];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - CLLocationManager
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"New Location: %@",locations.firstObject);
    
    CLLocation *newLoc = locations.firstObject;
    NSLog(@"Accuracy: %f",newLoc.horizontalAccuracy);

    
    // Save the most recent location
    if (newLoc.coordinate.latitude != self.currentLocation.coordinate.latitude && newLoc.coordinate.longitude != self.currentLocation.coordinate.longitude && newLoc.horizontalAccuracy <= 1000) {
        self.currentLocation = newLoc;
    }else if (newLoc.horizontalAccuracy > 1000){
        NSLog(@"Not enough accuracy: %f",newLoc.horizontalAccuracy);
    }
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Location Error: %@",error);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Error" message:@"Your location could not be determined" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [alert show];
    
    self.currentLocation = nil;
}

@end
