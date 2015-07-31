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
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    
    self.group1 = [[NSArray alloc] initWithObjects:@"运动日历", @"数据简报", @"类型管理", nil];
    self.group2 = [[NSArray alloc] initWithObjects:@"设置", @"关于", nil];
    
    self.tableView.allowsSelection = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:YKMunuViewControllerCellReuseId];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
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
