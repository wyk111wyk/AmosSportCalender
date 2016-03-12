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

#import <LocalAuthentication/LocalAuthentication.h>
#import <Security/Security.h>
#import <QuartzCore/QuartzCore.h>

#import "CommonMarco.h"
#import "ViewController.h"
#import "SportTVCell.h"
#import "SummaryViewController.h"
#import "SettingTableView.h"
#import "RESideMenu.h"
#import "WXApi.h"
#import "MobClick.h"
#import "NYSegmentedControl.h"
#import "YYKit.h"
#import "NewEventVC.h"
#import "MGSwipeButton.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate, WXApiDelegate, MGSwipeTableCellDelegate>
{
    NSMutableDictionary *eventsByDate; ///<储存所有事件的Dic
    
    NSDate *_todayDate;
    NSDate *_minDate;
    NSDate *_maxDate;
}

@property (strong, nonatomic)NSMutableDictionary *eventsMostByDate; ///<每一天练的项目，例如胸部
@property (strong, nonatomic)NSArray *rightButtons; ///<日历页面的Menu Button Set

@property (strong, nonatomic) IBOutlet UIView *rootView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *underTableLabel;
@property (weak, nonatomic) IBOutlet UIButton *addEventButton;
@property (weak, nonatomic) IBOutlet UIButton *addToCalendarButton;

//Data
@property (nonatomic, strong) NSDate* selectedDate; ///<被选择的当天日期，用作key
@property (nonatomic, strong) NSMutableArray *allSelectDayEvents; ///<选择的那一天的所有运动
@property (nonatomic, strong) NSString *dayPartText; ///<当天最多的类型

@property (nonatomic) NSInteger applicationIconBadgeNumber;

@end

@implementation ViewController

- (void)setSelectedDate:(NSDate *)selectedDate
{
    _selectedDate = selectedDate;
}

#pragma mark - Lift Cycle

- (void)loadView
{
    [super loadView];
    //侧边栏打开的手势
    [self.sideMenuViewController setPanFromEdge:YES];
    
    //获取用户权限发送通知
    [[ASBaseManage sharedManage] getTheAuthorityOfNofication];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //初始数据
    _todayDate = [NSDate date];
    self.selectedDate = [NSDate date];
    
    //TableView初始化
    [self initTheTableView];
    [self initNavBarButtons];
    [self initTheSegmentSwitch];
    //日历初始化
    [self initTheCalendarManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAllData) name:RefreshRootPageEventsNotifcation object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self loadTheDateEvents:_selectedDate];
}

- (void)viewDidAppear:(BOOL)animated
{
    [_calendarManager reload];
    [super viewDidAppear:animated];
}

