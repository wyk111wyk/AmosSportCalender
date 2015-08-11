//
//  DetailSummaryVC.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/9.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "DetailSummaryVC.h"
#import "SummaryNewTVCell.h"
#import "Event.h"
#import "SettingStore.h"

static NSString * const YKSummaryCellReuseId = @"summaryNewTVCell";

@interface DetailSummaryVC ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dateArray;
@property (nonatomic, strong) NSMutableArray *eventArray;

@end

@implementation DetailSummaryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(returnToPastView)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.title = @"项目详情";
    
    self.backgroundView.layer.cornerRadius = 7;
    
    UINib *nib = [UINib nibWithNibName:YKSummaryCellReuseId bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:YKSummaryCellReuseId];
    [self.tableView setRowHeight:50.];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.dateArray = [NSMutableArray array];
    self.eventArray = [NSMutableArray array];
    if (self.eventsByDateForTable.count > 0) {
        for (int i = 0; i < self.eventsByDateForTable.count; i++) {
            NSArray *tempArray = [self.eventsByDateForTable[i] allKeys];
            [self.dateArray addObject:tempArray[0]];
    }
        for (int i = 0; i < self.eventsByDateForTable.count; i++) {
            NSArray *tempArray = [self.eventsByDateForTable[i] allValues];
            [self.eventArray addObject:tempArray[0]];
        }
    };
    
    //UI Label初始化
    self.sportTypeLabel.text = self.sportTypeStr;
    
    if (self.eventsByDateForTable.count > 0) {
        self.timesLabel.text = [NSString stringWithFormat:@"%lu次", self.eventsByDateForTable.count];
        
        NSDate *date = [[self dateFormatter] dateFromString:[self.dateArray lastObject]];
        NSString *titleStr = [[self dateFormatterStart] stringFromDate:date];
        self.startDateLabel.text = titleStr;
        //平均时间
        int timelastMin = 0;
        for (int i = 0; i<self.eventArray.count; i++) {
            int tempTimelast = 0;
            for (Event *event in self.eventArray[i]){
                tempTimelast = tempTimelast + event.timelast;
            }
            timelastMin = timelastMin + tempTimelast;
        }
        int avegmin = timelastMin / self.eventArray.count;
        self.avegTime.text = [NSString stringWithFormat:@"%i", avegmin];
        //平均间隔
        
        float totalDay = 0;
        for (int i = 0; i < self.dateArray.count - 1; i++) {
            NSDate *firstDate = [[self dateFormatter] dateFromString:self.dateArray[i]];
            NSDate *lastDate = [[self dateFormatter] dateFromString:self.dateArray[i+1]];
            NSTimeInterval betweenTime = [firstDate timeIntervalSinceDate:lastDate];
            float betweenDays=((int)betweenTime)/(3600*24); //记录第一天和最后一天的间隔时间，单位：天
            totalDay = totalDay + betweenDays;
        }
        float avegSpaceDay = totalDay / (float)(self.dateArray.count - 1);
        self.avegSpaceLabel.text = [NSString stringWithFormat:@"%.1f", avegSpaceDay];
        
        if (self.dateArray.count == 1) {
            self.avegSpaceLabel.text = @"0";
        }
        
        //BelowTableViewLabel
        self.belowTableViewLabel.text = @"继续努力吧！";
    }else{
        self.timesLabel.text = @"0次";
        self.startDateLabel.text = @"还未开始此项运动";
        self.avegTime.text = @"0";
        self.avegSpaceLabel.text = @"0";
        self.belowTableViewLabel.text = @"还没有该项运动类型的任何记录";
    }
    
    //图片设置
    SettingStore *setting = [SettingStore sharedSetting];
    if (setting.sportTypeImageMale) {
        self.imageView.image = [UIImage imageNamed:self.sportTypeStr];
    }else{
        NSString *femaleImage = [NSString stringWithFormat:@"女%@", _sportTypeStr];
        self.imageView.image = [UIImage imageNamed:femaleImage];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)returnToPastView
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.eventsByDateForTable.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    for (int i = 0; i < self.eventArray.count; i++) {
        
        if (section == i) {
            return [self.eventArray[i] count];
        }
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22;
}

