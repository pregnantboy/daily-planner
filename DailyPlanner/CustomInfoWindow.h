//
//  CustomInfoWindow.h
//  DailyPlanner
//
//  Created by Soham Ghosh on 30/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomInfoWindow : UIView
@property (weak, nonatomic) IBOutlet UILabel *placeTitle;
- (IBAction)clickConfirm:(UIButton *)sender;

@end
