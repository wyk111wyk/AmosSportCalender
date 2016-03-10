//
//  SummaryViewController.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/3.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//
#define screenWidth ([UIScreen mainScreen].bounds.size.width)
#define screenHeight ([UIScreen mainScreen].bounds.size.height)
#define screenScale ([UIScreen mainScreen].scale)
#define screenSize ([UIScreen mainScreen].bounds.size)

#import <QuartzCore/QuartzCore.h>

#import "SummaryViewController.h"
#import "summaryTypeCell.h"
#import "EventStore.h"
#import "Event.h"
#import "DetailSummaryVC.h"
#import "SettingStore.h"
#import "DMPasscode.h"
#import "MobClick.h"
#import "UUChart.h"
#import "CommonMarco.h"

static NSString * const summaryCellReuseId = @"summaryTypeCell";

@interface SummaryViewController ()<UITableViewDataSource, UITableViewDelegate, XYPieChartDelegate, XYPieChartDataSource, UUChartDataSource>
{
    UISwipeGestureRecognizer *swipeGestureRight;
    UISwipeGestureRecognizer *swipeGestureLeft;
}
@property (strong, nonatomic) IBOutlet UIView *viewBackground;

@property (weak, nonatomic) IBOutlet UIView *contantView;
@property (strong, nonatomic) UUChart *chartView;
@property (strong, nonatomic) IBOutlet UIView *view2;
@property (strong, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UIView *vLineView;
@property (weak, nonatomic) IBOutlet UIView *hLineView;
@property (weak, nonatomic) IBOutlet UIView *shadoView1;
@property (weak, nonatomic) IBOutlet UIView *shadoView21;
@property (weak, nonatomic) IBOutlet UIView *shadoView22;
@property (weak, nonatomic) IBOutlet XYPieChart *pieChartView;

@property (weak, nonatomic) IBOutlet UIImageView *mostTypeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *leastTypeImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *theWholeNumber;
@property (weak, nonatomic) IBOutlet UILabel *theWholeTime;
@property (weak, nonatomic) IBOutlet UILabel *aveTimesAWeek;
@property (weak, nonatomic) IBOutlet UILabel *aveTime;
@property (weak, nonatomic) IBOutlet UILabel *percentageLabel;
@property (strong ,nonatomic) UILabel *expLabel;
@property (strong, nonatomic) IBOutlet UIButton *leftAButton;
@property (strong, nonatomic) IBOutlet UIButton *rightAButton;

@property (nonatomic, strong)NSMutableDictionary *eventsByDate;
@property (nonatomic, strong)NSArray *sortedKeyArray;
@property (nonatomic, strong)NSArray *sortedTypeArray; ///<tableView使用的数据源
@property (nonatomic, strong)NSDictionary *eventsDetailByType;

@property (nonatomic, strong)NSDate *firstDayofMonth; ///<这个月的第一天的日子
@property (nonatomic, strong)NSArray *chartDataArray;
@property (nonatomic, strong)NSString *monthAndYear;
@property (nonatomic, strong)UITapGestureRecognizer *tap;
@property (nonatomic)BOOL isDay;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation SummaryViewController

@synthesize percentageLabel = _percentageLabel;

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTheFrames];
    [self initButtons];
    
    //设置当前的月份和年份
    self.monthAndYear = [[self dateFormatterForMonth] stringFromDate:[NSDate date]];
    
    //初始化数据
    self.eventsByDate = [[NSMutableDictionary alloc] initWithDictionary:[[EventStore sharedStore] allItems] copyItems:NO];
    self.sortedKeyArray = [NSArray array];
    NSMutableArray *tempArray = [NSMutableArray array]; //所有key的Array
    tempArray = [[self.eventsByDate allKeys] copy];
    
    if (self.eventsByDate.count == 0){
        self.percentageLabel.text = @"0%";
    }
    
    //进行日期排序
    self.sortedKeyArray = [self sortKeyFromDate:tempArray]; //所有日期排序后生成的新key
    self.sortedTypeArray = [self sortEventsFromMostToLeast:self.eventsMostByDate];
    //self.sortedTypeArray包含字典的数组，对字典中key=number进行了从大到小的排列
    
    //2.创建队列
    dispatch_queue_t queue = dispatch_queue_create("myQueue",DISPATCH_QUEUE_SERIAL);
    //3.多次使用队列组的方法执行任务, 只有异步方法
    //3.1.执行3次循环
    dispatch_async(queue, ^{
        self.eventsDetailByType = [self sortForTypeDetail];
//        NSLog(@"数组Detail的数据已载入");
    });
    
    [self setView1NumberLabel];
    
    [self arrayForChartData: [NSDate date]];
    [self.chartView showInView:self.contantView];
    
    [self.contantView bringSubviewToFront:self.expLabel];
    [self.contantView bringSubviewToFront:self.leftAButton];
    [self.contantView bringSubviewToFront:self.rightAButton];
    
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
    NSString *mostTypeStr = [self.sortedTypeArray[0] valueForKey:@"type"];
    NSString *leastTypeStr = [[self.sortedTypeArray lastObject] valueForKey:@"type"];
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