- (void)refreshAllData{
    [self loadTheDateEvents:_selectedDate];
    [_calendarManager setDate:_selectedDate];
    [self.tableView reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 载入数据和处理

- (void)loadTheDateEvents: (NSDate *)seDate
{
    NSString *dateKey = [[ASBaseManage dateFormatterForDMY] stringFromDate:seDate];
    NSString *criStr = [NSString stringWithFormat:@" WHERE dateKey = '%@' ORDER BY eventTimeStamp ", dateKey];
    _allSelectDayEvents = [[NSMutableArray alloc] initWithArray:[SportRecordStore findByCriteria:criStr]];
    if (_allSelectDayEvents.count > 0) {
        NSString *maxPart = [[ASBaseManage sharedManage] findTheMaxOfTypes:_allSelectDayEvents.copy];
        _dayPartText = maxPart;
    }
    
    //更新文字说明
    [self updateTableViewHeadTitle];
    //更新今天没有完成的数目的角标
    [self updateBadgeNumber];
}

- (void)updateBadgeNumber {
    dispatch_async(dispatch_get_main_queue(), ^{
    
        SettingStore *setting = [SettingStore sharedSetting];
        if (setting.iconBadgeNumber) {
            //设置桌面的数字角标
            
            NSString *dateKey = [[ASBaseManage dateFormatterForDMY] stringFromDate:_todayDate];
            NSString *criStr = [NSString stringWithFormat:@" WHERE dateKey = '%@' ORDER BY eventTimeStamp ", dateKey];
            NSArray *todayAllEvents = [SportRecordStore findByCriteria:criStr];
            NSInteger eventCount = todayAllEvents.count;
            NSInteger doneCount = 0;
            
            for (SportRecordStore *recordStore in todayAllEvents){
                if (recordStore.isDone) {
                    doneCount ++;
                }
            }
            
            NSInteger leftCount = eventCount - doneCount;
            if (leftCount > 0){
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:leftCount];
            }else{
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
            }
        }
    });
}

- (void)updateTableViewHeadTitle {
    NSInteger eventCount = _allSelectDayEvents.count;
    PersonInfoStore *personal = [PersonInfoStore sharedSetting];
    //设置添加日程的Button
    if (_calendarManager.settings.weekModeEnabled && eventCount > 0) {
        self.addToCalendarButton.hidden = NO;
    }else{
        self.addToCalendarButton.hidden = YES;
    }
    
    if (eventCount > 0) {
        NSInteger doneCount = 0;
        for (SportRecordStore *recordStore in _allSelectDayEvents){
            if (recordStore.isDone) {
                doneCount ++;
            }
        }
        NSInteger leftCount = eventCount - doneCount;
    
        self.addEventButton.hidden = YES;
        
        if (leftCount == 0) {
            //都完成了
            if (personal.name.length > 0) {
                self.underTableLabel.text = [NSString stringWithFormat:Local(@"All events have done today，%@，well done!"), personal.name];
            }else{
                self.underTableLabel.text = [NSString stringWithFormat:Local(@"All events have done today，well done!")];
            }
        }else {
            if (personal.name.length > 0){
                self.underTableLabel.text = [NSString stringWithFormat:Local(@"%@，all %@ events，now %d done，%@ more left"), personal.name, @(eventCount), @(doneCount), @(leftCount)];
            }else{
                self.underTableLabel.text = [NSString stringWithFormat:Local(@"all %@ events，now %@ done，%@ more left"),  @(eventCount), @(doneCount), @(leftCount)];
            }
        }
    }else {
        //没有设置运动
        self.addEventButton.hidden = NO;
        NSArray *showingTextArr = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"homePageShow.plist" ofType:nil]];
        int i = arc4random() % showingTextArr.count;
        self.underTableLabel.text = showingTextArr[i];
    }
}

#pragma mark - UI组件初始化

- (void)initTheTableView {
    //TableView初始化
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)initNavBarButtons {
    //NavBar初始化
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus"] style:UIBarButtonItemStylePlain target:nil action:nil];
    [addButton setActionBlock:^(id _Nonnull sender) {
        [self alertForChooseCreate];
    }];
    [_addEventButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        [self alertForChooseCreate];
    }];
    UIBarButtonItem *todayButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"present"]  style:UIBarButtonItemStylePlain target:nil action:nil];
    [todayButton setActionBlock:^(id _Nonnull sender) {
        [self didGoTodayTouch];
    }];
    _rightButtons = [[NSArray alloc] initWithObjects: addButton, todayButton, nil];
    self.navigationItem.rightBarButtonItems = _rightButtons;
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menuIcon"] style:UIBarButtonItemStylePlain target:self action:nil];
    [menuButton setActionBlock:^(id _Nonnull sender) {
        [self.sideMenuViewController presentLeftMenuViewController];
    }];
    self.navigationItem.leftBarButtonItem = menuButton;
}

