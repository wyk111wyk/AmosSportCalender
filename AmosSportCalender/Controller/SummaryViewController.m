//
//  SummaryViewController.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/3.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "SummaryViewController.h"
#import "summaryTypeCell.h"
#import "EventStore.h"
#import "Event.h"
#import "DetailSummaryVC.h"
#import "CommonMarco.h"

@interface SummaryViewController ()<UITableViewDataSource, UITableViewDelegate, XYPieChartDelegate, XYPieChartDataSource, UUChartDataSource>
{
    UISwipeGestureRecognizer *swipeGestureRight;
    UISwipeGestureRecognizer *swipeGestureLeft;
}
@property (strong ,nonatomic) UILabel *expLabel;

@property (nonatomic, strong)NSMutableDictionary *eventsMostByDate;
@property (nonatomic, strong)NSMutableDictionary *eventsByDate;
@property (nonatomic, strong)NSArray *sortedKeyArray;
@property (nonatomic, strong)NSArray *sortedTypeArray; ///<tableView使用的数据源
@property (nonatomic, strong)NSDictionary *eventsDetailByType;

@property (nonatomic, strong)NSDate *firstDayofMonth; ///<这个月的第一天的日子
@property (nonatomic, strong)NSArray *chartDataArray;

@property (nonatomic, strong)NSArray *allSortedData;
@property (nonatomic) NSInteger allCount; ///<所有天数，而不是运动数
@property (nonatomic, strong)NSString *monthAndYear;
@property (nonatomic, strong)UITapGestureRecognizer *tap;
@property (nonatomic)BOOL isDay; ///<显示的是天数还是百分比

@end

@implementation SummaryViewController