- (void)initTheFrames
{
    //TableView初始化
    UINib *nib = [UINib nibWithNibName:summaryCellReuseId bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:summaryCellReuseId];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.isDay = YES;
    
    //View的初始化
    self.view.backgroundColor = [UIColor colorWithRed:0.9529 green:0.9529 blue:0.9529 alpha:1];
    _viewBackground.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    self.scrollView.frame = CGRectMake(0, 64, screenWidth, screenHeight);
    self.view1.frame = CGRectMake(0, 0, screenWidth, 167);
    
    self.view4.frame = CGRectMake(0, self.view1.frame.size.height, screenWidth, 165);
    self.chartView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(0, 14, screenWidth - 24, self.contantView.frame.size.height - 19)
                                                   withSource:self
                                                    withStyle:UUChartLineStyle];
    
    NSString *monthStr = [[self dateFormatterForMonth] stringFromDate:[NSDate date]];
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
    
    //    NSLog(@"tableview: %g, view3: %g", self.tableView.frame.size.height, _view3.frame.size.height);
    
    CGFloat contentHight = self.view1.frame.size.height + self.view2.frame.size.height + self.view3.frame.size.height + self.view4.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(screenWidth, contentHight);
    self.scrollView.bounces = YES;
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.scrollEnabled = YES;
    
    [self.scrollView addSubview:self.view1];
    [self.scrollView addSubview:self.view4];
    [self.scrollView addSubview:self.view2];
    [self.scrollView addSubview:self.view3];
    
    //    NSLog(@"1 screenWidth is %g, screen hight %g, contentHight is %g", screenWidth, screenHeight, contentHight);
    
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
    
    //添加视差效果
//    UIInterpolatingMotionEffect *motionEffect;
//    motionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
//       type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
//    motionEffect.minimumRelativeValue = @(-25);
//    motionEffect.maximumRelativeValue = @(25);
//    [self.view1 addMotionEffect:motionEffect];
//    [self.view4 addMotionEffect:motionEffect];
//    [self.view2 addMotionEffect:motionEffect];
//    
//    motionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
//    motionEffect.minimumRelativeValue = @(-25);
//    motionEffect.maximumRelativeValue = @(25);
//    [self.view1 addMotionEffect:motionEffect];
//    [self.view4 addMotionEffect:motionEffect];
//    [self.view2 addMotionEffect:motionEffect];
}

- (void)initButtons
{
    [self.leftAButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightAButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.leftAButton.alpha = 0;
    self.rightAButton.alpha = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.pieChartView reloadData];
    [MobClick beginLogPageView:@"1.1_Summary_Page"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"1.1_Summary_Page"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

- (void)makeButtonDisappear
{
    if (self.rightAButton.alpha == 0.7) {
        //提前直接隐藏buttons
//        [self.timer fire];
        //重新设置自动消失buttons的时间为3秒
        [self.timer setFireDate:[[NSDate date] dateByAddingTimeInterval:3]];
    }else{
        self.rightAButton.alpha = 0.7;
        self.leftAButton.alpha = 0.7;
        
        //设置3秒钟后，隐藏buttons
        self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(makeButtonOnlyDisappear) userInfo:nil repeats:NO];
    }
}

- (void)makeButtonOnlyDisappear
{
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.rightAButton.alpha = 0;
                         self.leftAButton.alpha = 0;
                     }
                     completion:nil];
}

