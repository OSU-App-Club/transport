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

#define kCellReuseID        @"stopCell"
#define kCollapsedHeight  80
#define kExpanedHeight self.view.bounds.size.height

@interface StopsViewController ()

@property (nonatomic, strong) NSArray *arrivals;
@property NSUInteger selectedIndex;

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
    
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:10];
    
    for (int cell_idx = 0; cell_idx < 10; cell_idx++) {
        [temp addObject:@{@"Name":@"Test Name"}];
    }
    self.arrivals = temp;
    self.selectedIndex = NSUIntegerMax;
    
    [self.collectionView reloadData];
    
    
    // Start monitoring for location updates
    AppDelegate *del = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [del addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
    
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
                        
                        
                        // Sort by distance,route name
                        [arrivals sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"stop.distance" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"routeName" ascending:YES]]];
                        
                        self.arrivals = arrivals;
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
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellReuseID forIndexPath:indexPath];
    cell.contentView.backgroundColor = indexPath.item % 2 ? [UIColor grayColor] : [UIColor orangeColor];
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
