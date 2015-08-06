//
//  TypeManageTableView.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/6.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "TypeManageTableView.h"
#import "TypeManageTVCell.h"
#import "NameManageTableView.h"
#import "UIViewController+MMDrawerController.h"

static NSString* const typeManageCellReuseId = @"typeManageCell";

@interface TypeManageTableView ()

@property (nonatomic, strong)NSArray *sportTypes;
@property (nonatomic, strong)NSString *sportType;
@property (nonatomic, strong)NSArray *sportNames;
@property (nonatomic)NSInteger indexRow;

@end

@implementation TypeManageTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSFileManager * defaultManager = [NSFileManager defaultManager];
    NSURL * documentPath = [[defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]firstObject];
    NSString * fileContainFloder = [documentPath.path stringByAppendingPathComponent:@"sportEventData"];
    NSString * fileSavePath = [fileContainFloder stringByAppendingPathComponent:@"sportTypeArray.plist"];
    NSArray * array = [NSArray arrayWithContentsOfFile:fileSavePath];
    
    self.sportTypes = array;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openAndCloseDrawer:(UIBarButtonItem *)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (nullable UIView *)tableView:(nonnull UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 22)];
    [headerView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel *headText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 22)];
    headText.textColor = [UIColor darkGrayColor];
    [headText setFont:[UIFont fontWithName:@"Arial" size:13]];
    headText.text = @"点击项目以编辑包含的运动种类，类型暂时无法编辑";
    [headText sizeToFit];
    headText.center = headerView.center;
    [headerView addSubview:headText];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sportTypes.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    TypeManageTVCell *cell = [tableView dequeueReusableCellWithIdentifier:typeManageCellReuseId forIndexPath:indexPath];
    
    NSString *tempStr = [[self.sportTypes objectAtIndex:indexPath.row] objectForKey:@"sportType"];
    cell.sportTypeLabel.text = tempStr;
    cell.sportTypeLabel.textColor = [self colorForsportType:tempStr];
    [cell.sportTypeLabel sizeToFit];
    
    cell.sportNameNumberLabel.text = [NSString stringWithFormat:@"包含数目：%lu 项", [[[self.sportTypes objectAtIndex:indexPath.row] objectForKey:@"sportName"] count]];
    [cell.sportNameNumberLabel sizeToFit];
    
    return cell;
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    self.sportNames = [[self.sportTypes objectAtIndex:indexPath.row] objectForKey:@"sportName"];
    self.sportType = [[self.sportTypes objectAtIndex:indexPath.row] objectForKey:@"sportType"];
    self.indexRow = indexPath.row;
    [self performSegueWithIdentifier:@"typeToNameSegue" sender:self];
    
//    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)prepareForSegue:(nonnull UIStoryboardSegue *)segue sender:(nullable id)sender
{
    if ([segue.identifier isEqualToString:@"typeToNameSegue"]) {
        NameManageTableView *nmTV = (NameManageTableView *)segue.destinationViewController;
        nmTV.sportNames = self.sportNames;
        nmTV.sportType = self.sportType;
        nmTV.indexRow = self.indexRow;
    }
  
//    NSLog(@"%@", NSStringFromSelector(_cmd));
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

@end