- (void)buttonClicked: (id)sender
{
//    NSLog(@"%li", self.contantView.subviews.count);
    
    [self makeButtonDisappear];
    
    //删除当下的图表
    [[self.contantView.subviews firstObject] removeFromSuperview];
    
    if (sender == swipeGestureLeft || sender == _leftAButton) {
        //重绘上月数据的图表
        NSString * lastMonthAndYear = [self lastMonthFrom:self.monthAndYear];
        NSDate *lastMonth = [[self dateFormatterForMonth] dateFromString:lastMonthAndYear];
        [self arrayForChartData:lastMonth];
        self.monthAndYear = lastMonthAndYear;
    }else if (sender == swipeGestureRight || sender == _rightAButton) {
        //重绘下月数据的图表
        NSString * nextMonthAndYear = [self nextMonthFrom:self.monthAndYear];
        NSDate *nextMonth = [[self dateFormatterForMonth] dateFromString:nextMonthAndYear];
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
    [self.contantView bringSubviewToFront:self.expLabel];
    [self.contantView bringSubviewToFront:self.leftAButton];
    [self.contantView bringSubviewToFront:self.rightAButton];
}
#pragma mark - 用于计算数据的方法

- (NSArray *)sortKeyFromDate: (NSMutableArray *)tempArray
{
    NSMutableArray *tempEventArray = [NSMutableArray array];
    NSMutableArray *newTempArray = [NSMutableArray array];
    
    for (NSString *str in tempArray){
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        tempDic[@"year"] = [str substringWithRange:NSMakeRange(6, 4)];
        tempDic[@"month"] = [str substringWithRange:NSMakeRange(3, 2)];
        tempDic[@"day"] = [str substringToIndex:2];
        [tempEventArray addObject:tempDic];
    }
    
    //对日期进行排序
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"year" ascending:NO];
    NSSortDescriptor *secondDescriptor = [[NSSortDescriptor alloc] initWithKey:@"month" ascending:NO];
    NSSortDescriptor *thirdDescriptor = [[NSSortDescriptor alloc] initWithKey:@"day" ascending:NO];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:firstDescriptor, secondDescriptor, thirdDescriptor,nil];
    NSArray *beforeSortedArray = [tempEventArray sortedArrayUsingDescriptors:sortDescriptors];
    
    for (NSMutableDictionary *temDic in beforeSortedArray){
        NSString *tempStr = [NSString stringWithFormat:@"%@-%@-%@", temDic[@"day"], temDic[@"month"], temDic[@"year"]];
        [newTempArray addObject:tempStr];
    }
    
    return [newTempArray copy];
}


- (NSArray *)sortEventsFromMostToLeast: (NSMutableDictionary *)sortedTypeByDate
{
    NSArray * array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sportTypes" ofType:@"plist"]];
    NSMutableArray *sportTypes = [NSMutableArray array];
    for (int i = 0; i < array.count; i++){
        sportTypes[i] = [[array objectAtIndex:i] objectForKey:@"sportType"];
    }
    //sportTypes是包含了所有运动项目序列的数组
    
    NSUInteger p = array.count;
    
    NSMutableArray *numberArray = [[NSMutableArray alloc] initWithCapacity:array.count];

    NSArray * allValueTypes = [sortedTypeByDate allValues];
    
    for (int i = 0; i < p; i++) { //p = 7
        NSMutableDictionary *tempMuDic = [NSMutableDictionary dictionary];
        int a = 0;
        NSString *type = sportTypes[i];
        //快速枚举遍历所有Value的值
        for (NSObject *object in allValueTypes) {
            if ([type isEqualToString:[NSString stringWithFormat:@"%@", object]]) {
                a++;
            }
        }
        [tempMuDic setValue:[NSNumber numberWithInt:a] forKey:@"number"];
        [tempMuDic setValue:type forKey:@"type"];
        [numberArray addObject:tempMuDic];
    }
    
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:firstDescriptor,nil];
    NSArray *afterSortedArray = [numberArray sortedArrayUsingDescriptors:sortDescriptors];
    
    return [afterSortedArray copy];
}

