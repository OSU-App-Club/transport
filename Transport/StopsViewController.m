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
#import "StopDetailViewController.h"

#define kCellReuseID        @"stopCell"

@interface StopsViewController ()

@property (nonatomic, strong) NSArray *arrivals;
@property (nonatomic, strong) NSTimer *updateTimer;

@property (nonatomic, strong) UIImageView *emptyImageView;
@property (atomic, strong) NSArray *nearbyStops;
@property (nonatomic, strong) NSOperationQueue *background;

@property (atomic) BOOL isLoading;

@end

@implementation StopsViewController

- (void) setArrivals:(NSArray *)arrivals{
    @synchronized(self){
        _arrivals = arrivals;
        [self.collectionView reloadData];
    }
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.background = [[NSOperationQueue alloc] init];
        self.background.maxConcurrentOperationCount = 1; // Throttles to one at a time
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    // Start monitoring for location updates
    AppDelegate *del = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [del addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
    
    // Add special info button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [button addTarget:self action:@selector(infoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:infoButton];
    
    // Removes title from back button in routes
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStyleDone target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:backButton];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
}

- (void) dealloc{
    AppDelegate *del = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [del removeObserver:self forKeyPath:@"currentLocation"];
}

- (void) infoButtonTapped{
    [self performSegueWithIdentifier:@"InfoSegue" sender:nil];
}

- (void) startRefresh:(UIRefreshControl*)refreshControl{
    if (!self.isLoading) {
        [self.refreshControl beginRefreshing];
        [self updateArrivalsForStops:self.nearbyStops];
    }
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.title = @"Transport";
    
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(periodicRefresh) userInfo:nil repeats:YES];
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.updateTimer invalidate];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"currentLocation"]) {
        // Extract location from object
        AppDelegate *del = (AppDelegate*) object;
        [self updateWithLocation:del.currentLocation];
    }
}

- (void) periodicRefresh{
    if (self.nearbyStops.count>0 && self.selectedIndex == NSUIntegerMax && !self.isLoading) {
        [self.collectionView reloadData];
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
        NSString* stopURLString = [[NSString stringWithFormat:@"http://www.corvallis-bus.appspot.com/stops?lat=%f&lng=%f&radius=800&limit=10", location.coordinate.latitude,location.coordinate.longitude] stringByAddingPercentEscapesUsingEncoding : NSUTF8StringEncoding];
        
        [[session dataTaskWithURL:[NSURL URLWithString:stopURLString]
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    
                    self.nearbyStops = [[NSJSONSerialization JSONObjectWithData:data
                                                                  options:0
                                                                    error:nil] objectForKey:@"stops"];
                    // Add empty state
                    [self addEmptyImage:YES shouldClear:self.nearbyStops.count != 0];
                    
                    // Populate arrivals -- if none exist
                    if (self.nearbyStops.count >0 && self.arrivals == nil && !self.isLoading) {
                        [self updateArrivalsForStops:self.nearbyStops];
                    }else if(self.nearbyStops.count ==0){
                        self.arrivals = nil;
                    }
                }
          ] resume];
        
    }
}

- (void) updateArrivalsForStops:(NSArray*) stopsArray{
    if (stopsArray.count == 0) {
        return;
    }
    
    NSLog(@"Updating Arrivals");
    self.isLoading = YES;
    
    NSMutableDictionary* stops = [NSMutableDictionary dictionary];
    
    // Create mapping
    for (NSDictionary *stopDict in stopsArray) {
        [stops setObject:stopDict forKey:stopDict[@"ID"]];
    }
    
    NSString *idString = [stops.allKeys componentsJoinedByString:@","];
    NSString* urlString = [[NSString stringWithFormat:@"http://www.corvallis-bus.appspot.com/arrivals?stops=%@", idString] stringByAddingPercentEscapesUsingEncoding : NSUTF8StringEncoding];
    
    // Make call for arrivals on this route
    NSURLSession *session = [NSURLSession sharedSession];
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
            Stop *newStop = [Stop stopWithDictionary:[stops objectForKey:@([stopNumString doubleValue])]];
            
            // Create new Arrival for each route/stop
            [timePairDict enumerateKeysAndObjectsUsingBlock:^(NSString* routeName, NSArray* times, BOOL *stop) {
                Arrival *newArrival = [[Arrival alloc] init];
                newArrival.routeName = routeName;
                newArrival.stop = newStop;
                newArrival.times = times;
                newArrival.routeColor = self.routeColorDict[routeName];
                
                [arrivals addObject:newArrival];
            }];
            
        }];
        
        // Filter times that are too far away -- 99 mins
        [arrivals filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Arrival* evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject.nextTime timeIntervalSinceNow] < 60.0*60.0; // one hour ahead of time
        }]];
        
        // Sort by distance,route name
        [arrivals sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"stop.distance" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"nextTime" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"routeName" ascending:YES]]];
        
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.arrivals = arrivals;
            [self addEmptyImage:YES shouldClear:self.arrivals.count != 0];
            self.isLoading = NO;
         }];
        
        NSLog(@"Finish updating arrivals");
        [self.refreshControl endRefreshing];
    }] resume];

}

- (void) addEmptyImage:(bool)nearbyStopsExist shouldClear:(BOOL) shouldClear{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (!shouldClear) {
            // Check if image view already exists
            if (!self.emptyImageView) {
                CGRect imageFrame = CGRectMake(70.0, 150.0, 180.0, 180.0);
                self.emptyImageView = [[UIImageView alloc] initWithFrame:imageFrame];
                [self.view addSubview:self.emptyImageView];
            }
            
            // Add empty state
            self.emptyImageView.image = [UIImage imageNamed:nearbyStopsExist?@"NoArrivals":@"UnsupportedArea"];
        }else{
            [self.emptyImageView removeFromSuperview];
            self.emptyImageView = nil;
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection View

- (void) updateCell: (UICollectionViewCell *) cell ToState:(BOOL) isExpanded{
    StopCell *stopCell = (StopCell*) cell;
    stopCell.timesTableView.hidden = stopCell.mapItButton.hidden = !isExpanded;
}

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
    
    cell.mapItButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Black" size:22.0];
    cell.mapItButton.tintColor = [UIColor colorWithRed:(0) green:(.764) blue:(.972) alpha:(.6)];
    
    Arrival *currentArrival = (Arrival*) self.arrivals[indexPath.item];
    stopName.text = currentArrival.stop.name;
    routeName.text = currentArrival.routeName;
    streetName.text = currentArrival.stop.stopID.stringValue;
    
    tileView.backgroundColor = currentArrival.routeColor;
    
    NSString *timeString = [NSString stringWithFormat:@"%.0f",floor([currentArrival.nextTime timeIntervalSinceNow]*(1.0/60.0))];
    nextArrival.text = timeString;
    
    cell.times = currentArrival.times;
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"mapStopSegue"]) {
        UICollectionViewCell *cell = (UICollectionViewCell*) [[sender superview] superview];
        NSIndexPath *path = [self.collectionView indexPathForCell:cell];
        
        // Get Stop
        Arrival* selectedArrival = self.arrivals[path.row];
        
        StopDetailViewController* stopDetail = (StopDetailViewController*) segue.destinationViewController;
        stopDetail.currentArrival = selectedArrival;
        
    }
    
}


@end
