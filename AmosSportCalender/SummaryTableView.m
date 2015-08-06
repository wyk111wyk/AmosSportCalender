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
#import "UIViewController+MMDrawerController.h"

static NSString * const YKSummaryCellReuseId = @"summaryCell";

@interface SummaryTableView ()

@property (nonatomic, strong)NSMutableDictionary *eventsByDate;
@property (nonatomic, strong)NSArray *sortedKeyArray;
@property (weak, nonatomic) IBOutlet UILabel *underTableLabel;

@end

@implementation SummaryTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    
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
        self.underTableLabel.text = [NSString stringWithFormat:@"总计运动天数：%lu天", (unsigned long)self.sortedKeyArray.count];
    }

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
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
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
    headerView.backgroundColor = [UIColor colorWithRed:0.9686 green:0.9686 blue:0.9686 alpha:1];

    UILabel *headText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 22)];
    headText.textColor = [UIColor darkGrayColor];
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
            
            cell.sportTypeLabel.text = [event.sportType substringToIndex:1];
            cell.sportTypeLabel.textColor = [self colorForsportType:event.sportType];
            [cell.sportTypeLabel sizeToFit];
            cell.sportNameLabel.text = event.sportName;
            cell.timelastLabel.text =[NSString stringWithFormat:@"%i分钟", event.timelast];
            cell.sportAttributeLabel.text = [self setSportAttributeText:event.times weight:event.weight rap:event.rap];
            if (event.done == NO) {
                cell.doneImageView.hidden = YES;
            } else if (event.done == YES){
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
    }else if ([sportType isEqualToString:@"其他"]){
        return [UIColor colorWithRed:0.6078 green:0.9255 blue:0.2980 alpha:0.8];
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

@end