- (NSDictionary *)sortForTypeDetail
{
    NSArray * array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sportTypes" ofType:@"plist"]];
    NSMutableArray *sportTypes = [NSMutableArray array];
    for (int i = 0; i < array.count; i++){
        sportTypes[i] = [[array objectAtIndex:i] objectForKey:@"sportType"];
    }
    //sportTypes是包含了所有运动项目序列的数组
    
    NSMutableDictionary *tempMuDic0 = [NSMutableDictionary dictionary];
    
    for (int i = 0; i < sportTypes.count; i++) {
        NSMutableArray *tempArray1 = [NSMutableArray array];
        //1. 每次遍历提取一个type
        NSString *keyTpye = sportTypes[i];
        //2. 遍历有值的每一个日期
        for (NSString *keyDate in self.sortedKeyArray){
            //3. 限定：假如该日期的主要运动类型Equal正在遍历的类型
            if ([keyTpye isEqualToString:self.eventsMostByDate[keyDate]]) {
                NSMutableDictionary *tempMuDic1 = [NSMutableDictionary dictionary];
                //4. 根据日期提取主数据中的运动细节数组
                [tempMuDic1 setValue:self.eventsByDate[keyDate] forKey:keyDate];
                //5. 根据先前排序好的日期顺序，归到一个临时数组中
                [tempArray1 addObject:tempMuDic1];
            }
        }
        //5. 将临时数组装入最终的临时字典
        [tempMuDic0 setValue:tempArray1 forKey:keyTpye];
    }
    
    return [tempMuDic0 copy];
}

//数组中最大的一个数
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

//某个月1号是星期几
- (int)weekOfFirstDay: (NSDate *)today
{
    NSString *monthStr = [[self dateFormatterForMonth] stringFromDate:today];
    NSDate *firstDayofMonth = [[self dateFormatter] dateFromString:[NSString stringWithFormat:@"01-%@", monthStr]];
    
    //调个时差
    NSTimeZone *localZone = [NSTimeZone localTimeZone];
    NSInteger interval = [localZone secondsFromGMTForDate:firstDayofMonth];
    self.firstDayofMonth = [firstDayofMonth dateByAddingTimeInterval:interval];
    
    //找到星期
    
    return [self weekOfParticularDay:self.firstDayofMonth];
}

- (int)weekOfParticularDay: (NSDate *)date
{
    NSString *weekStr = [[self dateFormatterForWeek] stringFromDate:date];
    int weekNum = 0;
    
    if ([weekStr isEqualToString:Local(@"Mon")]) {
        weekNum = 0;
    }else if ([weekStr isEqualToString:Local(@"Tue")]){
        weekNum = 1;
    }else if ([weekStr isEqualToString:Local(@"Wed")]){
        weekNum = 2;
    }else if ([weekStr isEqualToString:Local(@"Thu")]){
        weekNum = 3;
    }else if ([weekStr isEqualToString:Local(@"Fri")]){
        weekNum = 4;
    }else if ([weekStr isEqualToString:Local(@"Sat")]){
        weekNum = 5;
    }else if ([weekStr isEqualToString:Local(@"Sun")]){
        weekNum = 6;
    }
    
    return weekNum;
}

