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

#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <Security/Security.h>
#import <QuartzCore/QuartzCore.h>

#import "CommonMarco.h"
#import "DMPasscode.h"
#import "ViewController.h"
#import "NewEvevtViewController.h"
#import "Event.h"
#import "EventStore.h"
#import "SportTVCell.h"
#import "SummaryViewController.h"
#import "SettingStore.h"
#import "PersonInfoStore.h"
#import "SettingTableView.h"
#import "RESideMenu.h"
#import "WXApi.h"
#import "MobClick.h"
#import "NYSegmentedControl.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, EKEventEditViewDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate, WXApiDelegate>
{
    NSMutableDictionary *eventsByDate; ///<储存所有事件的Dic
    
    NSDate *_todayDate;
    NSDate *_minDate;
    NSDate *_maxDate;
}
@property NYSegmentedControl *segmentedControl;

@property (strong, nonatomic)NSMutableDictionary *eventsMostByDate;
@property (strong, nonatomic)NSMutableArray *sportTypes;
@property (strong, nonatomic)NSArray *homeStrLists;
@property (strong, nonatomic)NSArray *rightButtons;

@property (strong, nonatomic) IBOutlet UIView *rootView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UILabel *underTableLabel;
@property (weak, nonatomic) IBOutlet UIButton *addEventButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentButton;
@property (weak, nonatomic) IBOutlet UIButton *addToCalendarButton;

@property (nonatomic, strong) NSDate* selectedDate; ///<被选择的当天日期，用作key
@property (nonatomic, strong) NSMutableArray *oneDayEvents; ///<被选择当天的事件数组Array
@property (nonatomic, strong) NSMutableDictionary *doneNumbers; ///<储存完成项目数的字典
@property (nonatomic, strong) NSNumber *doneNumber; ///<已经完成的项目数

@property (nonatomic, strong) ViewController *vc;
@property (strong, nonatomic) Event *tempEvent; ///<专程用来在更改数据时临时存放的
@property (nonatomic, weak) LeftMenuTableView *menuTable;

// EKEventStore instance associated with the current Calendar application
@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) EKEvent *ekevent;
@property (nonatomic, strong) NSString *idf;

@property (nonatomic) NSInteger applicationIconBadgeNumber;

@property (nonatomic)BOOL isEnterApp;

/* Popover View Controller Handlers */
@property (nonatomic,strong) UIPopoverController *sharingPopoverController;

@end

@implementation ViewController
@synthesize summaryVC;

- (void)setSelectedDate:(NSDate *)selectedDate
{
    _selectedDate = selectedDate;
    
}

#pragma mark - life cycle

- (void)loadView
{
    [super loadView];
    SettingStore *setting = [SettingStore sharedSetting];
    
    if ([DMPasscode isPasscodeSet] && !setting.passWordOfFingerprint) {
        
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        [self presentViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"touchid"] animated:NO completion:^{
            
        }];
        
    }
    //假如通过了密码，则在本次开机过程都不需输入密码
    setting.passWordOfFingerprint = YES;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //侧边栏打开的手势
    [self.sideMenuViewController setPanFromEdge:YES];
    
    //主页无计划时TableView上显示的文字
    self.homeStrLists = [[NSArray alloc] initWithObjects:@"努力画满每一天的圈圈吧！", @"今天没有运动，做个计划吧！", @"每日的计划可以同步到系统日历里去哦", @"为过去创建的运动计划默认已完成", @"别人只看到腹肌，而我们看到了坚毅和决心", nil];
    
    //获取用户权限发送通知
    if (IS_IOS8) {
    UIUserNotificationSettings *setting=[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    }
    
    //TableView初始化
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //NavBar初始化
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewEvent:)];
    UIBarButtonItem *todayButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"present"]  style:UIBarButtonItemStylePlain target:self action:@selector(didGoTodayTouch)];
    _rightButtons = [[NSArray alloc] initWithObjects: addButton, todayButton, nil];
    self.navigationItem.rightBarButtonItems = _rightButtons;
    
    self.segmentedControl = [[NYSegmentedControl alloc] initWithItems:@[Local(@"Cal"), Local(@"Sum")]];
    [self.segmentedControl addTarget:self action:@selector(segmentedControl:) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    self.segmentedControl.segmentIndicatorBackgroundColor = [UIColor whiteColor];
    self.segmentedControl.segmentIndicatorInset = 0.0f;
    self.segmentedControl.titleTextColor = [UIColor lightGrayColor];
    self.segmentedControl.selectedTitleTextColor = [UIColor darkGrayColor];
    self.segmentedControl.usesSpringAnimations = YES;
    self.segmentedControl.selectedSegmentIndex = 0;
    
    [self.segmentedControl sizeToFit];
    self.navigationItem.titleView = self.segmentedControl;
    
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
    
    _todayDate = [NSDate date];
    [_calendarManager setMenuView:_calendarMenuView];
    [_calendarManager setContentView:_calendarContentView];
    [_calendarManager setDate:_todayDate];
    
    //长按移动cell顺序
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:longPress];

    //初始数据
    self.selectedDate = [NSDate date];
    self.doneNumbers = [NSMutableDictionary dictionary];
    
    //给运动项目赋值
    NSArray * array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sportTypes" ofType:@"plist"]];
    self.sportTypes = [NSMutableArray array];
    for (int i = 0; i < array.count; i++){
        self.sportTypes[i] = [[array objectAtIndex:i] objectForKey:@"sportType"];
    }

    [self createMinAndMaxDate];
