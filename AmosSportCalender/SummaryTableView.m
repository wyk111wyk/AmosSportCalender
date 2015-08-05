//
//  SummaryTableView.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/4.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "EventStore.h"
#import "SummaryTableView.h"
#import "SummaryTVCell.h"
#import "UIViewController+MMDrawerController.h"

static NSString * const YKSummaryCellReuseId = @"summaryCell";

@interface SummaryTableView ()

@property (nonatomic, strong)NSMutableDictionary *eventsByDate;
@property (nonatomic, strong)NSArray *sortedArray;

@end

@implementation SummaryTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //初始化数据
    self.eventsByDate = [[NSMutableDictionary alloc] initWithDictionary:[[EventStore sharedStore] allItems] copyItems:NO];
    
    self.sortedArray = [NSArray array];
    NSMutableArray *tempArray = [NSMutableArray array];
    NSMutableArray *tempEventArray = [NSMutableArray array];
    
    tempArray = [[self.eventsByDate allKeys] copy];
    
    NSEnumerator * enumeratorKey = [self.eventsByDate keyEnumerator];
    for (NSObject *object in enumeratorKey) {
        NSLog(@"遍历KEY的值: %@",object);
        [tempArray addObject:object];
    }
    
    //对日期进行排序
//    NSArray *result = [tempArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        
//        NSLog(@"%@ ~ %@", obj1, obj2);
//        
//        return [obj2 compare:obj1];
//    }];

//    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventDate" ascending:YES];
//    
//    NSArray *sortDescriptors = [NSArray arrayWithObjects:firstDescriptor, nil];
//    
//    NSArray *sortedArray = [tempArray sortedArrayUsingDescriptors:sortDescriptors];
//    
    NSEnumerator * enumeratorValue = [self.eventsByDate objectEnumerator];
    for (NSObject *object in enumeratorValue) {
        NSLog(@"遍历Value的值: %@",object);
        [tempEventArray addObject:object];
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
        dateFormatterDisplay.dateFormat = @"yyyy年mm月dd日 EEEE";
    }
    
    return dateFormatterDisplay;
}
#pragma mark - Buttons

- (IBAction)OpenAndCloseMenu:(UIBarButtonItem *)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (nullable NSString *)tableView:(nonnull UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"2015年6月";
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    SummaryTVCell *cell = [tableView dequeueReusableCellWithIdentifier:YKSummaryCellReuseId forIndexPath:indexPath];
    
    return cell;
}

@end
