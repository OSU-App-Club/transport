//
//  RouteCell.m
//  Transport
//
//  Created by Chris Vanderschuere on 4/19/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import "RouteCell.h"
#import "StopInRouteTableViewCell.h"

@implementation RouteCell

- (void) setStops:(NSArray *)stops{
    _stops = stops;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.stopsTableView reloadData];
    }];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.stops.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    StopInRouteTableViewCell *cell = (StopInRouteTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"stopInRouteCell" forIndexPath:indexPath];
    
    if (indexPath.row != self.stops.count-1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSDictionary* stop = self.stops[indexPath.row];
    
    cell.stopOrder.text = [@(indexPath.row+1) stringValue];
    cell.stopName.text = stop[@"Name"];
    cell.stopID.text = [stop[@"ID"] stringValue];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