- (nullable UIView *)tableView:(nonnull UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 22)];
    [headerView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    headerView.backgroundColor = [UIColor colorWithRed:0.9686 green:0.9686 blue:0.9686 alpha:1];
    
    UILabel *headText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 22)];
    headText.textColor = [UIColor darkGrayColor];
    [headText setFont:[UIFont fontWithName:@"Arial" size:14]];
    headText.text = @"text";
    [headText sizeToFit];
    [headerView addSubview:headText];
    
    for (int i = 0; i < self.dateArray.count; i++) {
        if (section == i) {
            NSDate *date = [[self dateFormatter] dateFromString:self.dateArray[i]];
            NSString *titleStr = [[self dateFormatterDisplay] stringFromDate:date];
            
            headText.text = titleStr;
            [headText sizeToFit];
            headText.center = headerView.center;
            return headerView;
        }
    }
    return headerView;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    SummaryNewTVCell *cell = [tableView dequeueReusableCellWithIdentifier:YKSummaryCellReuseId forIndexPath:indexPath];

    for (int i = 0; i < self.eventsByDateForTable.count; i++) {
        if (indexPath.section == i) {

            NSArray *array = self.eventArray[i];
            Event *event = array[indexPath.row];
            
            //Type Label
            cell.sportTypeLabel.text = [event.sportType substringToIndex:1];
            cell.sportTypeLabel.textColor = [self colorForsportType:event.sportType];
            [cell.sportTypeLabel sizeToFit];
            
            cell.sportNameLabel.text = event.sportName;
            cell.timelastLabel.text =[NSString stringWithFormat:@"%i分钟", event.timelast];
            cell.sportAttributeLabel.text = [self setSportAttributeText:event.times weight:event.weight rap:event.rap];
            [cell.sportAttributeLabel sizeToFit];
            
            if (event.done == NO) {
                cell.doneImageView.hidden = YES;
                cell.backgroundColor = [UIColor whiteColor];
            } else if (event.done == YES){
                cell.doneImageView.hidden = NO;
                cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.6];
            }
        }}
            
    return cell;
}

#pragma mark - 判断cell显示内容的方法
- (UIColor *)colorForsportType:(NSString *)sportType
{
    if ([sportType isEqualToString:@"胸部"]) {
        return [UIColor colorWithRed:0.5725 green:0.3216 blue:0.0667 alpha:0.7];
    }else if ([sportType isEqualToString:@"背部"]){
        return [UIColor colorWithRed:0.5725 green:0.5608 blue:0.1059 alpha:0.7];
    }else if ([sportType isEqualToString:@"肩部"]){
        return [UIColor colorWithRed:0.3176 green:0.5569 blue:0.0902 alpha:0.7];
    }else if ([sportType isEqualToString:@"腿部"]){
        return [UIColor colorWithRed:0.0824 green:0.5686 blue:0.5725 alpha:0.7];
    }else if ([sportType isEqualToString:@"体力"]){
        return [UIColor colorWithRed:0.9922 green:0.5765 blue:0.1490 alpha:0.7];
    }else if ([sportType isEqualToString:@"核心"]){
        return [UIColor colorWithRed:0.9922 green:0.2980 blue:0.9882 alpha:0.7];
    }else if ([sportType isEqualToString:@"其他"]){
        return [UIColor colorWithRed:0.6078 green:0.9255 blue:0.2980 alpha:0.7];
    }
    
    return [UIColor darkGrayColor];
}

- (NSString *)setSportAttributeText: (int)times weight: (float)weight rap:(int)rap
{
    if (weight == 0 && times > 0) {
        return [NSString stringWithFormat:@"%d组 x %d次", rap, times];
    }else if (weight == 220 && times > 0){
        return [NSString stringWithFormat:@"%d组 x %d次  自身重量", rap, times];
    }else if (times == 0 && rap == 0){
        return @"无额外属性";
    }else{
        return [NSString stringWithFormat:@"%d组 x %d次   %.1fkg", rap, times, weight];
    }
}

#pragma mark - 时间格式
- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }
    
    return dateFormatter;
}

- (NSDateFormatter *)dateFormatterDisplay
{
    static NSDateFormatter *dateFormatterDisplay;
    if(!dateFormatterDisplay){
        dateFormatterDisplay = [NSDateFormatter new];
        dateFormatterDisplay.dateFormat = @"yyyy年MM月dd日 EEEE";
        [dateFormatterDisplay setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    }
    
    return dateFormatterDisplay;
}

- (NSDateFormatter *)dateFormatterStart
{
    static NSDateFormatter *dateFormatterDisplay;
    if(!dateFormatterDisplay){
        dateFormatterDisplay = [NSDateFormatter new];
        dateFormatterDisplay.dateFormat = @"从yyyy年MM月dd日起";
        [dateFormatterDisplay setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    }
    
    return dateFormatterDisplay;
}

@end
