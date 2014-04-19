//
//  StopCell.m
//  Transport
//
//  Created by Chris Vanderschuere on 4/19/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import "StopCell.h"
#import "TimePair.h"

@implementation StopCell

- (void) setTimes:(NSArray *)times{
    _times = times;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.timesTableView reloadData];
    }];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.times.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timeCell" forIndexPath:indexPath];
    cell.textLabel.text = [NSDateFormatter localizedStringFromDate:[self.times[indexPath.row] expected] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