//    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self loadTheDateEvents];
    self.tempEvent = nil;

//    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_calendarManager reload];
    [MobClick beginLogPageView:@"1_Calendar_Page"];
    
//    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"1_Calendar_Page"];
}

- (void)loadTheDateEvents
{
    //从数据库载入所有数据
    self.oneDayEvents = [NSMutableArray array];
    eventsByDate = [[NSMutableDictionary alloc] initWithDictionary:[[EventStore sharedStore] allItems] copyItems:NO];
    //载入key
    NSString *key = [[self dateFormatter] stringFromDate:self.selectedDate];
    self.oneDayEvents = eventsByDate[key];
    
    [self setUnderTableLabelWithDifferentDay: self.selectedDate];
    [_calendarManager reload];
    [self.tableView reloadData];

//    NSLog(@"%@", NSStringFromSelector(_cmd));
}

//计算某一天已经完成的事件的数目
- (void)setUnderTableLabelWithDifferentDay: (NSDate *)date
{
    int i = 0;
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    //计算这一天有多少已完成的事件
    if (eventsByDate[key]) {
        for (Event *event in eventsByDate[key]) {
            if (event.done == YES) {
                i ++;
            }
        }}

//    NSLog(@"%@ 共有事件 k = %lu 完成事件 i = %d",date, (unsigned long)[eventsByDate[key] count], i);
    
    NSNumber *tempNum = [NSNumber numberWithInt:i];
    self.doneNumbers[key] = tempNum;
    
    SettingStore *setting = [SettingStore sharedSetting];
    if (setting.iconBadgeNumber) {
    //设置桌面的数字角标
    NSString *todayKey = [[self dateFormatter] stringFromDate:[NSDate date]];
    if ([key isEqualToString:todayKey] && eventsByDate && _doneNumbers){
        _applicationIconBadgeNumber = [eventsByDate[todayKey] count] - [_doneNumbers[todayKey] integerValue];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:_applicationIconBadgeNumber];
    }}else{
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
}

