//
//  RoutesViewController.m
//  Transport
//
//  Created by Chris Vanderschuere on 4/19/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import "RoutesViewController.h"
#import "RouteCell.h"
#import "StopTimesTableViewController.h"
#import "StopInRouteTableViewCell.h"
#import "RouteDetailViewController.h"

#define kCellReuseID        @"routeCell"
#define kCollapsedHeight  80
#define kExpanedHeight self.view.bounds.size.height - (self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height)


@interface RoutesViewController ()

@property (nonatomic, strong) NSArray *routes;
@property (nonatomic, strong) NSDictionary *routeColorDict;
@property NSUInteger selectedIndex;

@property (nonatomic, strong) GMSMarker *currentMarker;

@end

@implementation RoutesViewController

- (void) setRoutes:(NSArray *)routes{
    _routes = routes;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.collectionView reloadData];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.routeColorDict =  @{
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

    
    self.selectedIndex = NSUIntegerMax;
        
    [self updateRoutes];    
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //Customize layout for paging
    //MUST DO IT HERE: not setup yet in viewDidLoad
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
    layout.minimumLineSpacing = .8;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateRoutes{
    
    self.routes = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedRoutes"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:@"http://www.corvallis-bus.appspot.com/routes?stops=true"]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                
        // Parse JSON result and store in dictionary (self.routes)
        self.routes = [[NSJSONSerialization JSONObjectWithData:data
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil] objectForKey:@"routes"];
                
        // Save for later use
        [[NSUserDefaults standardUserDefaults] setObject:self.routes forKey:@"savedRoutes"];
        [[NSUserDefaults standardUserDefaults] synchronize];
                
    }] resume];
}

- (void) updateCell: (UICollectionViewCell *) cell ToState:(BOOL) isExpanded{
    RouteCell *routeCell = (RouteCell*) cell;
    routeCell.stopsTableView.hidden = routeCell.mapButton.hidden = !isExpanded;
}

#pragma mark - Collection View
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.routes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RouteCell *cell = (RouteCell*) [cv dequeueReusableCellWithReuseIdentifier:kCellReuseID forIndexPath:indexPath];
    
    NSDictionary *route = self.routes[indexPath.row];
    
    UILabel *routeNumber = (UILabel*) [cell viewWithTag:100];
    UILabel *routeName = (UILabel*) [cell viewWithTag:101];
    UIView *background = (UILabel*) [cell viewWithTag:102];

    routeNumber.text = route[@"Name"];
    routeName.text = route[@"AdditionalName"];
    background.backgroundColor = self.routeColorDict[route[@"Name"]];
    
    cell.stops = route[@"Path"];
    
    cell.mapButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Black" size:22.0];
    cell.mapButton.tintColor = [UIColor colorWithRed:(0) green:(.764) blue:(.972) alpha:(.6)];

    return cell;
}


#pragma mark - Navigation
- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"showArrivals"]) {
        UITableView* tv = (UITableView*) [[sender superview] superview];
        NSIndexPath *path = [tv indexPathForCell:sender];
        if (path.row == [tv numberOfRowsInSection:0]-1) {
            return NO;
        }
    }
    
    return YES;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showArrivals"]) {
        // Get the stop tag from the cell
        StopInRouteTableViewCell *cell = (StopInRouteTableViewCell*)sender;
        
        StopTimesTableViewController *arrVC = (StopTimesTableViewController*) segue.destinationViewController;
        arrVC.stopID = cell.stopID.text; // Used for next call of arrivals
        
        // Get route information
        //RouteCell *topCell = (RouteCell* )[[[[cell superview] superview] superview] superview];
        //NSIndexPath *path = [self.collectionView indexPathForCell:topCell];
        //arrVC.routeFilter = [self.routes[path.item] objectForKey:@"Name"];
    }else if([segue.identifier isEqualToString:@"routeDetail"]){
        RouteCell *topCell = (RouteCell* )[[sender superview] superview];
        NSIndexPath *path = [self.collectionView indexPathForCell:topCell];
        RouteDetailViewController *routeDetail = (RouteDetailViewController*) segue.destinationViewController;
        routeDetail.routes = @[self.routes[path.row]];
        routeDetail.showStops = YES;
    }else if ([segue.identifier isEqualToString:@"allRoutes"]){
        RouteDetailViewController *routeDetail = (RouteDetailViewController*) segue.destinationViewController;
        routeDetail.routes = self.routes;
    }
}

@end