//生成用于表格的数据（每周的运动次数）
- (void)arrayForChartData: (NSDate *)date
{
    //本月第一天星期几的代表数字 (0 - 6)
    int weekDay = [self weekOfFirstDay:date];
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
        NSString *veryFirstDayStr = [[self dateFormatter] stringFromDate:veryFirstDay];
        [lastMonthLastWeek addObject:veryFirstDayStr];
    }
    for (int i = 0; i <= 6 - weekDay; i++) {
        NSInteger interval =  i*24*60*60;
        NSDate *veryFirstDay = [self.firstDayofMonth dateByAddingTimeInterval:interval];
        NSString *veryFirstDayStr = [[self dateFormatter] stringFromDate:veryFirstDay];
        [lastMonthLastWeek addObject:veryFirstDayStr];
    }
    //计算这个月最后一周的所有日期
    NSMutableArray *thisMonthLastWeek = [NSMutableArray array];
    NSDate *lastDayOfThisMonthDate = [self thisMonthLastDay:date];
    int lastWeekDay = [self weekOfParticularDay:lastDayOfThisMonthDate];
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
        NSString *veryFirstDayStr = [[self dateFormatter] stringFromDate:veryFirstDay];
        [thisMonthLastWeek addObject:veryFirstDayStr];
    }
    for (int i = 0; i <= 6 - lastWeekDay; i++) {
        NSInteger interval =  i*24*60*60;
        NSDate *veryFirstDay = [lastDayOfThisMonthDate dateByAddingTimeInterval:interval];
        NSString *veryFirstDayStr = [[self dateFormatter] stringFromDate:veryFirstDay];
        [thisMonthLastWeek addObject:veryFirstDayStr];
    }
    //除去和上个月相关联的第一周，先把这个月的下个周一起的运动天数统计出来
    //首先要把这个月所有的运动具体天数统计出来
    NSMutableArray *thisMonthSportDates = [NSMutableArray array];
    for (NSString *date in self.sortedKeyArray){
        NSString *dayStr = [date substringFromIndex:3];
        NSString *subStr = [[self dateFormatterForMonth] stringFromDate:self.firstDayofMonth];
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

- (NSString *)lastMonthFrom: (NSString *)dateStr
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *compoents = [cal components:(NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:[[self dateFormatterForMonth] dateFromString:dateStr]];
    
    NSInteger thisMonth = compoents.month;
    NSInteger thisYear = compoents.year;
    if (thisMonth == 1) {
        thisMonth = 13;
        thisYear -= 1;
    }
    
    NSString *monthAndYear = [NSString stringWithFormat:@"%li-%li",(long)thisMonth - 1,(long)thisYear];
    
    if (thisMonth < 11) {
        monthAndYear = [NSString stringWithFormat:@"0%li-%li",(long)thisMonth - 1,(long)thisYear];
    }
    return monthAndYear;
}

- (NSString *)nextMonthFrom: (NSString *)dateStr
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *compoents = [cal components:(NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:[[self dateFormatterForMonth] dateFromString:dateStr]];
    
    NSInteger thisMonth = compoents.month;
    NSInteger thisYear = compoents.year;
    if (thisMonth == 12) {
        thisMonth = 0;
        thisYear += 1;
    }
    
    NSString *monthAndYear = [NSString stringWithFormat:@"%li-%li",(long)thisMonth + 1,(long)thisYear];
    
    if (thisMonth < 9) {
        monthAndYear = [NSString stringWithFormat:@"0%li-%li",(long)thisMonth + 1,(long)thisYear];
    }
    return monthAndYear;
}

- (NSDate *)thisMonthLastDay: (NSDate *)date
{
    NSString *thisMonth = [[self dateFormatterForMonth] stringFromDate:date];
    NSString *nextMonthAndYear = [self nextMonthFrom:thisMonth];
    
    NSDate *nextMonthFirstDay = [[self dateFormatter] dateFromString:[NSString stringWithFormat:@"01-%@", nextMonthAndYear]];
    //调个时差
    NSTimeZone *localZone = [NSTimeZone localTimeZone];
    NSInteger interval = [localZone secondsFromGMTForDate:nextMonthFirstDay];
    NSDate *nextMonthFirstDayNew = [nextMonthFirstDay dateByAddingTimeInterval:interval];
    //减去一天
    NSInteger intervalToLastDay = - 24*60*60;
    NSDate *lastMonthLastDay = [nextMonthFirstDayNew dateByAddingTimeInterval:intervalToLastDay];
    
    return lastMonthLastDay;
}

- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }
    
    return dateFormatter;
}

- (NSDateFormatter *)dateFormatterForMonth
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"MM-yyyy";
    }
    
    return dateFormatter;
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