- (void)setTableViewHeadTitle: (NSDate *)date{
    
    NSString *key = [[self dateFormatter] stringFromDate:date];
    self.doneNumber = self.doneNumbers[key];
    
    PersonInfoStore *personal = [PersonInfoStore sharedSetting];
    
    //设置显示的文字
    if (self.oneDayEvents.count > 0) {
        self.addEventButton.hidden = YES;
        //设置添加日程的Button
        if (_calendarManager.settings.weekModeEnabled) {
            self.addToCalendarButton.hidden = NO;
        }else{
            self.addToCalendarButton.hidden = YES;
        }
        if (self.oneDayEvents.count > [self.doneNumber intValue]) {
            
            if (personal.name.length > 0){
            self.underTableLabel.text = [NSString stringWithFormat:Local(@"%@，all %@ events，now %d done，%lu more left"), personal.name, @(self.oneDayEvents.count), [self.doneNumber intValue], self.oneDayEvents.count - [self.doneNumber intValue]];
            }else{
                self.underTableLabel.text = [NSString stringWithFormat:Local(@"all %@ events，now %d done，%lu more left"), @(self.oneDayEvents.count), [self.doneNumber intValue], self.oneDayEvents.count - [self.doneNumber intValue]];
            }
            if (_calendarManager.settings.weekModeEnabled) {
                self.addToCalendarButton.hidden = NO;
            }else{
                self.addToCalendarButton.hidden = YES;
            }
        }else if (self.oneDayEvents.count == [self.doneNumber intValue]){
            if (personal.name.length > 0) {
                self.underTableLabel.text = [NSString stringWithFormat:Local(@"All events have done today，%@，well done!"), personal.name];
            }else{
                self.underTableLabel.text = [NSString stringWithFormat:Local(@"All events have done today，well done!")];
            }
            self.addToCalendarButton.hidden = YES;
        }
    }else{
        if (_calendarManager.settings.weekModeEnabled) {
            self.addToCalendarButton.hidden = YES;
        }else{
            self.addToCalendarButton.hidden = YES;
        }
        self.addEventButton.hidden = NO;
        int i = arc4random() % self.homeStrLists.count;
        self.underTableLabel.text = self.homeStrLists[i];
    }
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
//                        [_calendarManager reload];
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
    [self loadTheDateEvents];
    [self setUnderTableLabelWithDifferentDay: self.selectedDate];
    [self.tableView reloadData];
    
    if (DeBugMode) {
        NSLog(@"点击了Date: %@ - %ld events, %@ done", mydate, (unsigned long)[self.oneDayEvents count], self.doneNumber); }
}

#pragma mark - Create New Event

- (IBAction)addNewEvent:(UIButton *)sender {

    [self alertForChooseCreate];
}

- (void)prepareForSegue:(nonnull UIStoryboardSegue *)segue sender:(nullable id)sender
{
//    NSLog(@"%@", NSStringFromSelector(_cmd));
    if ([segue.identifier isEqualToString:@"newEvent"]) {
        
        UINavigationController *nc = (UINavigationController *)segue.destinationViewController;
        NewEvevtViewController *mvc = (NewEvevtViewController *)[nc topViewController];
        
        Event *newEvent = [[EventStore sharedStore] createItem];
        mvc.event = self.tempEvent? self.tempEvent : newEvent;
        mvc.createNewEvent = self.tempEvent ? NO : YES;
        mvc.date = _selectedDate;
        
        NSString *showStr = [[self dateFormatter] stringFromDate:self.selectedDate];
        NSString *compareStr = [[self dateFormatter] stringFromDate:[NSDate date]];
        
        //假如新建事项，过去的日子默认完成
        if (mvc.createNewEvent) {
            if ([_selectedDate compare:[NSDate date]] == NSOrderedAscending && ![showStr isEqualToString:compareStr]) {
                mvc.event.done = YES;
            }
        }
        
        mvc.creatEventBlock = ^(){
//            NSLog(@"Hello World, I am Amos' first Block");
            [self performSegueWithIdentifier:@"newEvent" sender:self];
        };
        
        //新建事件前把页面切回日历视图
        if (self.segmentButton.selectedSegmentIndex == 1) {
        self.segmentButton.selectedSegmentIndex = 0;
        [self segmentedControl:self.segmentButton];
        }
    }
}

- (void)alertForChooseCreate
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"选择新建项目"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"一项运动"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                
        PersonInfoStore *personal = [PersonInfoStore sharedSetting];
        personal.defaultSportType = self.sportTypes[0];
        personal.defaultSportName = @"卧推（平板杠铃）";
        
        [self performSegueWithIdentifier:@"newEvent" sender:self];
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

#pragma mark - Buttons callback

