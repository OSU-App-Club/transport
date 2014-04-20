//
//  StopsViewController.m
//  Transport
//
//  Created by Chris Vanderschuere on 4/19/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import "StopsViewController.h"
#import "AppDelegate.h"
#import "Arrival.h"
#import "StopCell.h"

#define kCellReuseID        @"stopCell"
#define kCollapsedHeight  80
#define kExpanedHeight self.view.bounds.size.height

@interface StopsViewController ()

@property (nonatomic, strong) NSArray *arrivals;
@property (nonatomic, strong) NSDictionary *routeColorDict;
@property NSUInteger selectedIndex;
@property (nonatomic, strong) UIRefreshControl* refreshControl;

@end

@implementation StopsViewController

- (void) setArrivals:(NSArray *)arrivals{
    _arrivals = arrivals;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.collectionView reloadData];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.routeColorDict = @{
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
    
    // Start monitoring for location updates
    AppDelegate *del = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [del addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    
    self.title = @"Transport";
    
    // Add special info button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [button addTarget:self action:@selector(infoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:infoButton];
}

- (void) infoButtonTapped{
    [self performSegueWithIdentifier:@"InfoSegue" sender:nil];
}

- (void) startRefresh:(UIRefreshControl*)refreshControl{
    [self.refreshControl beginRefreshing];
    
    AppDelegate *del = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [self updateWithLocation:del.currentLocation];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
        
    //Customize layout for paging
    //MUST DO IT HERE: not setup yet in viewDidLoad
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
    layout.minimumLineSpacing = .8;
    
    self.navigationController.navigationBar.topItem.title = @"Transport";

    
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"currentLocation"]) {
        // Extract location from object
        AppDelegate *del = (AppDelegate*) object;
        [self updateWithLocation:del.currentLocation];
    }
}