@synthesize percentageLabel = _percentageLabel;

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isDay = YES;
    [self initTheFrames];
    [self getTheFreshData];
    
    //设置当前的月份和年份
    self.monthAndYear = [[ASBaseManage dateFormatterForMY] stringFromDate:[NSDate date]];
    
    //刷新图表的数据
    [self arrayForChartData: [NSDate date]];
    [self.chartView showInView:self.contantView];
    
    //初始化图片和手势
    [self initGestureAndImage];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.contantView bringSubviewToFront:self.expLabel];
    [self.pieChartView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 初始化页面UI

- (void)initTheFrames
{
    //TableView初始化
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    //View的初始化
    {
        self.view.backgroundColor = [UIColor colorWithRed:0.9529 green:0.9529 blue:0.9529 alpha:1];
        _viewBackground.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        self.scrollView.frame = CGRectMake(0, 64, screenWidth, screenHeight);
        self.view1.frame = CGRectMake(0, 0, screenWidth, 167);
    }
    {
        self.view4.frame = CGRectMake(0, self.view1.frame.size.height, screenWidth, 165);
        self.chartView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(0, 14, screenWidth - 24, self.contantView.frame.size.height - 19)
                                                       withSource:self
                                                        withStyle:UUChartLineStyle];
        
        NSString *monthStr = [[ASBaseManage dateFormatterForMY] stringFromDate:[NSDate date]];
        NSString *subStr1 = [monthStr substringFromIndex:3];
        NSString *subStr2 = [monthStr substringToIndex:2];
        NSString *labelStr = [NSString stringWithFormat:@"%@年%@月-每周运动天数",subStr1, subStr2];
        self.expLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contantView.frame.size.width - 125, 105, 0, 0)];
        self.expLabel.text = labelStr;
        self.expLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:12.0f];
        self.expLabel.textColor = [UIColor colorWithWhite:0.2 alpha:0.3];
        [self.expLabel sizeToFit];
        self.expLabel.center = CGPointMake(screenWidth/2, 13);
        [self.contantView addSubview:self.expLabel];
    }
    self.view2.frame = CGRectMake(0, self.view1.frame.size.height + self.view4.frame.size.height, screenWidth, 152);
    if (screenWidth == 320)
    { self.view2.frame = CGRectMake(0, self.view1.frame.size.height + self.view4.frame.size.height, screenWidth, 129.5); }
    else if (screenWidth == 414)
    { self.view2.frame = CGRectMake(0, self.view1.frame.size.height + self.view4.frame.size.height, screenWidth, 167.5); }
    
    self.tableView.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 376);
    self.view3.frame = CGRectMake(0, self.view1.frame.size.height + self.view2.frame.size.height + self.view4.frame.size.height, screenWidth, 384);
    if (screenWidth == 320) {
        self.view3.frame = CGRectMake(0, self.view1.frame.size.height + self.view2.frame.size.height + self.view4.frame.size.height, screenWidth, 360);
    }
    
    CGFloat contentHight = self.view1.frame.size.height + self.view2.frame.size.height + self.view3.frame.size.height + self.view4.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(screenWidth, contentHight);
    self.scrollView.bounces = YES;
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.scrollEnabled = YES;
    
    [self.scrollView addSubview:self.view1];
    [self.scrollView addSubview:self.view4];
    [self.scrollView addSubview:self.view2];
    [self.scrollView addSubview:self.view3];
    
    //图表View的初始化
    self.pieChartView.delegate = self;
    [self.pieChartView setDataSource:self];
    //optional
    [self.pieChartView setStartPieAngle:M_PI_2];
    [self.pieChartView setAnimationSpeed:0.8];
    [self.pieChartView setLabelFont:[UIFont fontWithName:@"ArialMT" size:11]];
    [self.pieChartView setLabelRadius:50];
    [self.pieChartView setShowPercentage:NO];
    [self.pieChartView setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
    [self.pieChartView setUserInteractionEnabled:YES];
    [self.pieChartView setLabelShadowColor:[UIColor darkGrayColor]];
    
    //设置阴影
    [[self.shadoView1 layer] setShadowOffset:CGSizeMake(1, 1)]; // 阴影的范围
    [[self.shadoView1 layer] setShadowRadius:2];                // 阴影扩散的范围控制
    [[self.shadoView1 layer] setShadowOpacity:1];               // 阴影透明度
    [[self.shadoView1 layer] setShadowColor:[UIColor colorWithWhite:0.2 alpha:0.55].CGColor]; // 阴影的颜色
    
    [[self.shadoView21 layer] setShadowOffset:CGSizeMake(1, 1)]; // 阴影的范围
    [[self.shadoView21 layer] setShadowRadius:2];                // 阴影扩散的范围控制
    [[self.shadoView21 layer] setShadowOpacity:1];               // 阴影透明度
    [[self.shadoView21 layer] setShadowColor:[UIColor colorWithWhite:0.2 alpha:0.55].CGColor]; // 阴影的颜色
    
    [[self.shadoView22 layer] setShadowOffset:CGSizeMake(1, 1)]; // 阴影的范围
    [[self.shadoView22 layer] setShadowRadius:2];                // 阴影扩散的范围控制
    [[self.shadoView22 layer] setShadowOpacity:1];               // 阴影透明度
    [[self.shadoView22 layer] setShadowColor:[UIColor colorWithWhite:0.2 alpha:0.55].CGColor]; // 阴影的颜色
    
    [[self.contantView layer] setShadowOffset:CGSizeMake(2, 2)]; // 阴影的范围
    [[self.contantView layer] setShadowRadius:2];                // 阴影扩散的范围控制
    [[self.contantView layer] setShadowOpacity:1];               // 阴影透明度
    [[self.contantView layer] setShadowColor:[UIColor colorWithWhite:0.2 alpha:0.45].CGColor]; // 阴影的颜色
    
    [self.percentageLabel.layer setCornerRadius:22];
    [self.percentageLabel setText:@"100%"];
    
    [self.contantView bringSubviewToFront:self.expLabel];
}

- (void)initGestureAndImage {
    //添加手势
    swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(buttonClicked:)];
    swipeGestureRight.numberOfTouchesRequired = 1;// 手指个数 The default value is 1.
    swipeGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.chartView addGestureRecognizer:swipeGestureRight];
    
    swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(buttonClicked:)];
    swipeGestureLeft.numberOfTouchesRequired = 1;// 手指个数 The default value is 1.
    swipeGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.chartView addGestureRecognizer:swipeGestureLeft];
    
    //    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(makeButtonDisappear)];
    //    [self.chartView addGestureRecognizer:self.tap];
    
    //2-1图片
    SettingStore *setting = [SettingStore sharedSetting];
    
    if (self.sortedTypeArray.count > 0) {
        NSString *mostTypeStr = [[_allSortedData firstObject] valueForKey:@"sportPart"];
        NSString *leastTypeStr = [[_allSortedData lastObject] valueForKey:@"sportPart"];
        if (setting.sportTypeImageMale) {
            self.mostTypeImageView.image = [UIImage imageNamed:mostTypeStr];
            self.leastTypeImageView.image = [UIImage imageNamed:leastTypeStr];
        }else{
            NSString *femaleImageMost = [NSString stringWithFormat:@"女%@", mostTypeStr];
            NSString *femaleImageLeast = [NSString stringWithFormat:@"女%@", leastTypeStr];
            self.mostTypeImageView.image = [UIImage imageNamed:femaleImageMost];
            self.leastTypeImageView.image = [UIImage imageNamed:femaleImageLeast];
        }
    };
}