- (IBAction)segmentedControl:(UISegmentedControl *)sender {
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"upload"] style:UIBarButtonItemStylePlain target:self action:@selector(alertForShare)];

    switch ([sender selectedSegmentIndex]) {
        case 0:
//            NSLog(@"first click");
            
            [[self.view.subviews lastObject] removeFromSuperview];
            self.navigationItem.rightBarButtonItem = nil;
            self.navigationItem.rightBarButtonItems = _rightButtons;
            
            self.addEventButton.enabled = YES;
            [self setTableViewHeadTitle:self.selectedDate];
            break;
            
        case 1:
//            NSLog(@"second click");

            if (_calendarManager.settings.weekModeEnabled) {
                [self transitionExample];
                [_calendarManager reload];
                [self setTableViewHeadTitle:_selectedDate];
            }
            
            //View Changes to Today
            [self didGoTodayTouch];
            
            summaryVC = [[SummaryViewController alloc] init];
            summaryVC.eventsMostByDate = self.eventsMostByDate;
            
            self.navigationItem.rightBarButtonItems = nil;
            self.navigationItem.rightBarButtonItem = shareButton;
            
            self.addEventButton.enabled = NO;
            [self.view addSubview:summaryVC.view];
            
            break;
            
        default:
            break;
    }
}

- (IBAction)openAndCloseDrower:(UIBarButtonItem *)sender {
    
//    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (IBAction)didGoTodayTouch
{
    [_calendarManager setDate:_todayDate];
    _selectedDate = _todayDate;
    [self loadTheDateEvents];
    [_calendarManager reload];
    [_tableView reloadData];
}

//往下滑动week模式改为全日期模式
- (IBAction)changeToMonthMode
{
    if (_calendarManager.settings.weekModeEnabled) {
        [self transitionExample];
        [_calendarManager reload];
        [self setTableViewHeadTitle:_selectedDate];
    }
}
//滑动Table改为week视图
- (void)scrollViewWillBeginDragging:(nonnull UIScrollView *)scrollView
{
    if (!_calendarManager.settings.weekModeEnabled) {
        [self transitionExample];
        [_calendarManager reload];
        [self setTableViewHeadTitle:_selectedDate];
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
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    int i = [self.doneNumbers[key] intValue];
    
    if(eventsByDate[key] && [eventsByDate[key] count] > 0){
        
        if ([eventsByDate[key] count] - i > 0) {
            return YES;
        }else if([eventsByDate[key] count] == i){
            return NO;
        }
    }
    
//    NSLog(@"haveEventForDay:判断-每一天是否有事件");
    
    return NO;
}

- (BOOL)eventsAllDoneForDay:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    int i = [self.doneNumbers[key] intValue];
    
    if([eventsByDate[key] count] > 0){
        
        if ([eventsByDate[key] count] == i) {
            return YES;
        }
    }
    
//    NSLog(@"eventsAllDoneForDay:判断-是否事件全部完成");
    
    return NO;
}

//根据Day所有完成的运动项目中，寻找数量最多的那一项
- (unsigned long)findTheMaxOfTypes:(NSDate *)date
{
//    NSLog(@"%@", NSStringFromSelector(_cmd));
    
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
    index = [numberArray indexOfObject:maxNumber]; //根据内容寻找下标，返回最近的值
//    NSLog(@"最多的元素下标是: %ld", index);
    
    if (max > 0) {
    return index;
    }
    
    return sportTypes.count - 1;
    
}

- (IBAction)addToCalendar:(UIButton *)sender {
    [self checkEventStoreAccessForCalendar];
    [MobClick event:@"AddToCalendar"]; //友盟统计数据：添加到日程
}

#pragma mark - CalendarManager delegate

- (void)createMinAndMaxDate
{
    _todayDate = [NSDate date];
    
    // Min date will be 2 month before today
    _minDate = [_calendarManager.dateHelper addToDate:_todayDate months:-2];
    
    // Max date will be 2 month after today
    _maxDate = [_calendarManager.dateHelper addToDate:_todayDate months:2];
}

// Exemple of implementation of prepareDayView method
// Used to customize the appearance of dayView
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
//    NSLog(@"prepareDayView");
    NSTimeZone *localZone = [NSTimeZone localTimeZone];
    NSInteger interval = [localZone secondsFromGMTForDate:dayView.date];
    NSDate *mydate = [dayView.date dateByAddingTimeInterval:interval];
    
    [self setUnderTableLabelWithDifferentDay:mydate];
    
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
    
    if([self haveEventForDay:mydate]){
        dayView.dotView.hidden = NO;
    }else{
        dayView.dotView.hidden = YES;
    }
    
    unsigned long index = [self findTheMaxOfTypes:mydate];
    
    if ([self eventsAllDoneForDay:mydate]) {
        SettingStore *setting = [SettingStore sharedSetting];
        NSArray *oneColor = [setting.typeColorArray objectAtIndex:index];
        UIColor *pickedColor = [UIColor colorWithRed:[oneColor[0] floatValue] green:[oneColor[1] floatValue] blue:[oneColor[2] floatValue] alpha:1];
        
        dayView.finishView.layer.borderColor = [pickedColor CGColor];
        dayView.finishView.hidden = NO;
    }else{
        dayView.finishView.hidden = YES;
    }
    
    if (!self.eventsMostByDate) {
        self.eventsMostByDate = [NSMutableDictionary dictionary];
    }
    NSString *key = [[self dateFormatter] stringFromDate:mydate];
    if (eventsByDate[key]) {
    self.eventsMostByDate[key] = self.sportTypes[index];
    }
    
//    NSLog(@"%@", NSStringFromSelector(_cmd));
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
    if (DeBugMode) { NSLog(@"Next page loaded"); }
}

