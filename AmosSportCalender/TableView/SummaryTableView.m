//
//  SummaryTableView.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/4.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "Event.h"
#import "EventStore.h"
#import "SummaryTableView.h"
#import "SummaryTVCell.h"
//#import "UIViewController+MMDrawerController.h"
#import "RESideMenu.h"
#import "DMPasscode.h"
#import "SettingStore.h"
#import "MobClick.h"

static NSString * const YKSummaryCellReuseId = @"summaryCell";

@interface SummaryTableView ()

@property (nonatomic, strong)NSMutableDictionary *eventsByDate;
@property (nonatomic, strong)NSArray *sortedKeyArray;
@property (weak, nonatomic) IBOutlet UILabel *underTableLabel;
@property (strong, nonatomic)UIDatePicker *datePicker;
@property (strong, nonatomic)UITextField *searchTextField;
@property (strong, nonatomic)NSString *searchStr;

@property (nonatomic) NSInteger indexRow;

@end

@implementation SummaryTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    
    [self.sideMenuViewController setPanFromEdge:NO];
//    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    
    //datePick初始化
    NSString *minDate = @"1990-01-01";
    NSString *maxDate = @"2030-01-01";
    NSDateFormatter *limtedDateFormatter = [NSDateFormatter new];
    limtedDateFormatter.dateFormat = @"yyyy-MM-dd";
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.minimumDate = [limtedDateFormatter dateFromString:minDate];
    self.datePicker.maximumDate = [limtedDateFormatter dateFromString:maxDate];
    [self.datePicker setDate:[NSDate date] animated:YES];
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
    //初始化数据
    self.eventsByDate = [[NSMutableDictionary alloc] initWithDictionary:[[EventStore sharedStore] allItems] copyItems:NO];
    
    self.sortedKeyArray = [NSArray array];
    NSMutableArray *tempArray = [NSMutableArray array];
    NSMutableArray *tempEventArray = [NSMutableArray array];
    NSMutableArray *newTempArray = [NSMutableArray array];
    
    tempArray = [[self.eventsByDate allKeys] copy];
    
//    NSEnumerator * enumeratorKey = [self.eventsByDate keyEnumerator]; //objectEnumerator对value进行遍历
//    for (NSObject *object in enumeratorKey) {
//        NSLog(@"遍历KEY的值: %@",object);
//        [tempArray addObject:object];
//    }
    
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
    
    self.sortedKeyArray = [newTempArray copy];
    
    if (self.sortedKeyArray.count == 0){
        self.underTableLabel.text = @"还没有任何运动记录，赶快开始运动吧！";
    }else if (self.sortedKeyArray.count > 0){
        self.underTableLabel.text = [NSString stringWithFormat:@"总计运动天数：%@天", @(self.sortedKeyArray.count)];
    }
    
    //设置标题
    self.navigationItem.title = [NSString stringWithFormat:@"完成列表（共计：%@天）", @(self.sortedKeyArray.count)];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"2_FinishedList_Page"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"2_FinishedList_Page"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
#pragma mark - Buttons

- (IBAction)OpenAndCloseMenu:(UIBarButtonItem *)sender {
//    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    [self.sideMenuViewController presentLeftMenuViewController];
}

-(void)dateChanged:(id)sender{
    
    self.searchStr = [[self dateFormatter] stringFromDate:self.datePicker.date];
    self.searchTextField.text = [[self dateFormatterDisplay] stringFromDate:self.datePicker.date];;
}

- (IBAction)searchOneDate:(UIBarButtonItem *)sender {
    
    [self alertForSearch];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sortedKeyArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    for (int i = 0; i < self.sortedKeyArray.count; i++) {
    
    if (section == i) {
        NSString *key = self.sortedKeyArray[i];
        NSArray *array = [self.eventsByDate valueForKey:key];
        return [array count];
        }
    }
    
    return 1;
}

- (nullable UIView *)tableView:(nonnull UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 22)];
    [headerView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    headerView.backgroundColor = [UIColor colorWithWhite:0.45 alpha:0.55];

    UILabel *headText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 22)];
    headText.textColor = [UIColor whiteColor];
    [headText setFont:[UIFont fontWithName:@"Arial" size:14]];
    headText.text = @"text";
    [headText sizeToFit];
    [headerView addSubview:headText];
    
    for (int i = 0; i < self.sortedKeyArray.count; i++) {
        if (section == i) {
            NSDate *date = [[self dateFormatter] dateFromString:self.sortedKeyArray[i]];
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
    SummaryTVCell *cell = [tableView dequeueReusableCellWithIdentifier:YKSummaryCellReuseId forIndexPath:indexPath];
    
    for (int i = 0; i < self.sortedKeyArray.count; i++) {
        if (indexPath.section == i) {
            
            Event *event = [self.eventsByDate[self.sortedKeyArray[i]] objectAtIndex:indexPath.row];
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
        }
    }
    
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
    }else if ([sportType isEqualToString:@"手臂"]){
        return [UIColor colorWithRed:0.3647 green:0.4314 blue:0.9373 alpha:0.7];
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

- (void)alertForSearch
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"定位到指定日期"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    NSString *dateStr = [[self dateFormatterDisplay] stringFromDate:[NSDate date]];
    self.datePicker.date = [NSDate date];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = dateStr;
        textField.tintColor = [UIColor clearColor];
        textField.inputView = self.datePicker;
        [textField becomeFirstResponder];
    }];
    
    self.searchTextField = alert.textFields[0];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"搜索"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
        if (![self.sortedKeyArray containsObject:self.searchStr]) {
            [self alertForNoResult];
        }else{
            _indexRow = [self.sortedKeyArray indexOfObject:self.searchStr];
            
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:_indexRow];
            [[self tableView] scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
                                                
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {
                                                
                                            }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertForNoResult
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"不好意思"
                                                                   message:@"这一天您没有做任何运动"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {
                                                
                                            }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end

