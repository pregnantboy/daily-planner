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
#import "MapViewController.h"

@interface EventDetailedView : UIView <MapViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *locationText;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *reminder;
@property (weak, nonatomic) IBOutlet UILabel *notes;
@property (strong, nonatomic) IBOutlet UIButton *suggestLocationButton;

- (id) initWithEventObject:(EventObject *)event andViewController:(UIViewController *) vc;

@end
