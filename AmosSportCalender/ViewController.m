//
//  ViewController.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/7/3.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

// TODO: [something]
// MARK: [something]
// FIXME: [something]

#import "ViewController.h"
#import "NewEvevtViewController.h"
#import "Event.h"
#import "EventStore.h"
#import "SportTVCell.h"
#import "LeftMenuTableView.h"

#import "UIViewController+MMDrawerController.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableDictionary *eventsByDate; ///<储存所有事件的Dic
    
    NSDate *_todayDate;
    NSDate *_minDate;
    NSDate *_maxDate;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDate* selectedDate; ///<被选择的当天日期，用作key
@property (nonatomic, strong) NSMutableArray *oneDayEvents; ///<被选择当天的事件数组Array
@property (nonatomic, strong) NSMutableDictionary *doneNumbers; ///<储存完成项目数的字典
@property (nonatomic, strong) NSNumber *doneNumber; ///<已经完成的项目数

@property (nonatomic, strong) ViewController *vc;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UILabel *underTableLabel;
@property (weak, nonatomic) IBOutlet UIView *addButtonView;

//@property (nonatomic, strong) Event *event;
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
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _calendarManager = [JTCalendarManager new];
    _calendarManager.delegate = self;
    _calendarManager.settings.weekDayFormat = JTCalendarWeekDayFormatShort;
    _calendarManager.dateHelper.calendar.locale = [NSLocale currentLocale];
    
    _todayDate = [NSDate date];
    
    [_calendarManager setMenuView:_calendarMenuView];
    [_calendarManager setContentView:_calendarContentView];
    [_calendarManager setDate:_todayDate];
    
    //init
    self.selectedDate = [NSDate date];
    self.doneNumbers = [NSMutableDictionary dictionary];
    
    //长按移动cell顺序
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:longPress];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadTheDateEvents];
    
}

- (void)loadTheDateEvents
{
    //init
    self.oneDayEvents = [NSMutableArray array];
    //载入key
    NSString *key = [[self dateFormatter] stringFromDate:self.selectedDate ? self.selectedDate : [NSDate date]];
    
    eventsByDate = [[NSMutableDictionary alloc] initWithDictionary:[[EventStore sharedStore] allItems] copyItems:NO];
    self.oneDayEvents = eventsByDate[key];
    [self setUnderTableLabelWithDifferentDay: self.selectedDate];
    
    [self.tableView reloadData];
}

- (void)setUnderTableLabelWithDifferentDay: (NSDate *)date
{
    int i = 0;
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    //计算这一天有多少已完成的事件
    if (self.oneDayEvents) {
        for (Event *event in self.oneDayEvents) {
            if (event.done == YES) {
                i ++;
            }
        }}

    NSLog(@"i = %d", i);
    
    [_calendarManager reload];
    
    //设置显示的文字
    if (self.oneDayEvents.count > 0) {
        self.addButtonView.hidden = YES;
        if (self.oneDayEvents.count > i) {
            self.underTableLabel.text = [NSString stringWithFormat:@"共有%lu个运动项目，已完成%d项，还剩%lu项", (unsigned long)self.oneDayEvents.count, i, self.oneDayEvents.count - i];
        }else if (self.oneDayEvents.count == i){
            self.underTableLabel.text = [NSString stringWithFormat:@"今天的运动已经全部完成了，干得好！"];
        }
    }else{
        self.addButtonView.hidden = NO;
        self.underTableLabel.text = [NSString stringWithFormat:@"今天没有运动，做个计划吧！"];
    }
    
    self.doneNumber = [NSNumber numberWithInt:i];
    self.doneNumbers[key] = self.doneNumber;
}
#pragma mark - click the Date

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
    
    //重新载入一遍数据
    [self loadTheDateEvents];
    NSLog(@"Date: %@ - %ld events", mydate, (unsigned long)[self.oneDayEvents count]);
}

#pragma mark - Buttons callback
- (IBAction)addNewEvent:(UIButton *)sender {
    
    [self creatTheNewEvent];
}