#pragma mark - 获取和计算数据

- (void)getTheFreshData {
    //计算主要数据
    NSArray *allDateEvents = [DateEventStore findByCriteria:@" ORDER BY dateKey DESC "];
    _allCount = allDateEvents.count;
    //百分比圆盘
    if (allDateEvents.count == 0){
        self.percentageLabel.text = @"0%";
    }
    NSArray * allSportTypes = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SportParts" ofType:@"plist"]];
    NSMutableArray *allSortedDates = [[NSMutableArray alloc] initWithCapacity:allSportTypes.count];
    
    for (NSString *sportPart in allSportTypes) {
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        [tempDic setObject:sportPart forKey:@"sportPart"];
        NSMutableArray *tempArray = [NSMutableArray array];
        [tempDic setObject:tempArray forKey:@"data"];
        [allSortedDates addObject:tempDic];
    }
    
    NSInteger totalTimeMin = 0;
    for (DateEventStore *dateStore in allDateEvents){
        totalTimeMin +=dateStore.doneMins;
        for (NSMutableDictionary *tempDic in allSortedDates){
            NSString *dicPart = [tempDic objectForKey:@"sportPart"];
            if ([dateStore.sportPart isEqualToString:dicPart]) {
                NSMutableArray *tempArr = [tempDic objectForKey:@"data"];
                [tempArr addObject:dateStore];
                break;
            }
        }
    }
    
    _allSortedData = [allSortedDates sortedArrayUsingComparator: ^(id obj1, id obj2) {
        NSMutableDictionary *tempDic1 = obj1;
        NSMutableDictionary *tempDic2 = obj2;
        NSMutableArray *tempArr1 = [tempDic1 objectForKey:@"data"];
        NSMutableArray *tempArr2 = [tempDic2 objectForKey:@"data"];
        
        if ([tempArr1 count] > [tempArr2 count]) {
            return (NSComparisonResult)NSOrderedAscending;//递减
        }
        if ([tempArr1 count] < [tempArr2 count]) {
            return (NSComparisonResult)NSOrderedDescending;//递减
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    //刷新总结数字
    [self getTheSummaryData:allDateEvents totalMin:totalTimeMin];
}

- (void)getTheSummaryData: (NSArray *)allDateEvents totalMin: (NSInteger)totalTimeMin {
    //总次数
    _theWholeNumber.text = [NSString stringWithFormat:@"%@", @(allDateEvents.count)];
    //总时间
    _theWholeTime.text = [NSString stringWithFormat:@"%@", @(totalTimeMin)];
    //平均每周几次
    DateEventStore *dateStore = [allDateEvents lastObject];
    NSDate *firstDate = [[ASBaseManage dateFormatterForDMY] dateFromString:dateStore.dateKey];
    NSInteger currentSeconds = [[NSDate date] timeIntervalSince1970];
    NSInteger firstSeconds = [firstDate timeIntervalSince1970];
    NSInteger gapDays = (currentSeconds - firstSeconds) / (24*60*60);
    float gapWeeks = (float)gapDays / 7.f;
    float avgWeekTimes = 0;
    if (gapWeeks > 1) {
        avgWeekTimes = (float)allDateEvents.count/gapWeeks;
    } else {
        avgWeekTimes = allDateEvents.count;
    }
    _aveTimesAWeek.text = [NSString stringWithFormat:@"%.1f", avgWeekTimes];
    //平均每次几分钟
    NSInteger allDoneEventCount = [SportRecordStore findCounts:@" WHERE isDone = '1' "];
    float avgTimeMin = (float)totalTimeMin/(float)allDoneEventCount;
    _aveTime.text = [NSString stringWithFormat:@"%.1f", avgTimeMin];
    
    //iphone5的话字体缩小
    if (screenWidth == WidthiPhone5) {
        UIFont *font = [UIFont systemFontOfSize:22];
        [_theWholeNumber setFont:font];
        [_theWholeTime setFont:font];
        [_aveTime setFont:font];
        [_aveTimesAWeek setFont:font];
        
        _tableView.rowHeight = 44;
    }
    
    [self.theWholeNumber sizeToFit];
    [self.theWholeTime sizeToFit];
    [self.aveTime sizeToFit];
    [self.aveTimesAWeek sizeToFit];
}

#pragma mark - Button Method
//最多的运动
- (IBAction)mosrButtonClick:(UIButton *)sender {
    
    DetailSummaryVC *detailVC = [DetailSummaryVC new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:detailVC];
    
    NSDictionary *cellInfoDic = [self.sortedTypeArray firstObject];
    NSString *typeStr = [NSString stringWithFormat:@"%@", cellInfoDic[@"type"]];
    
    detailVC.eventsByDateForTable = self.eventsDetailByType[typeStr];
    detailVC.sportTypeStr = [self.sortedTypeArray firstObject][@"type"];
    
    nav.modalTransitionStyle = UIModalTransitionStylePartialCurl; //改变模态视图出现的动画
    [self presentViewController:nav animated:YES completion:^{
    }];
}
//最少的运动
- (IBAction)leastButtonClick:(UIButton *)sender {
    
    DetailSummaryVC *detailVC = [DetailSummaryVC new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:detailVC];
    
    NSDictionary *cellInfoDic = [self.sortedTypeArray lastObject];
    NSString *typeStr = [NSString stringWithFormat:@"%@", cellInfoDic[@"type"]];
    
    detailVC.eventsByDateForTable = self.eventsDetailByType[typeStr];
    detailVC.sportTypeStr = [self.sortedTypeArray lastObject][@"type"];
    
    
    nav.modalTransitionStyle = UIModalTransitionStylePartialCurl; //改变模态视图出现的动画
    [self presentViewController:nav animated:YES completion:^{
    }];
}

//滑动改变图表显示的时间
- (void)buttonClicked: (id)sender
{
    //删除当下的图表
    [[self.contantView.subviews firstObject] removeFromSuperview];
    
    if (sender == swipeGestureLeft) {
        //重绘上月数据的图表
        NSString * lastMonthAndYear = [[ASBaseManage sharedManage] lastMonthFrom:self.monthAndYear];
        NSDate *lastMonth = [[ASBaseManage dateFormatterForMY] dateFromString:lastMonthAndYear];
        [self arrayForChartData:lastMonth];
        self.monthAndYear = lastMonthAndYear;
    }else if (sender == swipeGestureRight) {
        //重绘下月数据的图表
        NSString * nextMonthAndYear = [[ASBaseManage sharedManage] nextMonthFrom:self.monthAndYear];
        NSDate *nextMonth = [[ASBaseManage dateFormatterForMY] dateFromString:nextMonthAndYear];
        [self arrayForChartData:nextMonth];
        self.monthAndYear = nextMonthAndYear;
    }

    //更新title的月份显示
    NSString *subStr1 = [self.monthAndYear substringFromIndex:3];
    NSString *subStr2 = [self.monthAndYear substringToIndex:2];
    NSString *labelStr = [NSString stringWithFormat:@"%@年%@月-每周运动天数",subStr1, subStr2];
    self.expLabel.text = labelStr;
    
    //重绘chart图表
    self.chartView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(0, 14, screenWidth - 24, self.contantView.frame.size.height - 19)
                                                   withSource:self
                                                    withStyle:UUChartLineStyle];
    [self.chartView showInView:self.contantView];
    [self.chartView addGestureRecognizer:swipeGestureLeft];
    [self.chartView addGestureRecognizer:swipeGestureRight];
}

#pragma mark - 生成表格使用的数据

//生成用于表格的数据（每周的运动次数）
- (void)arrayForChartData: (NSDate *)date
{
    //本月第一天星期几的代表数字 (0 - 6)
    int weekDay = (int)[[ASBaseManage sharedManage] weekOfFirstDay:date]-1;
    //还有几天到下个周一(周日)
    SettingStore *setting = [SettingStore sharedSetting];
    if (setting.firstDayOfWeek) {
        weekDay += 1;
        if (weekDay == 7) {
            weekDay = 0;
        }
    }
    int toNextMonday = 7 - weekDay;
    if (toNextMonday == 7) {
        toNextMonday = 0;
    }
    //计算上个月最后一周的所有日期
    NSMutableArray *lastMonthLastWeek = [NSMutableArray array];
    for (int i = 0 ; i < weekDay; i++) {
        NSInteger interval = - (i+1)*24*60*60;
        NSDate *veryFirstDay = [self.firstDayofMonth dateByAddingTimeInterval:interval];
        NSString *veryFirstDayStr = [[ASBaseManage dateFormatterForDMY] stringFromDate:veryFirstDay];
        [lastMonthLastWeek addObject:veryFirstDayStr];
    }
    for (int i = 0; i <= 6 - weekDay; i++) {
        NSInteger interval =  i*24*60*60;
        NSDate *veryFirstDay = [self.firstDayofMonth dateByAddingTimeInterval:interval];
        NSString *veryFirstDayStr = [[ASBaseManage dateFormatterForDMY] stringFromDate:veryFirstDay];
        [lastMonthLastWeek addObject:veryFirstDayStr];
    }
    //计算这个月最后一周的所有日期
    NSMutableArray *thisMonthLastWeek = [NSMutableArray array];
    NSDate *lastDayOfThisMonthDate = [[ASBaseManage sharedManage] thisMonthLastDay:date];
    int lastWeekDay = (int)[[ASBaseManage sharedManage] weekOfFirstDay:lastDayOfThisMonthDate]-1;
    if (setting.firstDayOfWeek) {
        lastWeekDay += 1;
        if (lastWeekDay == 7) {
            lastWeekDay = 0;
        }
    }
    int toLastMonday = 7 - lastWeekDay;
    if (toLastMonday == 7) {
        toLastMonday = 0;
    }
    for (int i = 0 ; i < lastWeekDay; i++) {
        NSInteger interval = - (i+1)*24*60*60;
        NSDate *veryFirstDay = [lastDayOfThisMonthDate dateByAddingTimeInterval:interval];
        NSString *veryFirstDayStr = [[ASBaseManage dateFormatterForDMY] stringFromDate:veryFirstDay];
        [thisMonthLastWeek addObject:veryFirstDayStr];
    }
    for (int i = 0; i <= 6 - lastWeekDay; i++) {
        NSInteger interval =  i*24*60*60;
        NSDate *veryFirstDay = [lastDayOfThisMonthDate dateByAddingTimeInterval:interval];
        NSString *veryFirstDayStr = [[ASBaseManage dateFormatterForDMY] stringFromDate:veryFirstDay];
        [thisMonthLastWeek addObject:veryFirstDayStr];
    }
    //除去和上个月相关联的第一周，先把这个月的下个周一起的运动天数统计出来
    //首先要把这个月所有的运动具体天数统计出来
    NSMutableArray *thisMonthSportDates = [NSMutableArray array];
    for (NSString *date in self.sortedKeyArray){
        NSString *dayStr = [date substringFromIndex:3];
        NSString *subStr = [[ASBaseManage dateFormatterForMY] stringFromDate:self.firstDayofMonth];
        if ([dayStr isEqualToString:subStr]) {
            [thisMonthSportDates addObject:date];
        }
    }
    //接着根据7天为一个周期进行划分
    NSMutableArray *array0 = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *array1 = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *array2 = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *array3 = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *array4 = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *array5 = [NSMutableArray arrayWithCapacity:0];
    for (NSString *date in thisMonthSportDates){
        NSString *dayStr = [date substringToIndex:2];
        int day = [dayStr intValue];
        //计算下个周一是几号(最晚是7)
        int nextMondayDate = 1 + toNextMonday;
        //根据周期进行划分
        for (int i = 0; i < 5; i++) {
            if (day >= nextMondayDate + i*7 && day < nextMondayDate + 7 + i*7) {
                if (i == 0) {[array1 addObject:date];
                }else if (i == 1){[array2 addObject:date];
                }else if (i == 2){[array3 addObject:date];
                }else if (i == 3){[array4 addObject:date];
                }
            }
        }
    }
    //获取第一周的运动天数
    for (NSString *date in lastMonthLastWeek){
        if ([self.sortedKeyArray containsObject:date]) {
            [array0 addObject:date];
        }
    }
    //获取最后一周的运动天数
    for (NSString *date in thisMonthLastWeek){
        if ([self.sortedKeyArray containsObject:date]) {
            [array5 insertObject:date atIndex:0];
        }
    }
    
    NSArray *chartData = @[@(array0.count), @(array1.count), @(array2.count), @(array3.count), @(array4.count), @(array5.count)];
    
    //筛选这个月是否有第五周
    if ([array4 isEqualToArray: array5]) {
        chartData = @[@(array0.count), @(array1.count), @(array2.count), @(array3.count), @(array4.count)];
    }
    
    self.chartDataArray = chartData;
}


- (NSDateFormatter *)dateFormatterForWeek
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"EEE";
    }
    
    return dateFormatter;
}

