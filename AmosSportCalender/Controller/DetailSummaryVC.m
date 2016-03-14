//
//  DetailSummaryVC.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/9.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "DetailSummaryVC.h"
#import "SummaryDisplayCell.h"
#import "DMPasscode.h"
#import "CommonMarco.h"
#import "YYKit.h"

@interface DetailSummaryVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *allDateEvents;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DetailSummaryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initFrameUI];
    [self getTheFreshDate];
    [self updateDisplayData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 初始化框架UI

- (void)initFrameUI {
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:nil];
    [rightButton setActionBlock:^(id _Nonnull sender) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.title = @"项目详情";
    
    //设置BackgroundView的属性
    self.backgroundView.layer.cornerRadius = 7;
    [[self.backgroundView layer] setShadowOffset:CGSizeMake(1, 1)]; // 阴影的范围
    [[self.backgroundView layer] setShadowRadius:2];                // 阴影扩散的范围控制
    [[self.backgroundView layer] setShadowOpacity:1];               // 阴影透明度
    [[self.backgroundView layer] setShadowColor:[UIColor colorWithWhite:0.2 alpha:0.55].CGColor]; // 阴影的颜色
    
    [self.tableView setRowHeight:50.];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)getTheFreshDate {
    _allDateEvents = [[NSMutableArray alloc] initWithCapacity:_eventsByDateForTable.count];
    for (DateEventStore *dateStore in _eventsByDateForTable){
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        NSString *criStr = [NSString stringWithFormat:@" WHERE dateKey = '%@' AND isDone = '1' ", dateStore.dateKey];
        NSArray *tempArr = [SportRecordStore findByCriteria:criStr];
        [tempDic setObject:tempArr forKey:@"data"];
        [tempDic setObject:dateStore.dateKey forKey:@"dateKey"];
        [_allDateEvents addObject:tempDic];
    }
}

- (void)updateDisplayData {
    //UI Label初始化
    self.sportTypeLabel.text = self.sportTypeStr;
    
    if (self.eventsByDateForTable.count > 0) {
        //总次数
        self.timesLabel.text = [NSString stringWithFormat:@"%@次", @(self.eventsByDateForTable.count)];
        //开始日期
        DateEventStore *firstDateStore = [_eventsByDateForTable lastObject];
        NSDate *date = [[ASBaseManage dateFormatterForDMY] dateFromString:firstDateStore.dateKey];
        NSString *titleStr = [[self dateFormatterStart] stringFromDate:date];
        self.startDateLabel.text = titleStr;
        //平均时间
        NSInteger timelastMin = 0;
        for (DateEventStore *dateStore in _eventsByDateForTable) {
            timelastMin += dateStore.doneMins;
        }
        NSInteger avegmin = timelastMin / _eventsByDateForTable.count;
        self.avegTime.text = [NSString stringWithFormat:@"%@", @(avegmin)];
        
        if (_eventsByDateForTable.count == 1) {
            self.avegSpaceLabel.text = @"0";
        }else {
            //平均间隔
            DateEventStore *lastDateStore = [_eventsByDateForTable firstObject];
            NSDate *firstDate = [[ASBaseManage dateFormatterForDMY] dateFromString:firstDateStore.dateKey];
            NSDate *lastDate = [[ASBaseManage dateFormatterForDMY] dateFromString:lastDateStore.dateKey];
            NSTimeInterval betweenTime = [lastDate timeIntervalSinceDate:firstDate];
            NSInteger betweenDays = betweenTime / (3600*24);
            float avgGapDays = (float)betweenDays / (float)(_eventsByDateForTable.count-1);
            self.avegSpaceLabel.text = [NSString stringWithFormat:@"%.1f", avgGapDays];
        }
        
        self.belowTableViewLabel.text = @"继续努力吧！";
    }else{
        self.timesLabel.text = @"0次";
        self.startDateLabel.text = @"还未开始此项运动";
        self.avegTime.text = @"0";
        self.avegSpaceLabel.text = @"0";
        self.belowTableViewLabel.text = @"还没有该项运动类型的任何记录";
    }
    
    if (screenWidth == WidthiPhone5) {
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

#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.allDateEvents.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableDictionary *tempDic = _allDateEvents[section];
    NSArray *tempArr = [tempDic objectForKey:@"data"];
    return [tempArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22;
}

- (nullable UIView *)tableView:(nonnull UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 22)];
    [headerView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    headerView.backgroundColor = [UIColor colorWithWhite:0.65 alpha:0.65];
    
    UILabel *headText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 22)];
    headText.textColor = [UIColor whiteColor];
    [headText setFont:[UIFont fontWithName:@"Arial" size:14]];
    headText.text = @"text";
    [headText sizeToFit];
    [headerView addSubview:headText];
    
    NSMutableDictionary *tempDic = _allDateEvents[section];
    NSString *titleStr = [tempDic objectForKey:@"dateKey"];
    NSDate *tempDate = [[ASBaseManage dateFormatterForDMY] dateFromString:titleStr];
    NSString *titleText = [[ASBaseManage dateFormatterForDMYE] stringFromDate:tempDate];
    
    headText.text = titleText;
    [headText sizeToFit];
    headText.center = headerView.center;
    
    return headerView;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SummaryDisplayCell";
    SummaryDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:cellIdentifier owner:nil options:nil] firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSMutableDictionary *tempDic = _allDateEvents[indexPath.section];
    NSArray *tempArr = [tempDic objectForKey:@"data"];
    SportRecordStore *recordStore = tempArr[indexPath.row];
    
    cell.recordStore = recordStore;
    
    return cell;
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
