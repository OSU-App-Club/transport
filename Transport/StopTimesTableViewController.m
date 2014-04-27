//
//  StopTimesTableViewController.m
//  Transport
//
//  Created by Chris Vanderschuere on 4/24/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import "StopTimesTableViewController.h"
#import "TimePair.h"

@interface StopTimesTableViewController ()

@property (nonatomic, strong) NSArray* stopTimes;
@property (nonatomic, strong) NSDictionary *routeColorDict;

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
    
    // Make button for today
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSWeekdayCalendarUnit);
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
    NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit);
    NSDateComponents *comps = [calendar components:preservedComponents fromDate:date];
    
    if (!useToday) {
        [comps setDay:(comps.day-comps.weekday)+dayOfWeek];
    }
    
    date = [calendar dateFromComponents:comps];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d MMM yy HH:mm ZZZ"];
    
    NSString* urlString = [[NSString stringWithFormat:@"http://www.corvallis-bus.appspot.com/arrivals?date=%@&stops=%@",[dateFormatter stringFromDate:date], self.stopID] stringByAddingPercentEscapesUsingEncoding : NSUTF8StringEncoding];
    
    // Make call for arrivals on this route
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

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
    [dateFormatter setDateFormat:@"d MMM yy HH:mm ZZZ"];
    
    cell.textLabel.text = [NSDateFormatter localizedStringFromDate:[dateFormatter dateFromString:arrivalDict[@"Scheduled"]] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    cell.detailTextLabel.text = arrivalDict[@"Route"];
    cell.detailTextLabel.textColor = self.routeColorDict[arrivalDict[@"Route"]];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