- (void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar
{
    if (DeBugMode) { NSLog(@"Previous page loaded");}
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
    
    [self loadTheDateEvents];
    [self setUnderTableLabelWithDifferentDay: self.selectedDate];
    [self.tableView reloadData];
    
    BOOL success = [[EventStore sharedStore] saveChanges];
    
    if (DeBugMode) {
    if (success) {
        NSLog(@"完成事件后，储存数据成功");
    }else{
        NSLog(@"完成事件后，储存数据失败！");
    } }
}

- (nullable UIView *)tableView:(nonnull UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //初始化自定义View
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
    [headerView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    headerView.backgroundColor = [UIColor colorWithWhite:0.45 alpha:0.6];

    //设置Header的字体
    UILabel *headText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 22)];
    headText.textColor = [UIColor whiteColor];
    [headText setFont:[UIFont fontWithName:@"Arial" size:14]];
    headText.text = @"text";
    [headText sizeToFit];
    [headerView addSubview:headText];
    
    //设置underLabel的文字内容
    [self setTableViewHeadTitle:self.selectedDate];
    
    unsigned long index = [self findTheMaxOfTypes:self.selectedDate];
    NSArray *sportTypes = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sportTypes" ofType:@"plist"]];
    NSString *blankStr = @"";
    
    if (section == 0) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd EEEE";
        
        headText.text = ([self.doneNumber intValue] > 0)
        ?
        [NSString stringWithFormat:@"%@ - %@",[dateFormatter stringFromDate:self.selectedDate],
         [sportTypes[index] objectForKey:@"sportType"]?
         [sportTypes[index] objectForKey:@"sportType"]:blankStr]
        :
        [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:self.selectedDate]];
        
        [headText sizeToFit];
        headText.center = headerView.center;
        
        return headerView;
    }
    return headerView;
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
}

//设置滑动后出现的选项
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //删除的方法
    UITableViewRowAction *deleteAction = [UITableViewRowAction
       rowActionWithStyle:UITableViewRowActionStyleDestructive
       title:Local(@"Delete")
       handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
         Event *event = self.oneDayEvents[indexPath.row];
         [[EventStore sharedStore] removeItem:event date:self.selectedDate];
           
         //删除表格中的相应行
         [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
           
           if (self.oneDayEvents.count == 0) {
               [self loadTheDateEvents];
           }
           
         [_calendarManager reload];
         [self setUnderTableLabelWithDifferentDay: self.selectedDate];
         [self setTableViewHeadTitle:self.selectedDate];
           
         BOOL success = [[EventStore sharedStore] saveChanges];
           
           if (DeBugMode) {
         if (success) {
             NSLog(@"删除事件后，储存数据成功");
         }else{
             NSLog(@"删除事件后，储存数据失败！");
         }}
     }];
    
    //修改内容的方法
    UITableViewRowAction *editAction = [UITableViewRowAction
      rowActionWithStyle:UITableViewRowActionStyleNormal
      title:Local(@"Edit")
      handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
          self.tempEvent = self.oneDayEvents[indexPath.row];
          
          [self performSegueWithIdentifier:@"newEvent" sender:self];
          [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
      }];
    editAction.backgroundColor = [UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1];
    
    return @[deleteAction, editAction]; //与实际显示的顺序相反
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


#pragma mark - 申请日历事件的权限

