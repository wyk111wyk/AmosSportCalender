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
#import "DetailSummaryVC.h"
#import "CommonMarco.h"

@interface SummaryViewController ()<UITableViewDataSource, UITableViewDelegate, XYPieChartDelegate, XYPieChartDataSource, UUChartDataSource>
{
    UISwipeGestureRecognizer *swipeGestureRight;
    UISwipeGestureRecognizer *swipeGestureLeft;
}
@property (strong ,nonatomic) UILabel *expLabel; ///<表格上的文字
@property (nonatomic, strong) NSString *monthAndYear; ///<表格展示的月份
@property (nonatomic, strong) NSDate *displayDate;
@property (nonatomic, strong) NSMutableArray *chartDataArray;

@property (nonatomic, strong)NSArray *allDateEvents;
@property (nonatomic, strong)NSArray *allSortedData;
@property (nonatomic) NSInteger allCount; ///<所有天数，而不是运动数
@property (nonatomic, strong)UITapGestureRecognizer *tap;
@property (nonatomic)BOOL isDay; ///<显示的是天数还是百分比

@end

@implementation SummaryViewController

@synthesize percentageLabel = _percentageLabel;

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isDay = YES;
    self.displayDate = [NSDate date];
    //设置刚开始展示的当月数据
    _monthAndYear = [[ASBaseManage dateFormatterForMY] stringFromDate:[NSDate date]];
    
    [self getTheFreshData];
    [self initTheFrames];
    
    //刷新图表的数据
//    [self arrayForChartData: [NSDate date]];
    [self updateTheDataForChart:[NSDate date]];
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

