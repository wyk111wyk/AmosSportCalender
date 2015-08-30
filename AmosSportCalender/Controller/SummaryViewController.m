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

static NSString * const summaryCellReuseId = @"summaryTypeCell";

@interface SummaryViewController ()<UITableViewDataSource, UITableViewDelegate, XYPieChartDelegate, XYPieChartDataSource>

@property (strong, nonatomic) IBOutlet UIView *viewBackground;
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

@property (nonatomic, strong)NSMutableDictionary *eventsByDate;
@property (nonatomic, strong)NSArray *sortedKeyArray;
@property (nonatomic, strong)NSArray *sortedTypeArray; ///<tableView使用的数据源
@property (nonatomic, strong)NSDictionary *eventsDetailByType;

@property (nonatomic)BOOL isDay;
@end

@implementation SummaryViewController

@synthesize percentageLabel = _percentageLabel;

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    self.view2.frame = CGRectMake(0, self.view1.frame.size.height, screenWidth, 152);
    if (screenWidth == 320)
    { self.view2.frame = CGRectMake(0, self.view1.frame.size.height, screenWidth, 129.5); }
    else if (screenWidth == 414)
    { self.view2.frame = CGRectMake(0, self.view1.frame.size.height, screenWidth, 167.5); }
    
    self.tableView.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 376);
    
    self.view3.frame = CGRectMake(0, self.view1.frame.size.height + self.view2.frame.size.height, screenWidth, 384);
    if (screenWidth == 320) {
        self.view3.frame = CGRectMake(0, self.view1.frame.size.height + self.view2.frame.size.height, screenWidth, 360);
    }
    
//    NSLog(@"tableview: %g, view3: %g", self.tableView.frame.size.height, _view3.frame.size.height);
    
   CGFloat contentHight = self.view1.frame.size.height + self.view2.frame.size.height + self.view3.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(screenWidth, contentHight);
    self.scrollView.bounces = YES;
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.scrollEnabled = YES;
    
    [self.scrollView addSubview:self.view1];
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
    
//    [[self.tableView layer] setShadowOffset:CGSizeMake(2, 2)]; // 阴影的范围
//    [[self.tableView layer] setShadowRadius:2];                // 阴影扩散的范围控制
//    [[self.tableView layer] setShadowOpacity:1];               // 阴影透明度
//    [[self.tableView layer] setShadowColor:[UIColor colorWithWhite:0.2 alpha:0.45].CGColor]; // 阴影的颜色
    
    [self.percentageLabel.layer setCornerRadius:22];
    [self.percentageLabel setText:@"100%"];
    
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
        NSLog(@"数组Detail的数据已载入");
    });
    
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


- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }
    
    return dateFormatter;
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
    return [self colorForsportType:cellInfoDic[@"type"]];
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

#pragma mark - 判断cell文字颜色的方法
- (UIColor *)colorForsportType:(NSString *)sportType
{
    if ([sportType isEqualToString:@"胸部"]) {
        return [UIColor colorWithRed:0.5725 green:0.3216 blue:0.0667 alpha:0.8];
    }else if ([sportType isEqualToString:@"背部"]){
        return [UIColor colorWithRed:0.5725 green:0.5608 blue:0.1059 alpha:0.8];
    }else if ([sportType isEqualToString:@"肩部"]){
        return [UIColor colorWithRed:0.3176 green:0.5569 blue:0.0902 alpha:0.8];
    }else if ([sportType isEqualToString:@"腿部"]){
        return [UIColor colorWithRed:0.0824 green:0.5686 blue:0.5725 alpha:0.8];
    }else if ([sportType isEqualToString:@"体力"]){
        return [UIColor colorWithRed:0.9922 green:0.5765 blue:0.1490 alpha:0.8];
    }else if ([sportType isEqualToString:@"核心"]){
        return [UIColor colorWithRed:0.9922 green:0.2980 blue:0.9882 alpha:0.8];
    }else if ([sportType isEqualToString:@"手臂"]){
        return [UIColor colorWithRed:0.3647 green:0.4314 blue:0.9373 alpha:0.8];
    }else if ([sportType isEqualToString:@"其他"]){
        return [UIColor colorWithRed:0.6078 green:0.9255 blue:0.2980 alpha:0.8];
    }
    
    return [UIColor darkGrayColor];
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