- (NSDateFormatter *)dateFormatterForChart
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"MMM";
    }
    
    return dateFormatter;
}

#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _allSortedData.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"summaryTypeCell";
    summaryTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:cellIdentifier owner:nil options:nil] firstObject];
    }
    
    NSMutableDictionary *tempDic = _allSortedData[indexPath.row];
    NSString *sportPart = [tempDic objectForKey:@"sportData"];
    NSMutableArray *tempArr = [tempDic objectForKey:@"data"];
    
    cell.typeLabel.text = sportPart;
    
    if (self.isDay == YES) {
        cell.daysOrPerLabel.text = [NSString stringWithFormat:@"%@ 天", @(tempArr.count)];
    }else{
        float f = 0;
        if (_allCount > 0) {
            f = (float)tempArr.count / (float)_allCount;
        }
        cell.daysOrPerLabel.text = [NSString stringWithFormat:@"%.1f%%", f*100];
    }

    cell.changeShowBlock = ^(){
        _isDay = !_isDay;
        [self.tableView reloadData];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DetailSummaryVC *detailVC = [DetailSummaryVC new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:detailVC];
    
    NSMutableDictionary *tempDic = _allSortedData[indexPath.row];
    NSString *sportPart = [tempDic objectForKey:@"sportData"];
    NSMutableArray *tempArr = [tempDic objectForKey:@"data"];
    
    detailVC.eventsByDateForTable = tempArr;
    detailVC.sportTypeStr = sportPart;
    
    nav.modalTransitionStyle = UIModalTransitionStylePartialCurl; //改变模态视图出现的动画
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - XYPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    return _allSortedData.count;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    NSMutableDictionary *tempDic = _allSortedData[index];
    NSMutableArray *tempArr = [tempDic objectForKey:@"data"];
    
    return tempArr.count;
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    NSMutableDictionary *tempDic = _allSortedData[index];
    NSString *sportPart = [tempDic objectForKey:@"sportPart"];
    UIColor *pickedColor = [[ASBaseManage sharedManage] colorForsportType:sportPart];
    
    return pickedColor;
}

