//
//  SummaryTableView.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/4.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "CommonMarco.h"
#import "SummaryDisplayCell.h"
#import "SummaryTableView.h"
#import "RESideMenu.h"

@interface SummaryTableView ()

@property (nonatomic, strong) NSMutableArray *allDateEvents;
@property (nonatomic, strong) UIView *tableViewBV;

@end

@implementation SummaryTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menuIcon"] style:UIBarButtonItemStylePlain target:self action:nil];
    [menuButton setActionBlock:^(id _Nonnull sender) {
        [self.sideMenuViewController presentLeftMenuViewController];
    }];
    self.navigationItem.leftBarButtonItem = menuButton;
    menuButton.tintColor = MyGreenColor;
    
    NSArray *allDates = [DateEventStore findByCriteria:@" ORDER BY dateKey DESC "];
    
    NSMutableArray *allDateKey = [NSMutableArray array];
    for (DateEventStore *dateStore in allDates){
        [allDateKey addObject:dateStore.dateKey];
    }
    
    NSArray *allSortedDateKey = [[ASDataManage sharedManage] sortDateString:allDateKey.copy];
    _allDateEvents = [[NSMutableArray alloc] initWithCapacity:allDates.count];
    for (NSString *dateKey in allSortedDateKey){
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        NSString *criStr = [NSString stringWithFormat:@" WHERE dateKey = '%@' AND isDone = '1' AND isGroupSet = '0' ", dateKey];
        NSArray *tempArr = [SportRecordStore findByCriteria:criStr];
        if (tempArr.count == 0) {
            [DateEventStore deleteObjectsWithFormat:@" WHERE dateKey = '%d' ", dateKey];
        }else {
            [tempDic setObject:tempArr forKey:@"data"];
            [tempDic setObject:dateKey forKey:@"dateKey"];
            [_allDateEvents addObject:tempDic];
        }
    }
    
    //设置标题
    self.navigationItem.title = [NSString stringWithFormat:Local(@"FinishList (%@ day)"), @(allDates.count)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_allDateEvents.count == 0) {
        [self initBackgroundView];
    }
}

- (void)initBackgroundView {
    //这里是TableView的背景文字
    _tableViewBV = [[UIView alloc] initWithFrame:self.tableView.frame];
    _tableViewBV.backgroundColor = MyWhite;
    NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:Local(@"There is no finished sport")];
    one.font = [UIFont systemFontOfSize:20];
    one.color = [UIColor colorWithWhite:0.85 alpha:1];;
    YYTextShadow *shadow = [YYTextShadow new];
    shadow.color = [UIColor colorWithWhite:0.6 alpha:1];
    shadow.offset = CGSizeMake(0.2, 0.5);
    shadow.radius = 2;
    one.textInnerShadow = shadow;
    
    YYLabel *tableViewBGLabel = [[YYLabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
    tableViewBGLabel.center = self.tableView.center;
    tableViewBGLabel.attributedText = one;
    tableViewBGLabel.numberOfLines = 0;
    tableViewBGLabel.textAlignment = NSTextAlignmentCenter;
    [_tableViewBV addSubview:tableViewBGLabel];
    
    self.tableView.backgroundView = _tableViewBV;
}

- (BOOL)checkDicObject:(NSMutableDictionary *)tempDic key:(NSString *)keyStr {
    if ([tempDic objectForKey:keyStr]) {
        return YES;
    }else {
        NSMutableArray *tempArr = [NSMutableArray array];
        [tempDic setObject:tempArr forKey:keyStr];
        return NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
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

@end

