//
//  EventTableViewCell.m
//  DailyPlanner
//
//  Created by Ian Chen on 10/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import "EventTableViewCell.h"

@implementation EventTableViewCell

- (void)awakeFromNib {
    [self setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:0.4]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

// remove weird left padding for cell separation
- (UIEdgeInsets)layoutMargins {
    return UIEdgeInsetsZero;
}

@end
