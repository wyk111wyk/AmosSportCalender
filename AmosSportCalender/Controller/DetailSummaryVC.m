//
//  DetailSummaryVC.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/9.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "DetailSummaryVC.h"
#import "SummaryDisplayCell.h"
#import "Event.h"
#import "SettingStore.h"
#import "DMPasscode.h"
#import "MobClick.h"
#import "CommonMarco.h"

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
    
    //设置BackgroundView的属性
    self.backgroundView.layer.cornerRadius = 7;
    [[self.backgroundView layer] setShadowOffset:CGSizeMake(1, 1)]; // 阴影的范围
    [[self.backgroundView layer] setShadowRadius:2];                // 阴影扩散的范围控制
    [[self.backgroundView layer] setShadowOpacity:1];               // 阴影透明度
    [[self.backgroundView layer] setShadowColor:[UIColor colorWithWhite:0.2 alpha:0.55].CGColor]; // 阴影的颜色
    
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
        self.timesLabel.text = [NSString stringWithFormat:@"%@次", @(self.eventsByDateForTable.count)];
        
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
    
    if ([UIScreen mainScreen].bounds.size.width == 320) {
        UIFont *font = [UIFont systemFontOfSize:22];
        [_avegTime setFont:font];
        [_avegSpaceLabel setFont:font];
    }
    
    [_avegSpaceLabel sizeToFit];
    [_avegTime sizeToFit];
    
    //图片设置
    SettingStore *setting = [SettingStore sharedSetting];
    if (setting.sportTypeImageMale) {
        self.imageView.image = [UIImage imageNamed:self.sportTypeStr];
    }else{
        NSString *femaleImage = [NSString stringWithFormat:@"女%@", self.sportTypeStr];
        self.imageView.image = [UIImage imageNamed:femaleImage];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"1.1.1_SummaryDetail_Page"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"1.1.1_SummaryDetail_Page"];
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
    headerView.backgroundColor = [UIColor colorWithWhite:0.45 alpha:0.55];;
    
    UILabel *headText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 22)];
    headText.textColor = [UIColor whiteColor];
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
    SummaryDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:YKSummaryCellReuseId forIndexPath:indexPath];

    for (int i = 0; i < self.eventsByDateForTable.count; i++) {
        if (indexPath.section == i) {

            NSArray *array = self.eventArray[i];
            Event *event = array[indexPath.row];
            
            //Type Label
            cell.sportTypeLabel.text = [event.sportType substringToIndex:1];
            
            SettingStore *setting = [SettingStore sharedSetting];
            NSArray *oneColor = [setting.typeColorArray objectAtIndex:[self colorForsportType:event.sportType]];
            UIColor *pickedColor = [UIColor colorWithRed:[oneColor[0] floatValue] green:[oneColor[1] floatValue] blue:[oneColor[2] floatValue] alpha:1];
            
            cell.sportTypeLabel.textColor = pickedColor;
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
                cell.backgroundColor = [UIColor colorWithWhite:0.97 alpha:0.8];
            }
        }}
            
    return cell;
}

#pragma mark - 判断cell显示内容的方法
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