- (void)initTheSegmentSwitch {
    NYSegmentedControl *segmentedControl = [[NYSegmentedControl alloc] initWithItems:@[Local(@"Cal"), Local(@"Sum")]];
    [segmentedControl addBlockForControlEvents:UIControlEventValueChanged block:^(id  _Nonnull sender) {
        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"upload"] style:UIBarButtonItemStylePlain target:self action:@selector(alertForShare)];
        
        switch ([sender selectedSegmentIndex]) {
            case 0:
                //日历页面
                
                [[self.view.subviews lastObject] removeFromSuperview];
                self.navigationItem.rightBarButtonItem = nil;
                self.navigationItem.rightBarButtonItems = self.rightButtons;
                
                self.addEventButton.enabled = YES;
                [self updateTableViewHeadTitle];
                break;
                
            case 1:
                //数据展示页面
                
                if (self.calendarManager.settings.weekModeEnabled) {
                    [self transitionExample];
                    [self.calendarManager reload];
                    [self updateTableViewHeadTitle];
                }
                
                //View Changes to Today
                [self didGoTodayTouch];
                
                self.summaryVC = [[SummaryViewController alloc] init];
//                self.summaryVC.eventsMostByDate = self.eventsMostByDate;
                
                self.navigationItem.rightBarButtonItems = nil;
                self.navigationItem.rightBarButtonItem = shareButton;
                
                self.addEventButton.enabled = NO;
                [self.view addSubview:self.summaryVC.view];
                
                break;
                
            default:
                break;
        }
    }];
    segmentedControl.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    segmentedControl.segmentIndicatorBackgroundColor = MyWhite;
    segmentedControl.segmentIndicatorInset = 0.0f;
    segmentedControl.titleTextColor = MyLightGray;
    segmentedControl.selectedTitleTextColor = MyDarkGray;
    segmentedControl.usesSpringAnimations = YES;
    segmentedControl.selectedSegmentIndex = 0;
    
    [segmentedControl sizeToFit];
    self.navigationItem.titleView = segmentedControl;
}

- (void)initTheCalendarManager {
    //日历初始化
    _calendarManager = [JTCalendarManager new];
    _calendarManager.delegate = self;
    _calendarManager.settings.weekDayFormat = JTCalendarWeekDayFormatShort;
    _calendarManager.dateHelper.calendar.locale = [NSLocale currentLocale];
    //每周的第一天是星期几
    SettingStore *setting = [SettingStore sharedSetting];
    if (setting.firstDayOfWeek) {
        [_calendarManager.dateHelper.calendar setFirstWeekday:1];
    }else{
        [_calendarManager.dateHelper.calendar setFirstWeekday:2];
    };
    
    [_calendarManager setMenuView:_calendarMenuView];
    [_calendarManager setContentView:_calendarContentView];
    [_calendarManager setDate:_todayDate];
    
    //载入前后几周多少数据
    // Min date will be 2 month before today
    _minDate = [_calendarManager.dateHelper addToDate:_todayDate months:-2];
    // Max date will be 2 month after today
    _maxDate = [_calendarManager.dateHelper addToDate:_todayDate months:2];
}

#pragma mark - 创建新的运动项目

- (void)alertForChooseCreate
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"选择新建项目"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"一项运动"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                
        NewEventVC *newEvent = [[NewEventVC alloc] init];
        SportRecordStore *recordStore = [SportRecordStore new];
        recordStore.eventTimeStamp = [_selectedDate timeIntervalSince1970];
        recordStore.dateKey = [[ASBaseManage dateFormatterForDMY] stringFromDate:_selectedDate];
        newEvent.pageState = 0;
        newEvent.recordStore = recordStore;
        UINavigationController *newNav = [[UINavigationController alloc] initWithRootViewController:newEvent];
        [self presentViewController:newNav animated:YES completion:nil];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"精选组合"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"sportGroupNav"] animated:YES];
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Buttons Method

- (void) didGoTodayTouch {
    _selectedDate = _todayDate;
    [_calendarManager setDate:_todayDate];
    [self loadTheDateEvents:_todayDate];
    
    [_tableView reloadData];
}

//滑动改变日历视图
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"scroll Y: %@", @(scrollView.contentOffset.y));
    if (_calendarManager.settings.weekModeEnabled) {
        //变为完整日历视图
        if (scrollView.contentOffset.y < -5) {
            [self transitionExample];
        }
        NSInteger eventCount = _allSelectDayEvents.count;
        //设置添加日程的Button
        if (eventCount > 0) {
            self.addToCalendarButton.hidden = NO;
        }
    }else {
        //变为周视图
        if (scrollView.contentOffset.y > 5) {
            [self transitionExample];
        }
        self.addToCalendarButton.hidden = YES;
    }
    [_calendarManager reload];
}