- (void) updateWithLocation: (CLLocation *)location{
    // Check for nil location
    if (location == nil) {
        // Clear the screen
        self.arrivals = nil;
    }else{
        NSLog(@"Loading for: %f,%f",location.coordinate.latitude,location.coordinate.longitude);
        
        // Load nearby stops...and then arrivals for those stops
        NSURLSession *session = [NSURLSession sharedSession];
        NSString* stopURLString = [[NSString stringWithFormat:@"http://www.corvallis-bus.appspot.com/stops?lat=%f&lng=%f&radius=500&limit=10", location.coordinate.latitude,location.coordinate.longitude] stringByAddingPercentEscapesUsingEncoding : NSUTF8StringEncoding];
        
        [[session dataTaskWithURL:[NSURL URLWithString:stopURLString]
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    
                    NSArray *nearbyStops = [[NSJSONSerialization JSONObjectWithData:data
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:nil] objectForKey:@"stops"];
                    
                    NSMutableDictionary* stops = [NSMutableDictionary dictionary];
                    
                    // Create mapping
                    for (NSDictionary *stopDict in nearbyStops) {
                        [stops setObject:stopDict forKey:stopDict[@"ID"]];
                    }
                    
                    NSString *idString = [stops.allKeys componentsJoinedByString:@","];
                    NSString* urlString = [[NSString stringWithFormat:@"http://www.corvallis-bus.appspot.com/arrivals?stops=%@", idString] stringByAddingPercentEscapesUsingEncoding : NSUTF8StringEncoding];
                    
                    // Make call for arrivals on this route
                    [[session dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        // Parse Arrival times
                        
                        NSDictionary *arrivalJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                                options:NSJSONReadingAllowFragments
                                                                                  error:nil];
                        
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"d MMM yy HH:mm ZZZ"];
                        
                        NSMutableArray *arrivals = [NSMutableArray array];

                        // Loop over all arrivals for all stops
                        [arrivalJSON enumerateKeysAndObjectsUsingBlock:^(NSString* stopNumString, id obj, BOOL *stop) {
                            NSArray *timeInfos = (NSArray *)obj;
                            
                            // Create time pairs -- key is routeName, value: array of TimePairs
                            NSMutableDictionary *timePairDict = [NSMutableDictionary dictionary];

                            // Build time pairs by route
                            for (NSDictionary *timeInfo in timeInfos) {
                                //Create timepair
                                TimePair *newPair = [[TimePair alloc] init];
                                newPair.scheduled = [dateFormatter dateFromString:timeInfo[@"Scheduled"]];
                                newPair.expected = [dateFormatter dateFromString:timeInfo[@"Expected"]];
            
                                
                                NSArray *times = [timePairDict objectForKey:timeInfo[@"Route"]];
                                if (times) {
                                    // Extend with new time
                                    NSArray *newTimes = [times arrayByAddingObject:newPair];
                                    [timePairDict setObject:newTimes forKey:timeInfo[@"Route"]];
                                    
                                }else{
                                    [timePairDict setObject:[NSArray arrayWithObject:newPair] forKey:timeInfo[@"Route"]];
                                }
                            }
                            
                            // Create stop
                            NSDictionary *stopDict = [stops objectForKey:@([stopNumString doubleValue])];
                            Stop *newStop = [[Stop alloc] init];
                            newStop.name = stopDict[@"Name"];
                            newStop.road = stopDict[@"Road"];
                            newStop.distance = stopDict[@"Distance"];
                            
                            // Create new Arrival for each route/stop
                           [timePairDict enumerateKeysAndObjectsUsingBlock:^(NSString* routeName, NSArray* times, BOOL *stop) {
                               Arrival *newArrival = [[Arrival alloc] init];
                               newArrival.routeName = routeName;
                               newArrival.stop = newStop;
                               newArrival.times = times;
                               
                               [arrivals addObject:newArrival];
                           }];
                            
                        }];
                        
                        
                        // Filter times that are too far away -- 99 mins
                        [arrivals filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Arrival* evaluatedObject, NSDictionary *bindings) {
                            return [evaluatedObject.nextTime timeIntervalSinceNow] < 60.0*99.0;
                        }]];
                        
                        // Sort by distance,route name
                        [arrivals sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"stop.distance" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"nextTime" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"routeName" ascending:YES]]];
                        
                        self.arrivals = arrivals;
                        
                        [self.refreshControl endRefreshing];
                    }] resume];

                }
          ] resume];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arrivals.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    StopCell *cell = (StopCell*) [cv dequeueReusableCellWithReuseIdentifier:kCellReuseID forIndexPath:indexPath];
    
    UILabel *stopName = (UILabel*) [cell viewWithTag:200];
    UILabel *nextArrival = (UILabel*) [cell viewWithTag:201];
    UILabel *routeName = (UILabel*) [cell viewWithTag:202];
    UIView *tileView = (UIView*) [cell viewWithTag:203];
    UILabel *streetName = (UILabel*) [cell viewWithTag:204];
    
    Arrival *currentArrival = (Arrival*) self.arrivals[indexPath.item];
    stopName.text = currentArrival.stop.name;
    routeName.text = currentArrival.routeName;
    streetName.text = currentArrival.stop.road;
    
    tileView.backgroundColor = self.routeColorDict[currentArrival.routeName];
    
    NSString *timeString = [NSString stringWithFormat:@"%.0f",[[currentArrival.times.firstObject expected] timeIntervalSinceNow]*(1.0/60.0)];
    nextArrival.text = timeString;
    
    cell.times = currentArrival.times;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.bounds.size.width, (indexPath.item==self.selectedIndex)?kExpanedHeight:kCollapsedHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger currentHeight = [collectionView cellForItemAtIndexPath:indexPath].bounds.size.height;
    BOOL expand = currentHeight == kCollapsedHeight;
    collectionView.scrollEnabled = !expand;
    [collectionView performBatchUpdates:^{
        self.selectedIndex = expand ? indexPath.item : NSUIntegerMax;
    } completion:^(BOOL finished) {
        [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
    }];
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

@end