// Check the authorization status of our application for Calendar
-(void)checkEventStoreAccessForCalendar
{
    self.eventStore = [[EKEventStore alloc] init];
    
    if ([self.eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        // the selector is available, so we must be on iOS 6 or newer
        [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    NSLog(@"请求许可错误");
                }
                else if (!granted)
                {
                    NSLog(@"被用户拒绝");
                }
                else
                {
                    [self accessGrantedForCalendar:self.eventStore];
                }
            });
        }];
    }
}

#pragma mark - 创建日历事件的方法

-(void)accessGrantedForCalendar:(EKEventStore *)eventStore
{
    self.ekevent  = [EKEvent eventWithEventStore:self.eventStore];
    
    //设置创建日历的内容
    
    //设置事件标题
    unsigned long index = [self findTheMaxOfTypes:self.selectedDate];
    NSArray *sportTypes = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sportTypes" ofType:@"plist"]];
    NSString *blankStr = @"";
    self.ekevent.title = [NSString stringWithFormat:@"进行：%@锻炼",
          [sportTypes[index] objectForKey:@"sportType"]?
          [sportTypes[index] objectForKey:@"sportType"]:blankStr];  //事件标题
    
    //设置事件内容
    NSString *initStr = [NSString stringWithFormat:@"锻炼内容：\n"];
    NSMutableString *notesStr = [[NSMutableString alloc] initWithString:initStr];
    
    for (Event *event in self.oneDayEvents){
        
        NSString *tempAttribute;
        if (event.weight == 0 && event.times > 0) {
            tempAttribute = [NSString stringWithFormat:Local(@"%d times x %d RM"), event.rap, event.times];
        }else if (event.weight == 220 && event.times > 0){
            tempAttribute = [NSString stringWithFormat:Local(@"%d times x %d RM  self-Weight"), event.rap, event.times];
        }else if (event.times == 0 && event.rap == 0){
            tempAttribute = [NSString stringWithFormat:Local(@"%d min"), event.timelast];
        }else{
            tempAttribute = [NSString stringWithFormat:Local(@"%d times x %d RM   %.1fkg"), event.rap, event.times, event.weight];
        }
        [notesStr appendFormat:@"- %@ （%@）\n", event.sportName, tempAttribute];
        
    }
    self.ekevent.notes     = notesStr; //事件内容
    
    //设置事件链接
    self.ekevent.URL = [NSURL URLWithString:@"openurlAmosSportCalendar://"];
   
    //设置时间和日期
    NSDateFormatter* inputFormatter = [NSDateFormatter new];
    [inputFormatter setDateFormat:@"YYYY-MM-dd"];
    [inputFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    NSDateFormatter *outFormatter = [NSDateFormatter new];
    [outFormatter setDateFormat:@"YYYY-MM-dd-H-mm"];
    
    NSString *tempDateStr = [inputFormatter stringFromDate:_selectedDate];
    NSMutableString *tempDateMuStr = [[NSMutableString alloc] initWithString:tempDateStr];
    NSMutableString *tempDateMuStr1 = [[NSMutableString alloc] initWithString:tempDateStr];
    [tempDateMuStr appendString:@"-15-30"];
    NSDate *startDate = [outFormatter dateFromString:tempDateMuStr];
    [tempDateMuStr1 appendString:@"-17-00"];
    NSDate *endDate = [outFormatter dateFromString:tempDateMuStr1];
    
    self.ekevent.startDate = startDate;
    self.ekevent.endDate   = endDate;
    self.ekevent.allDay = NO;
    
    //添加提醒
    [self.ekevent addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -60.0f * 1]];  //1小时前提醒
    //    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -15.0f]];  //15分钟前提醒
    
    EKEventEditViewController *addController = [[EKEventEditViewController alloc] init];
    
    addController.event = self.ekevent;
    addController.eventStore = self.eventStore;
    addController.editViewDelegate = self;
    [self presentViewController:addController animated:YES completion:nil];
}

#pragma mark EKEventEditViewDelegate

// 编辑日历事件页面中按钮的事件
- (void)eventEditViewController:(EKEventEditViewController *)controller
          didCompleteWithAction:(EKEventEditViewAction)action
{
    
    // Dismiss the modal view controller
    [self dismissViewControllerAnimated:YES completion:^
     {
         if (action == EKEventEditViewActionCanceled)
         {
         }else if (action == EKEventEditViewActionSaved)
         {
             NSLog(@"事件创建成功");
         }else if (action == EKEventEditViewActionDeleted)
         {
         }
     }];
}