- (void)prepareForSegue:(nonnull UIStoryboardSegue *)segue sender:(nullable id)sender
{
    if ([segue.identifier isEqualToString:@"newEvent"]) {
        UINavigationController *nc = (UINavigationController *)segue.destinationViewController;
        NewEvevtViewController *mvc = (NewEvevtViewController *)[nc topViewController];
        
        Event *newEvent = [[EventStore sharedStore] createItem];
        mvc.event = newEvent;
        
        if (_selectedDate) {
            mvc.date = _selectedDate;
        }else{
            mvc.date = [NSDate date];
        }
    }
}

- (void)creatTheNewEvent
{
    [self performSegueWithIdentifier:@"newEvent" sender:self];
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

//往下滑动week模式改为全日期模式
- (IBAction)changeToMonthMode
{
    if (_calendarManager.settings.weekModeEnabled) {
        [self transitionExample];
    }
}
//滑动Table改为week视图
- (void)scrollViewWillBeginDragging:(nonnull UIScrollView *)scrollView
{
    if (!_calendarManager.settings.weekModeEnabled) {
        [self transitionExample];
    }
}
//改变日历视图的动画
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

- (BOOL)haveEventForDay:(NSDate *)date
{
    //    NSLog(@"haveEventForDay:判断每一天是否有事件");
    
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    int i = [self.doneNumbers[key] intValue];
    
    if(eventsByDate[key] && [eventsByDate[key] count] > 0){
        
        if ([eventsByDate[key] count] > i) {
            return YES;
        }else if([eventsByDate[key] count] == i){
            return NO;
        }
    }
    
    return NO;
}

- (BOOL)eventsAllDoneForDay:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    int i = [self.doneNumbers[key] intValue];
    
    if(eventsByDate[key] && [eventsByDate[key] count] > 0){
        
        if ([eventsByDate[key] count] == i) {
            return YES;
        }
    }
    return NO;
}

//根据Day所有完成的运动项目中，寻找数量最多的那一项
- (unsigned long)findTheMaxOfTypes:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    NSArray *sportTypes = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sportTypes" ofType:@"plist"]];
    NSUInteger k = sportTypes.count;

    NSMutableArray *numberArray = [NSMutableArray array];
    
    for (int i = 0; i < k; i++) {
        int a = 0;
        for (Event *event in eventsByDate[key]){
            if ([[sportTypes[i] objectForKey:@"sportType"] isEqualToString:event.sportType]) {
                a++;
            }
        }
        [numberArray addObject:[NSNumber numberWithInt:a]];
    }
    
    int max = [self findMaxInArray:numberArray];
    NSNumber *maxNumber = [NSNumber numberWithInt:max];
    unsigned long index = 0;
    index = [numberArray indexOfObject:maxNumber];
    NSLog(@"最多的元素下标是: %ld", index);
    
    return index;
}

//设置不同完成后标记颜色的方法
- (UIColor *)colorForDoneEventsMark:(unsigned long)index
{
    if (index == 0) {
        return [UIColor colorWithRed:0.5725 green:0.3216 blue:0.0667 alpha:1];
    }else if (index == 1){
        return [UIColor colorWithRed:0.5725 green:0.5608 blue:0.1059 alpha:1];
    }else if (index == 2){
        return [UIColor colorWithRed:0.3176 green:0.5569 blue:0.0902 alpha:1];
    }else if (index == 3){
        return [UIColor colorWithRed:0.0824 green:0.5686 blue:0.5725 alpha:1];
    }else if (index == 4){
        return [UIColor colorWithRed:0.9922 green:0.5765 blue:0.1490 alpha:1];
    }else if (index == 5){
        return [UIColor colorWithRed:0.9922 green:0.2980 blue:0.9882 alpha:1];
    }else if (index == 6){
        return [UIColor colorWithRed:0.5686 green:0.9686 blue:0.1882 alpha:1];
    }
    
    return [UIColor clearColor];
}

#pragma mark - CalendarManager delegate

