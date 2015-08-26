//
//  ViewController.h
//  AmosSportCalender
//
//  Created by Amos Wu on 15/7/3.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTCalendar.h"
#import "WeixinActivity.h"

@class SummaryViewController;

@interface ViewController : UIViewController<JTCalendarDelegate>

@property (strong, nonatomic)NSArray *activity;

@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (weak, nonatomic) IBOutlet JTHorizontalCalendarView *calendarContentView;

@property (strong, nonatomic) JTCalendarManager *calendarManager;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarContentViewHeight;
@property (nonatomic, strong)SummaryViewController *summaryVC;

@end

