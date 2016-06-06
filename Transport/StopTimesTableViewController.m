//
//  StopTimesTableViewController.m
//  Transport
//
//  Created by Chris Vanderschuere on 4/24/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import "StopTimesTableViewController.h"
#import "TimePair.h"
#import "UIColor+Utils.h"

@interface StopTimesTableViewController ()

@property (nonatomic, strong) NSArray* stopTimes;

@end

@implementation StopTimesTableViewController

- (void) setStopTimes:(NSArray *)stopTimes{
    _stopTimes = stopTimes;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView reloadData]; 
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Make button for today
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitWeekday);
    NSDateComponents *comps = [calendar components:preservedComponents fromDate:date];
    
    [self updateArrivalsWithCurrentDay:YES other:comps.weekday];

    [self updateStatusBarWithDayOfWeek:comps.weekday];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateStatusBarWithDayOfWeek:(NSInteger)dayOfWeek{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:formatter.weekdaySymbols[dayOfWeek-1] style:UIBarButtonItemStyleBordered target:self action:@selector(showDaysPicker)];
}

- (void) updateArrivalsWithCurrentDay:(BOOL) useToday other:(NSInteger)dayOfWeek{
    // Convert to generic midnight time
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday);
    NSDateComponents *comps = [calendar components:preservedComponents fromDate:date];
    
    if (!useToday) {
        [comps setDay:(comps.day-comps.weekday)+dayOfWeek];
    }
    
    date = [calendar dateFromComponents:comps];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setDateFormat:@"dd MMM yy HH:mm ZZZ"];
    
    NSString* urlString = [[NSString stringWithFormat:@"%@/arrivals?date=%@&stops=%@",SERVER_URL,[dateFormatter stringFromDate:date], self.stopID] stringByAddingPercentEscapesUsingEncoding : NSUTF8StringEncoding];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Make call for arrivals on this route
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        
        // Parse Arrival times
        
        NSDictionary *arrivalJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:nil];
        
        if (arrivalJSON.count>0) {
            NSArray * allArrivals =[arrivalJSON objectForKey:arrivalJSON.allKeys[0]];
            
            if (self.routeFilter) {
                self.stopTimes = [allArrivals filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary* evaluatedObject, NSDictionary *bindings) {
                    return [evaluatedObject[@"Route"] isEqualToString:self.routeFilter];
                }]];
            }else{
                self.stopTimes = allArrivals;
            }
            
            if (self.stopTimes.count==0) {
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    UIAlertView *newAlert = [[UIAlertView alloc] initWithTitle:@"No Arrivals" message:@"This stop does not have any known arrivals. Try a nearby stop" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                    [newAlert show];
                }];
            }
        }
        
    }] resume];
    
    [[Mixpanel sharedInstance] track:@"Stop Times" properties:@{
                                                                     @"StopID":self.stopID,
                                                                     @"Day":dateFormatter.weekdaySymbols[comps.weekday-1]
                                                                     }
     ];

}

- (void) showDaysPicker{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose Day" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    
    for (NSString *title in formatter.weekdaySymbols) {
        [sheet addButtonWithTitle:title];
    }
    
    [sheet addButtonWithTitle:@"Cancel"];
    sheet.cancelButtonIndex = [formatter.weekdaySymbols count];
    
    [sheet showInView:self.view];
}

#pragma mark - UIActionSheet
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex<7) {
        [self updateArrivalsWithCurrentDay:NO other:buttonIndex+1];
        [self updateStatusBarWithDayOfWeek:buttonIndex+1];
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.stopTimes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timeCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Configure the cell...
    NSDictionary *arrivalDict = self.stopTimes[indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM yy HH:mm ZZZ"];
    
    cell.textLabel.text = [NSDateFormatter localizedStringFromDate:[dateFormatter dateFromString:arrivalDict[@"Scheduled"]] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    cell.detailTextLabel.text = arrivalDict[@"Route"];
    cell.detailTextLabel.textColor = [UIColor colorForRoute:arrivalDict[@"Route"]];
    
    return cell;
}

@end
