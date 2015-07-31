//
//  ViewController.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/7/3.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "ViewController.h"
#import "NewEvevtViewController.h"
#import "Event.h"
#import "SportTVCell.h"
#import "LeftMenuTableView.h"

#import "UIViewController+MMDrawerController.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableDictionary *eventsByDate;
    
    NSDate *_todayDate;
    NSDate *_minDate;
    NSDate *_maxDate;

}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDate* selectedDate;
@property (nonatomic, strong) NSMutableArray *oneDayEvents;
@property (nonatomic, strong) ViewController *vc;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@property (nonatomic, strong) Event *event;
@end

@implementation ViewController
@synthesize leftmenu;

- (void)setSelectedDate:(NSDate *)selectedDate
{
    _selectedDate = selectedDate;
    
}

#pragma mark - life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _calendarManager = [JTCalendarManager new];
    _calendarManager.delegate = self;
    _calendarManager.settings.weekDayFormat = JTCalendarWeekDayFormatShort;
    _calendarManager.dateHelper.calendar.locale = [NSLocale currentLocale];
    
    _todayDate = [NSDate date];
    
    [_calendarManager setMenuView:_calendarMenuView];
    [_calendarManager setContentView:_calendarContentView];
    [_calendarManager setDate:_todayDate];
    
    eventsByDate = [NSMutableDictionary new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadTheDateEvents];
}

- (void)loadTheDateEvents
{
    self.oneDayEvents = [NSMutableArray array];
    NSString *key = [[self dateFormatter] stringFromDate:self.selectedDate ? self.selectedDate : [NSDate date]];
    
    if(!eventsByDate[key])
    {
        eventsByDate[key] = [NSMutableArray array];
    }
    self.oneDayEvents = eventsByDate[key];
    
    [_calendarManager reload];
    [self.tableView reloadData];
    
}

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
        NSTimeZone *localZone=[NSTimeZone localTimeZone];
        NSInteger interval=[localZone secondsFromGMTForDate:dayView.date];
        NSDate *mydate=[dayView.date dateByAddingTimeInterval:interval];
    
    self.selectedDate = mydate;
    
    // Animation for the circleView
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView transitionWithView:dayView
                      duration:.3
                       options:0
                    animations:^{
                        dayView.circleView.transform = CGAffineTransformIdentity;
                        [_calendarManager reload];
                    } completion:nil];
    
    // Load the previous or next page if touch a day from another month
    
    if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        if([_calendarContentView.date compare:dayView.date] == NSOrderedAscending){
            [_calendarContentView loadNextPageWithAnimation];
        }
        else{
            [_calendarContentView loadPreviousPageWithAnimation];
        }
    }
    
    [self loadTheDateEvents];
    NSLog(@"Date: %@ - %ld events", mydate, [self.oneDayEvents count]);
}

#pragma mark - Buttons callback

- (void)prepareForSegue:(nonnull UIStoryboardSegue *)segue sender:(nullable id)sender
{
    if ([segue.identifier isEqualToString:@"newEvent"]) {
        UINavigationController *nc = (UINavigationController *)segue.destinationViewController;
        NewEvevtViewController *mvc = (NewEvevtViewController *)[nc topViewController];
        
        //初始化一遍Event *
        Event *newEvent = [[Event alloc] init];
        
        if (_selectedDate) {
            mvc.date = _selectedDate;
        }else{
            mvc.date = [NSDate date];
        }
        
        mvc.event = newEvent;
        
        NSString *key = [[self dateFormatter] stringFromDate:_selectedDate ? _selectedDate : [NSDate date]];
        
        if(!eventsByDate[key])
        {
            eventsByDate[key] = [NSMutableArray array];
        }
        
        [eventsByDate[key] addObject:newEvent];
        
    }
}
- (IBAction)segmentedControl:(UISegmentedControl *)sender {
    
    switch ([sender selectedSegmentIndex]) {
        case 0:
            NSLog(@"first click");
            
            break;
            
        case 1:
            NSLog(@"second click");
            
//            leftmenu = [[LeftMenuTableView alloc] init];
//            [self.view addSubview:leftmenu.view];
            break;
            
        default:
            break;
    }
}
- (IBAction)openAndCloseDrower:(UIBarButtonItem *)sender {
    
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (IBAction)didGoTodayTouch
{
    [_calendarManager setDate:_todayDate];
}

- (IBAction)changeToMonthMode
{
    if (_calendarManager.settings.weekModeEnabled) {
        [self transitionExample];
    }
}

- (void)scrollViewWillBeginDragging:(nonnull UIScrollView *)scrollView
{
    if (!_calendarManager.settings.weekModeEnabled) {
        [self transitionExample];
    }
}

- (void)transitionExample
{
    _calendarManager.settings.weekModeEnabled = !_calendarManager.settings.weekModeEnabled;
    [_calendarManager reload];
    
    CGFloat newHeight = 300;
    if(_calendarManager.settings.weekModeEnabled){
        newHeight = 85.;
    }
    
    [UIView animateWithDuration:.5
                     animations:^{
                         self.calendarContentViewHeight.constant = newHeight;
                         [self.view layoutIfNeeded];
                     }];
    
    [UIView animateKeyframesWithDuration:.5
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionCalculationModeLinear
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 //相对的起始时间,是百分比,范围0-1
                                                          relativeDuration:0.5 //相对持续时间，范围0-1
                                                                animations:^{
                                                        self.calendarContentView.layer.opacity = 0;
                                                                }];
                                  [UIView addKeyframeWithRelativeStartTime:0.5
                                                          relativeDuration:0.5
                                                                animations:^{
                                                        self.calendarContentView.layer.opacity = 1;
                                                                }];
                              } completion:^(BOOL finished) {
                                  
                     }];
}

