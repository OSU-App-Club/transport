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
#import "UIColor+Utils.h"

#define kCellReuseID        @"routeCell"
#define kCollapsedHeight  80
#define kExpanedHeight self.view.bounds.size.height - (self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height)


@interface RoutesViewController ()

@property (nonatomic, strong) NSArray *routes;
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
    [[session dataTaskWithURL:[NSURL URLWithString:[SERVER_URL stringByAppendingString:@"/routes?stops=true"]]
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
    UIColor* routeColor = [UIColor colorFromHex:route[@"Color"]];

    routeNumber.text = route[@"Name"];
    routeName.text = route[@"AdditionalName"];
    background.backgroundColor = routeColor;
    
    cell.stops = route[@"Path"];
    
    [cell.mapButton setTitleColor:routeColor forState:UIControlStateNormal];
    [cell.mapButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];

    [cell.mapButton setImage:[GMSMarker markerImageWithColor:routeColor] forState:UIControlStateNormal];
    [cell.mapButton setImage:[GMSMarker markerImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];


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
