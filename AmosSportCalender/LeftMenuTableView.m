//
//  LeftMenuTableView.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/7/31.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "LeftMenuTableView.h"

static NSString * const YKMunuViewControllerCellReuseId = @"CellReuseId";
@interface LeftMenuTableView ()

@property (nonatomic, strong)NSArray *group1;
@property (nonatomic, strong)NSArray *group2;

@end

@implementation LeftMenuTableView

- (void)viewDidLoad {
    [super viewDidLoad];

    self.group1 = [[NSArray alloc] initWithObjects:@"运动日历", @"数据总结", @"类型管理", nil];
    self.group2 = [[NSArray alloc] initWithObjects:@"设置", @"关于", nil];
    
    self.tableView.allowsSelection = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 更改状态栏样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 20.;
            break;
        case 1:
            return 10.;
            break;
        default:
            return 0;
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.group1.count;
            break;
        case 1:
            return self.group2.count;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:YKMunuViewControllerCellReuseId forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = _group1[indexPath.row];
            break;
        case 1:
            cell.textLabel.text = _group2[indexPath.row];
            break;
        default:
            break;
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.highlightedTextColor = [UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1];
    
    return cell;
    
}

@end