#pragma mark - CalendarManager delegate

// Exemple of implementation of prepareDayView method
// Used to customize the appearance of dayView
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
    // Today
    if([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor colorWithRed:0.5961 green:0.8471 blue:0.9608 alpha:1];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Selected date
    else if(_selectedDate && [_calendarManager.dateHelper date:_selectedDate isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor redColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Other month
    else if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor lightGrayColor];
    }
    // Another day of the current month
    else{
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor blackColor];
    }
    
    if([self haveEventForDay:dayView.date]){
        dayView.dotView.hidden = NO;
    }
    else{
        dayView.dotView.hidden = YES;
    }
}

- (UIView *)calendarBuildMenuItemView:(JTCalendarManager *)calendar
{
    UILabel *label = [UILabel new];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Avenir-Medium" size:18];
    
    return label;
}

/*!
 * Used to customize the menuItemView.
 * Set text attribute to the name of the month by default.
 */
- (void)calendar:(JTCalendarManager *)calendar prepareMenuItemView:(UILabel *)menuItemView date:(NSDate *)date
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy - MMMM";
        
        dateFormatter.locale = _calendarManager.dateHelper.calendar.locale;
        dateFormatter.timeZone = _calendarManager.dateHelper.calendar.timeZone;
    }
    
    menuItemView.text = [dateFormatter stringFromDate:date];
}

//星期view的自定义
- (UIView<JTCalendarWeekDay> *)calendarBuildWeekDayView:(JTCalendarManager *)calendar
{
    JTCalendarWeekDayView *view = [JTCalendarWeekDayView new];
    
    for(UILabel *label in view.dayViews){
        label.textColor = [UIColor blackColor];
        label.font = [UIFont fontWithName:@"Avenir-Light" size:12];
    }
    
    return view;
}

- (UIView<JTCalendarDay> *)calendarBuildDayView:(JTCalendarManager *)calendar
{
    JTCalendarDayView *view = [JTCalendarDayView new];
    
    view.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:13];
    
    view.circleRatio = .8;
//    view.dotRatio = 1. / .9;
    
    return view;
}

// Used only to have a key for _eventsByDate
- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }
    
    return dateFormatter;
}

- (BOOL)haveEventForDay:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    if(eventsByDate[key] && [eventsByDate[key] count] > 0){
        return YES;
    }
    
//    if([date isEqualToDate:[[self dateFormatter] dateFromString:@"24-7-2015"]]){
//        return YES;
//    }
    
    return NO;
    
}

#pragma mark - CalendarManager delegate - Page mangement

- (void)calendarDidLoadNextPage:(JTCalendarManager *)calendar
{
        NSLog(@"Next page loaded");
}

- (void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar
{
        NSLog(@"Previous page loaded");
}

#pragma mark - tableview

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.oneDayEvents) {
        return self.oneDayEvents.count;
    }else{
        return 0;
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    SportTVCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    self.event = self.oneDayEvents[indexPath.row];
    cell.event = self.event;
    
    return cell;
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
    SportTVCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (self.event.done == NO){
        self.event.done = YES;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        self.event.done = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (nullable NSString *)tableView:(nonnull UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return [NSString stringWithFormat:@"%@", [[self dateFormatter] stringFromDate:self.selectedDate ? self.selectedDate : [NSDate date]]];
    }else{
        return nil;
    }
}

#pragma mark - TableView的操作

//这两个方法是必须的
-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

//实现协议规定的方法，需要向UITableView发送该消息
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
