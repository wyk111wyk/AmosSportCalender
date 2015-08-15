//
//  LeftMenuTableView.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/7/31.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "LeftMenuTableView.h"
#import "SummaryTableView.h"
#import "SummaryViewController.h"
#import "UIViewController+MMDrawerController.h"

static NSString * const YKMunuViewControllerCellReuseId = @"CellReuseId";
@interface LeftMenuTableView ()

@property (nonatomic, strong)NSArray *group1;
@property (nonatomic, strong)NSArray *group2;

@property (nonatomic, weak)LeftMenuTableView *menuTable;

@property (nonatomic, strong)NSIndexPath *selectedIndex;
@end

@implementation LeftMenuTableView

- (void)viewDidLoad {
    [super viewDidLoad];

    self.group1 = [[NSArray alloc] initWithObjects:@"运动日历", @"完成列表", @"类型管理", nil];
    self.group2 = [[NSArray alloc] initWithObjects:@"设置", @"反馈", @"关于", nil];
    
    self.tableView.allowsSelection = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.selectedIndex = [NSIndexPath indexPathForRow:0 inSection:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self.tableView selectRowAtIndexPath:self.selectedIndex animated:NO scrollPosition:UITableViewScrollPositionNone];
//    NSLog(@"indexPath: %@", self.selectedIndex);
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
            if ([_group1[indexPath.row] isEqualToString:@"运动日历"]) {
                cell.imageView.image = [UIImage imageNamed:@"calendar"];
            }else if ([_group1[indexPath.row] isEqualToString:@"完成列表"]){
                cell.imageView.image = [UIImage imageNamed:@"to_do"];
            }else if ([_group1[indexPath.row] isEqualToString:@"类型管理"]){
                cell.imageView.image = [UIImage imageNamed:@"manage"];
            }
            break;
        case 1:
            cell.textLabel.text = _group2[indexPath.row];
            if ([_group2[indexPath.row] isEqualToString:@"设置"]) {
                cell.imageView.image = [UIImage imageNamed:@"settings"];
            }else if ([_group2[indexPath.row] isEqualToString:@"反馈"]){
                cell.imageView.image = [UIImage imageNamed:@"feedback"];
            }else if ([_group2[indexPath.row] isEqualToString:@"关于"]){
                cell.imageView.image = [UIImage imageNamed:@"about"];
            }
            break;
        default:
            break;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.highlightedTextColor = [UIColor colorWithRed:0.2000 green:0.6235 blue:0.9882 alpha:0.8];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:14];
    
    if (indexPath == self.selectedIndex) {
        cell.textLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:14];
        cell.textLabel.textColor = [UIColor colorWithRed:0.2000 green:0.6235 blue:0.9882 alpha:0.8];
        switch (indexPath.section) {
            case 0:
                cell.textLabel.text = _group1[indexPath.row];
                if ([_group1[indexPath.row] isEqualToString:@"运动日历"]) {
                    cell.imageView.image = [UIImage imageNamed:@"Scalendar"];
                }else if ([_group1[indexPath.row] isEqualToString:@"完成列表"]){
                    cell.imageView.image = [UIImage imageNamed:@"Stodo_list"];
                }else if ([_group1[indexPath.row] isEqualToString:@"类型管理"]){
                    cell.imageView.image = [UIImage imageNamed:@"Smanage"];
                }
                break;
            case 1:
                cell.textLabel.text = _group2[indexPath.row];
                if ([_group2[indexPath.row] isEqualToString:@"设置"]) {
                    cell.imageView.image = [UIImage imageNamed:@"Ssettings"];
                }else if ([_group2[indexPath.row] isEqualToString:@"反馈"]){
                    cell.imageView.image = [UIImage imageNamed:@"Sfeedback"];
                }else if ([_group2[indexPath.row] isEqualToString:@"关于"]){
                    cell.imageView.image = [UIImage imageNamed:@"Sabout"];
                }
                break;
            default:
                break;
        }
    }
    
    return cell;
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    self.selectedIndex = indexPath;
    
    switch (indexPath.section) {
            
        case 0:
            if (indexPath.row == 0.0){
                NSLog(@"click section = %li row = %li", (long)indexPath.section, (long)indexPath.row);
                
                [self.mm_drawerController setCenterViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"nav"] withCloseAnimation:YES completion:nil];
                
            }else if (indexPath.row == 1.0){
                NSLog(@"click section = %li row = %li", (long)indexPath.section, (long)indexPath.row);
                
                [self.mm_drawerController setCenterViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"summaryTableNav"] withCloseAnimation:YES completion:nil];
                
            }else if (indexPath.row == 2.0){
                NSLog(@"click section = %li row = %li", (long)indexPath.section, (long)indexPath.row);
                
                [self.mm_drawerController setCenterViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"typeManageNav"] withCloseAnimation:YES completion:nil];
            }
            break;
        case 1:
            if (indexPath.row == 0.0){
                NSLog(@"click section = %li row = %li", (long)indexPath.section, (long)indexPath.row);
                
                [self.mm_drawerController setCenterViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"settingNav"] withCloseAnimation:YES completion:nil];
            }else if (indexPath.row == 1.0){
                NSLog(@"click section = %li row = %li", (long)indexPath.section, (long)indexPath.row);
                
                [self.mm_drawerController setCenterViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"feedbackNav"] withCloseAnimation:YES completion:nil];
            }else if (indexPath.row == 2.0){
                NSLog(@"click section = %li row = %li", (long)indexPath.section, (long)indexPath.row);
            }
            break;
        default:
            break;
    }
    
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    [self.tableView reloadData];
}

@end