//改变日历视图的动画
- (void)transitionExample {
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

- (IBAction)addToCalendar:(UIButton *)sender {
    [[ASBaseManage sharedManage] checkEventStoreAccessForCalendarWithdayEvents:_allSelectDayEvents seDate:_selectedDate dayPart:_dayPartText view:self];
}

#pragma mark - 点击一个日期

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
    
    if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:mydate]){
        if([_calendarContentView.date compare:mydate] == NSOrderedAscending){
            [_calendarContentView loadNextPageWithAnimation];
        }
        else{
            [_calendarContentView loadPreviousPageWithAnimation];
        }
    }
    
    //重新载入一遍数据
    [self loadTheDateEvents:mydate];
    [self.tableView reloadData];
}

#pragma mark - CalendarManager delegate

//每一天的View的载入
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
    NSTimeZone *localZone = [NSTimeZone localTimeZone];
    NSInteger interval = [localZone secondsFromGMTForDate:dayView.date];
    NSDate *mydate = [dayView.date dateByAddingTimeInterval:interval];
    
    // Today
    if([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:mydate]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor colorWithRed:0.5961 green:0.8471 blue:0.9608 alpha:0.7];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Selected date
    else if(_selectedDate && [_calendarManager.dateHelper date:_selectedDate isTheSameDayThan:mydate]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor redColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
        dayView.finishView.hidden = YES;
    }
    // Other month
    else if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:mydate]){
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
    
    NSString *dayKey = [[ASBaseManage dateFormatterForDMY] stringFromDate:mydate];
    NSArray *dayEvents = [SportRecordStore findWithFormat:@" WHERE dateKey = '%@' ", dayKey];
    if (dayEvents.count > 0) {
        NSInteger doneCount = 0;
        NSString *maxPart = [[ASBaseManage sharedManage] findTheMaxOfTypes:dayEvents];
        
        for (SportRecordStore *recordStore in dayEvents){
            if (recordStore.isDone) {
                doneCount ++;
            }
        }
        NSInteger leftCount = dayEvents.count - doneCount;
        if (leftCount == 0) {
            //全部完成
            UIColor *cycleColor = [[ASBaseManage sharedManage] colorForsportType:maxPart];
            dayView.finishView.layer.borderColor = [cycleColor CGColor];
            dayView.finishView.hidden = NO;
            dayView.dotView.hidden = YES;
        }else {
            dayView.finishView.hidden = YES;
            dayView.dotView.hidden = NO;
        }
    }else{
        dayView.finishView.hidden = YES;
        dayView.dotView.hidden = YES;
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

//每天的字体和选圈的大小
- (UIView<JTCalendarDay> *)calendarBuildDayView:(JTCalendarManager *)calendar
{
    JTCalendarDayView *view = [JTCalendarDayView new];
    view.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:13];
    view.circleRatio = .8;
    return view;
}

#pragma mark - CalendarManager delegate - Page mangement

- (void)calendarDidLoadNextPage:(JTCalendarManager *)calendar
{
    if (DeBugMode) { NSLog(@"Next page loaded"); }
}

- (void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar
{
    if (DeBugMode) { NSLog(@"Previous page loaded");}
}

#pragma mark - Tableview Delegate


- (nullable UIView *)tableView:(nonnull UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //初始化自定义View
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth,20)];
    [headerView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    
    //设置Header的字体
    UILabel *headText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 20)];
    headText.textColor = [UIColor whiteColor];
    headText.textAlignment = NSTextAlignmentCenter;
    [headText setFont:[UIFont fontWithName:@"Arial" size:14]];
    headText.text = @"text";
    [headerView addSubview:headText];
    
    if (_allSelectDayEvents.count > 0) {
        UIColor *partColor = [[ASBaseManage sharedManage] colorForsportType:_dayPartText];
        headerView.backgroundColor = partColor;
        headText.text = [NSString stringWithFormat:@"%@ (%@)",[[ASBaseManage dateFormatterForDMYE] stringFromDate:self.selectedDate], _dayPartText];
    }else {
        headerView.backgroundColor = [UIColor colorWithWhite:0.55 alpha:0.7];
        headText.text = [NSString stringWithFormat:@"%@",[[ASBaseManage dateFormatterForDMYE] stringFromDate:self.selectedDate]];
    }
    
    return headerView;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return 55;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _allSelectDayEvents.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SportTVCell";
    SportTVCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:cellIdentifier owner:nil options:nil] firstObject];
        cell.delegate = self;
    }
    
    SportRecordStore *recordStore = _allSelectDayEvents[indexPath.row];
    cell.recordStore = recordStore;
    
    return cell;
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    SportRecordStore *recordStore = _allSelectDayEvents[indexPath.row];
    
    if (recordStore.sportType == 1) {
        //抗阻运动，点一下完成一个
        if (!recordStore.isDone) {
            NSInteger leftSets = recordStore.repeatSets - recordStore.doneSets;
            if (recordStore.repeatSets > 0) {
                if (leftSets > 0) {
                    recordStore.doneSets ++;
                }
            }
            if (recordStore.repeatSets == recordStore.doneSets) {
                //该运动全部完成
                recordStore.isDone = YES;
                if ([recordStore update]) {
                    [_calendarManager setDate:_selectedDate];
                    [self updateTableViewHeadTitle];
                    [[ASDataManage sharedManage] addNewDateEventRecord:recordStore];
                }
            }
        }
    }else {
        if (!recordStore.isDone) {
            recordStore.isDone = YES;
            if ([recordStore update]) {
                [_calendarManager setDate:_selectedDate];
                [self updateTableViewHeadTitle];
                [[ASDataManage sharedManage] addNewDateEventRecord:recordStore];
            }
        }
    }
    
    [tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - TableView Swipe Delegate
-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings;
{
    swipeSettings.transition = MGSwipeTransitionBorder; //划出来的动画效果
    expansionSettings.buttonIndex = 0;
    expansionSettings.animationDuration = .2; //滑到底触发时的动画时间
    expansionSettings.threshold = 2;
    expansionSettings.fillOnTrigger = YES;
    
    if (direction == MGSwipeDirectionLeftToRight) {
        return [[ASBaseManage sharedManage] createDoneAndUndoButtons];
    }else {
        expansionSettings.buttonIndex = -1;
        return [[ASBaseManage sharedManage] createDeleteAndEditButtons];
    }
}

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    SportRecordStore *recordStore = _allSelectDayEvents[indexPath.row];
    
    if (direction == MGSwipeDirectionLeftToRight) {
        if (index == 0) {
            //完成
            if (!recordStore.isDone) {
                recordStore.isDone = YES;
                recordStore.doneSets = recordStore.repeatSets;
                if ([recordStore update]) {
                    [[ASDataManage sharedManage] addNewDateEventRecord:recordStore];
                }
            }
        }else if (index == 1) {
            //重置
            recordStore.isDone = NO;
            recordStore.doneSets = 0;
            if ([recordStore update]) {
                [[ASDataManage sharedManage] editDateEventRecord:recordStore];
            }
        }
        [_calendarManager setDate:_selectedDate];
        [self updateTableViewHeadTitle];
        [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
    }else {
        if (index == 0) {
            //删除
            [self alertForDelete:recordStore indexPath:indexPath];
        }else if (index == 1) {
            //编辑
            NewEventVC *newEvent = [[NewEventVC alloc] init];
            newEvent.pageState = 1;
            newEvent.recordStore = recordStore;
            UINavigationController *newNav = [[UINavigationController alloc] initWithRootViewController:newEvent];
            [self presentViewController:newNav animated:YES completion:nil];
        }
    }
    
    return YES;
}

- (void)alertForDelete:(SportRecordStore *)recordStore indexPath:(NSIndexPath *)indexPath
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"删除这项运动"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确认"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * action) {
                                                if ([recordStore deleteObject]) {
                                                    [_allSelectDayEvents removeObject:recordStore];
                                                    [[ASDataManage sharedManage] editDateEventRecord:recordStore];
                                                    [_calendarManager setDate:_selectedDate];
                                                    [self.tableView deleteRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
                                                }
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Share

- (void)alertForShare
{
    UIImage *bottomImage = [[ASBaseManage sharedManage] scaleTheImage:[UIImage imageNamed:@"shareButtonImage"]];
    
    WeixinSessionActivity *weixinSession = [[WeixinSessionActivity alloc] init];
    WeixinTimelineActivity *weixinTimeLine = [[WeixinTimelineActivity alloc] init];
//    QQSessionAct *QQSession = [[QQSessionAct alloc] init];
//    QZoneAct *Qzone = [[QZoneAct alloc] init];
    
    _activity = @[weixinSession, weixinTimeLine];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:Local(@"What you wanna share with")
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    NSString *countStr = [NSString stringWithFormat:Local(@"Today's events(%@)"), @(self.allSelectDayEvents.count)];
    [alert addAction:[UIAlertAction actionWithTitle:countStr
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                
        UIImage *headerImg = [[ASBaseManage sharedManage] captureView:_tableView Rectsize:CGSizeMake(screenWidth, 20)];
        UIImage *tableImg = [self captureTableView:_tableView];
        UIImage *tempImg = [[ASBaseManage sharedManage] addImageview:tableImg toImage:headerImg];
        UIImage *img = [[ASBaseManage sharedManage] addImageview:bottomImage toImage:tempImg];
        [self shareThePersonalInfo:img];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Summary")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                         
//        UIImage *topImg1 = [self captureView:_calendarMenuView Rectsize:CGSizeMake(screenWidth, 50)];
        UIImage *topImg2 = [SummaryViewController captureView:self.summaryVC.view4];
//        UIImage *topImg = [self addImageview:topImg2 toImage:topImg1];
                                                
        UIImage *tempImg = [SummaryViewController captureView:self.summaryVC.view1];
        UIImage *bottomImg = [[ASBaseManage sharedManage] addImageview:topImg2 toImage:tempImg];
                                                
        UIImage *img = [[ASBaseManage sharedManage] addImageview:bottomImage toImage:bottomImg];
        [self shareThePersonalInfo:img];
                                            }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)shareThePersonalInfo:(UIImage *)img
{
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[img]
                                      applicationActivities:_activity];
    
    //不需要显示的部分
    activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint];
    
    [self.navigationController presentViewController:activityViewController
                                       animated:YES
                                     completion:^{
                                         // ... 
                                     }];

}

//对TableView进行截图
- (UIImage *)captureTableView:(UITableView *)tableView
{
    [_tableView setContentOffset:CGPointMake(0, 0)];
    
    //t来保存整张图的高度
    int t = 0;
    for (int i = 0; i < [tableView numberOfRowsInSection:0]; ++i) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        t += [self tableView:tableView heightForRowAtIndexPath:path];
    }
    //开始绘图
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(screenWidth, t), YES, 0.f);
    //获取当前图形上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //保存上一个cell绘制时候的纵向偏移
    float lasty = 0;
    //保存当前总共绘制的高度
    float height = 0;
    
    //使用循环创建tableviewcell绘制在图形上下文之上
    for (int i = 0; i < [tableView numberOfRowsInSection:0]; ++i) {
        //绘制第i个cell的时候需要下移前面所有cell高度的和
        CGContextTranslateCTM(context,.0,-lasty);
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        //获取cell
        UITableViewCell *Cell = [tableView cellForRowAtIndexPath:path];
        if (Cell == nil) {
            Cell = [self tableView:tableView cellForRowAtIndexPath:path];
        }
        
        height += [self tableView:tableView heightForRowAtIndexPath:path];
        float y = height - [self tableView:tableView heightForRowAtIndexPath:path];
        
        [tableView setContentOffset:CGPointMake(0, y)];
        
        //绘图偏移移回最顶部
        CGContextTranslateCTM(context,.0,y);
        //绘制
        [Cell.layer renderInContext:context];
        
        lasty = y;
    }
    //结束绘图
//    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
//    UIImage *img = [UIImage imageWithCGImage:imageMasked];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [tableView setContentOffset:CGPointZero];
    return img;
}


@end