- (void)initTheFrames {
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
        NSString *labelStr = [NSString stringWithFormat:Local(@"%@-%@ - Days / Every week"),subStr1, subStr2];
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
    
    self.tableView.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 50*_allSortedData.count);
    self.view3.frame = CGRectMake(0, self.view1.frame.size.height + self.view2.frame.size.height + self.view4.frame.size.height, screenWidth, self.tableView.frame.size.height+8);
    if (screenWidth == 320) {
//        self.view3.frame = CGRectMake(0, self.view1.frame.size.height + self.view2.frame.size.height + self.view4.frame.size.height, screenWidth, 360);
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
    
    //2-1图片
    SettingStore *setting = [SettingStore sharedSetting];
    
    if (_allDateEvents.count > 0) {
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
    _allDateEvents = [DateEventStore findByCriteria:@" ORDER BY dateKey DESC "];
    _allCount = _allDateEvents.count;
    //百分比圆盘
    [self.percentageLabel.layer setCornerRadius:22];
    if (_allCount == 0){
        self.percentageLabel.text = @"0%";
    }else {
        self.percentageLabel.text = @"100%";
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
    for (DateEventStore *dateStore in _allDateEvents){
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
    [self getTheSummaryData:_allDateEvents totalMin:totalTimeMin];
}

- (void)getTheSummaryData: (NSArray *)allDateEvents totalMin: (NSInteger)totalTimeMin {
    //总次数
    _theWholeNumber.text = [NSString stringWithFormat:@"%@", @(allDateEvents.count)];
    //总时间
    _theWholeTime.text = [NSString stringWithFormat:@"%@", @(totalTimeMin/60)];
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
    NSInteger allDoneEventCount = [SportRecordStore findCounts:@" WHERE isDone = '1' AND isGroupSet = '0' "];
    float avgTimeMin = 0;
    if (allDoneEventCount > 0) {
        avgTimeMin = (float)totalTimeMin/(float)allDoneEventCount;
    }
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
    
    NSMutableDictionary *tempDic = [_allSortedData firstObject];
    NSString *sportPart = [tempDic objectForKey:@"sportPart"];
    NSMutableArray *tempArr = [tempDic objectForKey:@"data"];
    
    detailVC.eventsByDateForTable = tempArr;
    detailVC.sportTypeStr = sportPart;
    
    nav.modalTransitionStyle = UIModalTransitionStylePartialCurl; //改变模态视图出现的动画
    [self presentViewController:nav animated:YES completion:^{
    }];
}
//最少的运动
- (IBAction)leastButtonClick:(UIButton *)sender {
    
    DetailSummaryVC *detailVC = [DetailSummaryVC new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:detailVC];
    
    NSMutableDictionary *tempDic = [_allSortedData lastObject];
    NSString *sportPart = [tempDic objectForKey:@"sportPart"];
    NSMutableArray *tempArr = [tempDic objectForKey:@"data"];
    
    detailVC.eventsByDateForTable = tempArr;
    detailVC.sportTypeStr = sportPart;
    
    nav.modalTransitionStyle = UIModalTransitionStylePartialCurl; //改变模态视图出现的动画
    [self presentViewController:nav animated:YES completion:^{
    }];
}

//滑动改变图表显示的时间
- (void)buttonClicked: (id)sender
{
//    NSLog(@"%@", self.contantView.subviews);
    
    //删除当下的图表
    [self.contantView.subviews[0] removeFromSuperview];
    
    if (sender == swipeGestureLeft) {
        //重绘上月数据的图表
        NSString * lastMonthAndYear = [[ASBaseManage sharedManage] lastMonthFrom:_monthAndYear];
        _displayDate = [[ASBaseManage dateFormatterForDMY] dateFromString:lastMonthAndYear];
        _monthAndYear = [lastMonthAndYear substringFromIndex:3];
    }else if (sender == swipeGestureRight) {
        //重绘下月数据的图表
        NSString * nextMonthAndYear = [[ASBaseManage sharedManage] nextMonthFrom:_monthAndYear];
        _displayDate = [[ASBaseManage dateFormatterForDMY] dateFromString:nextMonthAndYear];
        _monthAndYear = [nextMonthAndYear substringFromIndex:3];
    }
    [self updateTheDataForChart:_displayDate];

    //更新title的月份显示
    NSString *subStrYear = [_monthAndYear substringFromIndex:3];
    NSString *subStrMonth = [_monthAndYear substringToIndex:2];
    NSString *labelStr = [NSString stringWithFormat:Local(@"%@-%@ - Days / Every week"),subStrYear, subStrMonth];
    self.expLabel.text = labelStr;
    
    //重绘chart图表
    self.chartView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(0, 14, screenWidth - 24, self.contantView.frame.size.height - 19)
                                                   withSource:self
                                                    withStyle:UUChartLineStyle];
    [self.chartView showInView:self.contantView];
    [self.chartView addGestureRecognizer:swipeGestureLeft];
    [self.chartView addGestureRecognizer:swipeGestureRight];
    [self.contantView bringSubviewToFront:self.expLabel];
}

#pragma mark - 生成表格使用的数据

- (void)updateTheDataForChart: (NSDate *)targetDate {
    SettingStore *setting = [SettingStore sharedSetting];
    
    NSDate *firstDate = [[ASBaseManage sharedManage] firstDateOfMonth:targetDate];
    NSInteger firstTimpStamp = [firstDate timeIntervalSince1970];
    NSInteger weekNumOfMonthFirstDate = [[ASBaseManage sharedManage] weekDayFromTimeStamp:firstTimpStamp];
    //判断用户设置的第一天是星期几
    NSInteger leftDayOfWeek;
    if (setting.firstDayOfWeek) {
        //星期天
        leftDayOfWeek = 7 - weekNumOfMonthFirstDate;
    }else {
        //星期一
        leftDayOfWeek = 8 - weekNumOfMonthFirstDate;
    }
    
    NSString *leftDateStr = [[ASBaseManage dateFormatterForMY] stringFromDate:targetDate];
    //这个月最后一天
    NSDate *lastDate = [[ASBaseManage sharedManage] DateOfMonth:targetDate isFirst:NO];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal
                               components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                               fromDate:lastDate];
    
    self.chartDataArray = [[NSMutableArray alloc] initWithCapacity:5];
    NSInteger dateDay = 1;
    for (int i = 0; i < 6; i++) {
        NSMutableArray *tempArr = [NSMutableArray array];
        for (int k = 0; k < leftDayOfWeek; k++) {
            NSString *compareDateStr = [NSString stringWithFormat:@"%@-%@", @(dateDay), leftDateStr];
            if (dateDay < 10) {
                compareDateStr = [NSString stringWithFormat:@"0%@-%@", @(dateDay), leftDateStr];
            }
            DateEventStore *dateStore = [DateEventStore findFirstWithFormat:@" WHERE dateKey = '%@' ", compareDateStr];
            if (dateStore) {
                [tempArr addObject:dateStore];
            }
            dateDay ++;
        }
        leftDayOfWeek = 7;
        [self.chartDataArray addObject:@(tempArr.count)];
        if (dateDay >= comps.day) {
            break;
        }
    }
    
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

#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _allSortedData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"summaryTypeCell";
    summaryTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:cellIdentifier owner:nil options:nil] firstObject];
    }
    
    NSMutableDictionary *tempDic = _allSortedData[indexPath.row];
    NSString *sportPart = [tempDic objectForKey:@"sportPart"];
    NSMutableArray *tempArr = [tempDic objectForKey:@"data"];
    
    cell.typeLabel.text = sportPart;
    
    NSArray *imageArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SportImages" ofType:@"plist"]];
    NSArray * allSportTypes = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SportParts" ofType:@"plist"]];
    NSInteger imageIndex = [allSportTypes indexOfObject:sportPart];
    NSString *imageName = [imageArr objectAtIndex:imageIndex];
    cell.iconImageView.image = [UIImage imageNamed:imageName];
    
    if (self.isDay == YES) {
        cell.daysOrPerLabel.text = [NSString stringWithFormat:Local(@"%@ day"), @(tempArr.count)];
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
    NSString *sportPart = [tempDic objectForKey:@"sportPart"];
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
    NSString *monthStr = [[ASBaseManage dateFormatterForChart] stringFromDate:_displayDate];
    
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