// Exemple of implementation of prepareDayView method
// Used to customize the appearance of dayView
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
//    NSLog(@"prepareDayView");
    
    // Today
    if([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor colorWithRed:0.5961 green:0.8471 blue:0.9608 alpha:0.8];
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
    }else{
        dayView.dotView.hidden = YES;
    }
    
    if ([self eventsAllDoneForDay:dayView.date]) {
        dayView.finishView.hidden = NO;
        unsigned long index = [self findTheMaxOfTypes:dayView.date];
        dayView.finishView.layer.borderColor = [[self colorForDoneEventsMark:index] CGColor];
    }else{
        dayView.finishView.hidden = YES;
    }
}
//Menu视图属性
- (UIView *)calendarBuildMenuItemView:(JTCalendarManager *)calendar
{
    UILabel *label = [UILabel new];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Avenir-Medium" size:18];
    
    return label;
}
//Menu视图字体
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
//    NSLog(@"calendarBuildDayView");
    
    JTCalendarDayView *view = [JTCalendarDayView new];
    
    view.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:13];
    
    view.circleRatio = .8;
    
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
    
//    NSLog(@"+ 重载cell");
    Event *event = self.oneDayEvents[indexPath.row];
    cell.event = event;
    
    return cell;
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
//    SportTVCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    Event *event = self.oneDayEvents[indexPath.row];
    
    if (event.done == NO){
        
        event.done = YES;
        
        [[EventStore sharedStore] moveItemAtIndex:indexPath.row toIndex:self.oneDayEvents.count - 1 date:self.selectedDate];
        
        NSIndexPath *fromIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        NSUInteger row = [self.oneDayEvents count] - 1;
        NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
        
        if (![fromIndexPath isEqual: toIndexPath]) {
        [self.tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
        }
        
//        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:toIndexPath] withRowAnimation:UITableViewRowAnimationRight];
        
//        NSLog(@"- No to Yes");
    }else{
        event.done = NO;
        
        [[EventStore sharedStore] moveItemAtIndex:indexPath.row toIndex:0 date:self.selectedDate];
        
        NSIndexPath *fromIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];

        [self.tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];

//        NSLog(@"~ Yes to No");
    }
    
//    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self setUnderTableLabelWithDifferentDay: self.selectedDate];
    [_calendarManager reload];
    [self.tableView reloadData];
}

- (nullable NSString *)tableView:(nonnull UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    unsigned long index = [self findTheMaxOfTypes:self.selectedDate];
    NSArray *sportTypes = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sportTypes" ofType:@"plist"]];
    NSString *blankStr = @"";
    
    if (section == 0) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd EEEE";
        
        return ([self.doneNumber intValue] > 0)?
        [NSString stringWithFormat:@"%@ - %@",[dateFormatter stringFromDate:self.selectedDate],
        [sportTypes[index] objectForKey:@"sportType"]?
        [sportTypes[index] objectForKey:@"sportType"]:blankStr]
        :
        [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:self.selectedDate]];
        
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return 55;
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
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Event *event = self.oneDayEvents[indexPath.row];
        [[EventStore sharedStore] removeItem:event date:self.selectedDate];
        
        //删除表格中的相应行
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [_calendarManager reload];
        [self setUnderTableLabelWithDifferentDay: self.selectedDate];
        
        if (self.oneDayEvents.count == 0) {
            [self loadTheDateEvents];
        }
    }
}

#pragma mark - 长按移动cell顺序

- (IBAction)longPressGestureRecognized:(id)sender {
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshoFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    cell.alpha = 0.0;
                    
                } completion:^(BOOL finished) {
                    
                    cell.hidden = YES;
                    
                }];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
                // ... update data source.
                [[EventStore sharedStore] moveItemAtIndex:indexPath.row toIndex:sourceIndexPath.row date:self.selectedDate];

                // ... move the rows.
                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            break;
        }
            
        default: {
            // Clean up.
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            cell.hidden = NO;
            cell.alpha = 0.0;
            
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                cell.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
                
            }];
            
            break;
        }
    }
}

#pragma mark - Helper methods

/** @brief Returns a customized snapshot of a given view. */
- (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

#pragma mark - 求数组中最大值的方法

- (int)findMaxInArray:(NSArray *)array
{
    int max = 0;
    max = [array[0] intValue];
    for (int i = 1; i < array.count; i++) {
        if ([array[i] intValue] > max) {
            max = [array[i] intValue];
        }
    }
    return max;
}

@end