//删除一个日历事件
- (void)deleteTheEvent
{
    EKEvent *eventToRemove = [self.eventStore eventWithIdentifier:self.idf];
    
    if ([eventToRemove.eventIdentifier length] > 0) {
        NSError* error = nil;
        [self.eventStore removeEvent:eventToRemove span:EKSpanThisEvent error:&error];
        if (error) {
            NSLog(@"%@",error);
        }else {
            NSLog(@"将一个日历事件删除");
        }
    }
}

#pragma mark - Share

- (void)alertForShare
{
    UIImage *bottomImage = [self scaleTheImage:[UIImage imageNamed:@"shareButtonImage"]];
    
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
    NSString *countStr = [NSString stringWithFormat:Local(@"Today's events(%@)"), @(self.oneDayEvents.count)];
    [alert addAction:[UIAlertAction actionWithTitle:countStr
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                
        UIImage *headerImg = [self captureView:_tableView Rectsize:CGSizeMake(screenWidth, 20)];
        UIImage *tableImg = [self captureTableView:_tableView];
        UIImage *tempImg = [self addImageview:tableImg toImage:headerImg];
        UIImage *img = [self addImageview:bottomImage toImage:tempImg];
        [self shareThePersonalInfo:img];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Summary")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                         
//        UIImage *topImg1 = [self captureView:_calendarMenuView Rectsize:CGSizeMake(screenWidth, 50)];
        UIImage *topImg2 = [SummaryViewController captureView:summaryVC.view4];
//        UIImage *topImg = [self addImageview:topImg2 toImage:topImg1];
                                                
        UIImage *tempImg = [SummaryViewController captureView:summaryVC.view1];
        UIImage *bottomImg = [self addImageview:topImg2 toImage:tempImg];
                                                
        UIImage *img = [self addImageview:bottomImage toImage:bottomImg];
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

# pragma mark - 屏幕截图处理方法

//对某View进行截图
- (UIImage*)captureView: (UIView *)theView Rectsize: (CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.f);
    //将view上的子view加进来
    CGContextRef context =UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    
//    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
//    UIImage *img = [UIImage imageWithCGImage:imageMasked];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

//对TableView进行截图
- (UIImage *)captureTableView:(UITableView *)tableView
{
    [_tableView setContentOffset:CGPointMake(0, 0)];
    
    //t来保存整张图的高度
    int t = 0;
    for (int i = 0; i < [self.tableView numberOfRowsInSection:0]; ++i) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        t += [self tableView:_tableView heightForRowAtIndexPath:path];
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
    for (int i = 0; i < [self.tableView numberOfRowsInSection:0]; ++i) {
        //绘制第i个cell的时候需要下移前面所有cell高度的和
        CGContextTranslateCTM(context,.0,-lasty);
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        //获取cell
        UITableViewCell *Cell = [tableView cellForRowAtIndexPath:path];
        if (Cell == nil) {
            Cell = [self tableView:_tableView cellForRowAtIndexPath:path];
        }
        
        height += [self tableView:_tableView heightForRowAtIndexPath:path];
        float y = height - [self tableView:_tableView heightForRowAtIndexPath:path];
        
        [_tableView setContentOffset:CGPointMake(0, y)];
        
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
    
    [_tableView setContentOffset:CGPointZero];
    return img;
}

//合并两张图片
- (UIImage *)addImageview:(UIImage *)imageBottom toImage:(UIImage *)imageTop {
    
    CGSize size = CGSizeMake(imageTop.size.width, imageTop.size.height + imageBottom.size.height);
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.f);
    
    // Draw image1
    [imageTop drawInRect:CGRectMake(0, 0, imageTop.size.width, imageTop.size.height)];
    
    // Draw image2
    [imageBottom drawInRect:CGRectMake(0, imageTop.size.height, imageBottom.size.width, imageBottom.size.height)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

- (UIImage *)scaleTheImage:(UIImage *)img {
    
    float radio = img.size.height / img.size.width;
    
    float width = screenWidth;
    float height = width * radio;

    // 并把它设置成为当前正在使用的context(这里的Size是最终成品图的size)
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), YES, 0.f);

    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, width, height)];

    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();

    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}


@end