//计算主页的4个数字
- (void)setView1NumberLabel
{
    //设置UI显示的属性
    //1-1总计天数
    self.theWholeNumber.text =[NSString stringWithFormat:@"%@", @([self.eventsByDate count])];
    //1-2总时间
    int timelastMin = 0;
    for (NSString *key in self.sortedKeyArray){
        int tempTimelast = 0;
        for (Event *event in self.eventsByDate[key]){
            tempTimelast = tempTimelast + event.timelast;
        }
        timelastMin = timelastMin + tempTimelast;
    }
    float timelastHour = (float)timelastMin / 60.;
    self.theWholeTime.text = [NSString stringWithFormat:@"%.0f", timelastHour];
    //1-3平均每次多少时间
    if (self.eventsByDate.count > 0) {
        float avegTimeMin = (float)timelastMin / self.eventsByDate.count;
        self.aveTime.text = [NSString stringWithFormat:@"%.0f", avegTimeMin];
    }else{self.aveTime.text = @"0";}
    
    //1-4平均每周几次
    if (self.eventsByDate.count > 0){
        
        NSDate *firstDate = [[self dateFormatter] dateFromString:[self.sortedKeyArray lastObject]];
        NSDate *lastDate = [[self dateFormatter] dateFromString:self.sortedKeyArray[0]];
        NSTimeInterval betweenTime = [lastDate timeIntervalSinceDate:firstDate];
        float betweenDays = ((int)betweenTime)/(3600*24); //记录第一天和最后一天的间隔时间，单位：天
        float avegTimesAWeek = self.eventsByDate.count / (betweenDays/7.);
        
        if (betweenDays < 8) {
            self.aveTimesAWeek.text = [NSString stringWithFormat:@"%@", @(self.eventsByDate.count)];
        }else{
            self.aveTimesAWeek.text = [NSString stringWithFormat:@"%.1f", avegTimesAWeek];
        }
        
    }else{self.aveTimesAWeek.text = @"0";}
    
    //iphone5的话字体缩小
    if (screenWidth == 320) {
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
#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.sortedTypeArray.count > 0) {
        return self.sortedTypeArray.count;
    }else{
        return 0;
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    summaryTypeCell *cell = [self.tableView dequeueReusableCellWithIdentifier:summaryCellReuseId];
    
    NSDictionary *cellInfoDic = self.sortedTypeArray[indexPath.row];
    cell.typeLabel.text = [NSString stringWithFormat:@"%@", cellInfoDic[@"type"]];
    
    if (self.isDay == YES) {
        cell.daysOrPerLabel.text = [NSString stringWithFormat:@"%@ 天", cellInfoDic[@"number"]];
    }else{
        float f = [cellInfoDic[@"number"] floatValue] / (float)self.eventsByDate.count;
        cell.daysOrPerLabel.text = [NSString stringWithFormat:@"%.1f%%", f*100];
    }

    cell.changeShowBlock = ^(){
        
        if (self.isDay == YES) {
            self.isDay = NO;
        }else{
            self.isDay = YES;
        }
        
        [self.tableView reloadData];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailSummaryVC *detailVC = [DetailSummaryVC new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:detailVC];
    
    NSDictionary *cellInfoDic = self.sortedTypeArray[indexPath.row];
    NSString *typeStr = [NSString stringWithFormat:@"%@", cellInfoDic[@"type"]];
    
    detailVC.eventsByDateForTable = self.eventsDetailByType[typeStr];
    NSDictionary *dic = self.sortedTypeArray[indexPath.row];
    detailVC.sportTypeStr = [dic valueForKey:@"type"];
    
    
    nav.modalTransitionStyle = UIModalTransitionStylePartialCurl; //改变模态视图出现的动画
    [self presentViewController:nav animated:YES completion:^{
    }];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - XYPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    return self.sortedTypeArray.count;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    return [self.sortedTypeArray[index][@"number"] intValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    NSDictionary *cellInfoDic = self.sortedTypeArray[index];
    SettingStore *setting = [SettingStore sharedSetting];
    NSArray *oneColor = [setting.typeColorArray objectAtIndex:[self colorForsportType:cellInfoDic[@"type"]]];
    UIColor *pickedColor = [UIColor colorWithRed:[oneColor[0] floatValue] green:[oneColor[1] floatValue] blue:[oneColor[2] floatValue] alpha:1];
    
    return pickedColor;
}

- (NSString *)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index
{
    return self.sortedTypeArray[index][@"type"];
}

#pragma mark - XYPieChart Delegate
- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index
{
//    NSLog(@"will select slice at index %lu",index);
    NSDictionary *cellInfoDic = self.sortedTypeArray[index];
    float f = [cellInfoDic[@"number"] floatValue] / (float)self.eventsByDate.count;
    self.percentageLabel.text = [NSString stringWithFormat:@"%.1f%%", f*100];
}
- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index
{
//    NSLog(@"will deselect slice at index %lu",index);
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
    NSDate *date = [[self dateFormatterForMonth] dateFromString:self.monthAndYear];
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

#pragma mark - 判断cell文字颜色的方法
- (int)colorForsportType:(NSString *)sportType
{
    if ([sportType isEqualToString:@"胸部"]) {
        return 0;
    }else if ([sportType isEqualToString:@"背部"]){
        return 1;
    }else if ([sportType isEqualToString:@"肩部"]){
        return 2;
    }else if ([sportType isEqualToString:@"腿部"]){
        return 3;
    }else if ([sportType isEqualToString:@"体力"]){
        return 4;
    }else if ([sportType isEqualToString:@"核心"]){
        return 5;
    }else if ([sportType isEqualToString:@"手臂"]){
        return 6;
    }else if ([sportType isEqualToString:@"综合"]){
        return 7;
    }
    
    return 0;
}

+(UIImage*)captureView: (UIView *)theView
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
