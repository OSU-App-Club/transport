//
//  RoutesViewController.m
//  Transport
//
//  Created by Chris Vanderschuere on 4/19/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import "RoutesViewController.h"
#import "RouteCell.h"

#define kCellReuseID        @"routeCell"
#define kCollapsedHeight  80
#define kExpanedHeight self.view.bounds.size.height

#define CORVALLIS_LAT 44.567
#define CORVALLIS_LONG -123.278


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
        
    [self updateRoutes];
    
    self.navigationController.navigationBar.topItem.title = @"";
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
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:@"http://www.corvallis-bus.appspot.com/routes?stops=true"]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                
        // Parse JSON result and store in dictionary (self.routes)
        NSError *jsonError;
        self.routes = [[NSJSONSerialization JSONObjectWithData:data
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil] objectForKey:@"routes"];
    }] resume];
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
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.bounds.size.width, (indexPath.item==self.selectedIndex)?kExpanedHeight:kCollapsedHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    RouteCell *cell = (RouteCell*)[collectionView cellForItemAtIndexPath:indexPath];
    NSInteger currentHeight = cell.bounds.size.height;
    BOOL expand = currentHeight == kCollapsedHeight;
    collectionView.scrollEnabled = !expand;
    
    // Add/remove map view
    if (expand) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Make new map view
            GMSMapView *mapView = [[GMSMapView alloc] initWithFrame:CGRectZero];
            [cell addSubview:mapView];
            cell.mapView = mapView;
            mapView.translatesAutoresizingMaskIntoConstraints = NO;
            
            NSArray *horzConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mapView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mapView)];
            [cell addConstraints:horzConstraint];
            
            UIView *topView = (UILabel*) [cell viewWithTag:102];
            NSArray *vertConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topView(==80)][mapView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mapView,topView)];
                    [cell addConstraints:vertConstraint];

            NSDictionary *route = self.routes[indexPath.row];
            
             // Initialize the map
             GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude: CORVALLIS_LAT
             longitude: CORVALLIS_LONG
             zoom:14];
             [cell.mapView clear];
             [cell.mapView setCamera:camera];
            cell.mapView.myLocationEnabled = YES;
            cell.mapView.delegate = self;
            
             // Add polyline to map
             GMSPolyline *polyline = [GMSPolyline polylineWithPath:[GMSPath pathFromEncodedPath:route[@"Polyline"]]];
             
             polyline.strokeWidth = 5.f;
             polyline.strokeColor = self.routeColorDict[route[@"Name"]];
             polyline.map = cell.mapView;
            
            for (NSDictionary *stop in route[@"Path"]) {
                CLLocationCoordinate2D circleCenter = CLLocationCoordinate2DMake([stop[@"Lat"] doubleValue], [stop[@"Long"] doubleValue]);
                
                GMSCircle *circ = [GMSCircle circleWithPosition:circleCenter
                                                         radius:10];
                circ.title = stop[@"Name"];
                circ.fillColor = [UIColor colorWithWhite:0.0 alpha:.25];
                circ.strokeWidth = 2.0f;
                circ.tappable = YES;
                circ.map = mapView;
            }
            
        }];
    }else{
        [cell.mapView clear];
        [cell.mapView removeFromSuperview];
        cell.mapView = nil;
    }
    
    [collectionView performBatchUpdates:^{
        self.selectedIndex = expand ? indexPath.item : NSUIntegerMax;
    } completion:^(BOOL finished) {
        [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
    }];
}

#pragma mark - MapView delegate

- (void) mapView: (GMSMapView *) mapView didTapOverlay:(GMSOverlay *) overlay{
    self.currentMarker.map = nil;
    self.currentMarker = [[GMSMarker alloc] init];

    GMSPolygon *circle = (GMSPolygon *)overlay;
    self.currentMarker.position = [circle.path coordinateAtIndex:0];
    self.currentMarker.snippet = circle.title;
    self.currentMarker.appearAnimation = kGMSMarkerAnimationPop;
    self.currentMarker.map = mapView;
}

@end
