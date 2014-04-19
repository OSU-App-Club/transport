//
//  AppDelegate.m
//  Transport
//
//  Created by Chris Vanderschuere on 4/19/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//  Carly carly carly

#import "AppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation AppDelegate

- (CLLocation *)currentLocation{
    //if (_currentLocation == nil) {
        return [[CLLocation alloc] initWithLatitude:44.571319 longitude:-123.275147];
    //}
    
    //return _currentLocation;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GMSServices provideAPIKey:@"AIzaSyCC8uhRO960wAErUp8WyLE9n7NnFmq3Aek"];
    // Override point for customization after application launch.
    
    // Setup location monitoring
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        self.locManager = [[CLLocationManager alloc] init];
        self.locManager.delegate = self;
        
        [self.locManager startMonitoringSignificantLocationChanges];
    }
    
    [self setupColors];
    
    return YES;
}

- (void) setupColors{
    //[UIColor colorWithRed:(.996) green:(.88) blue:(.1) alpha:(1)];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:(0) green:(.764) blue:(.972) alpha:(.6)]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]]; // text color
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - CLLocationManager
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    // Save the most recent location
    self.currentLocation = locations.firstObject;
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Location Error: %@",error);
}

@end
