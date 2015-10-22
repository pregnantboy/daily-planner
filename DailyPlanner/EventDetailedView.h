//
//  EventDetailedView.h
//  DailyPlanner
//
//  Created by Soham Ghosh on 17/10/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EventObject.h"

@interface EventDetailedView : UIView
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *locationText;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *reminder;
@property (weak, nonatomic) IBOutlet UILabel *notes;
- (IBAction)clickSuggestLocation:(id)sender;

- (id) initWithEventObject:(EventObject *)event;
@property (strong, nonatomic) IBOutlet UIButton *suggestLocationButton;

@end