- (NSString *)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index
{
    NSMutableDictionary *tempDic = _allSortedData[index];
    NSString *sportPart = [tempDic objectForKey:@"sportPart"];
    
    return sportPart;
}

#pragma mark - XYPieChart Delegate
- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index
{
    NSMutableDictionary *tempDic = _allSortedData[index];
    NSMutableArray *tempArr = [tempDic objectForKey:@"data"];
    float f = 0;
    if (_allCount > 0) {
        f = (float)tempArr.count / (float)_allCount;
    }
    self.percentageLabel.text = [NSString stringWithFormat:@"%.1f%%", f*100];
}

- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index
{
    self.percentageLabel.text = @"100%";
}

- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index
{
//    NSLog(@"did deselect slice at index %lu",index);
}
- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
//    NSLog(@"did select slice at index %lu",index);
}

#pragma mark - 设置表格的方法
- (NSArray *)getXTitles:(NSUInteger)num
{
    NSMutableArray *xTitles = [NSMutableArray array];
    NSDate *date = [[ASBaseManage dateFormatterForMY] dateFromString:self.monthAndYear];
    NSString *monthStr = [[self dateFormatterForChart] stringFromDate:date];
    
    for (int i=0; i<num; i++) {
        NSString * str = [NSString stringWithFormat:@"%@(%d)",monthStr ,i+1];
        [xTitles addObject:str];
    }
    return xTitles;
}

//横坐标标题数组
- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{
    return [self getXTitles:self.chartDataArray.count];
}

//用以显示的数值：多重数组
- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
    return @[self.chartDataArray];
}

//颜色数组
- (NSArray *)UUChart_ColorArray:(UUChart *)chart
{
    return @[UUGreen, UURed];
}

//显示数值范围
- (CGRange)UUChartChooseRangeInLineChart:(UUChart *)chart
{
    return CGRangeMake(7, 0);
}

//标记数值区域
- (CGRange)UUChartMarkRangeInLineChart:(UUChart *)chart
{
    return CGRangeMake(4, 6);
}

//判断显示横线条
- (BOOL)UUChart:(UUChart *)chart ShowHorizonLineAtIndex:(NSInteger)index
{
    return YES;
}

//判断显示最大最小值
- (BOOL)UUChart:(UUChart *)chart ShowMaxMinAtIndex:(NSInteger)index
{
    return NO;
}

+ (UIImage*)captureView: (UIView *)theView
{
    CGRect rect = theView.frame;
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0);
    CGContextRef context =UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

@end
