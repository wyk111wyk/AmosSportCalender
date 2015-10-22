//
//  GroupDetailTV.m
//  AmosSportDiary
//
//  Created by Amos Wu on 15/10/4.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "GroupDetailTV.h"
#import "GroupDetailCell.h"
#import "GroupStore.h"
#import "NewGroupTVViewController.h"
#import "NewEvevtViewController.h"

static NSString * const YKSummaryCellReuseId = @"GroupDetailCell";

@interface GroupDetailTV ()<UITableViewDataSource, UITableViewDelegate>
{
    NSInteger selectedSection; ///<点选的行数
    NSMutableArray *allTableDataArray;
}
@end

@implementation GroupDetailTV

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = _navTitle;
    UINib *nib = [UINib nibWithNibName:YKSummaryCellReuseId bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:YKSummaryCellReuseId];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backToPresentPage)];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *allEventsByType = [[NSMutableDictionary alloc] initWithDictionary:[[GroupStore sharedStore] allItems] copyItems:NO];
    _allDataArray = [allEventsByType[_belong][_navTitle] copy];
    [self initTheData];
    
    [self.tableView reloadData];
}

- (void)initTheData
{
    if (_allDataArray) {
        allTableDataArray = [[NSMutableArray alloc] initWithArray:_allDataArray];
    }
}

- (void)backToPresentPage
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)prepareForSegue:(nonnull UIStoryboardSegue *)segue sender:(nullable id)sender
{
    //    NSLog(@"%@", NSStringFromSelector(_cmd));
    if ([segue.identifier isEqualToString:@"newGroupEvent"]) {
        
        NewEvevtViewController *mvc = (NewEvevtViewController *)segue.destinationViewController;
        Event *event = [[GroupStore sharedStore] createItem];
        
        mvc.event = event;
        mvc.groupEdit = YES;
        mvc.belong = self.belong;
        mvc.groupName = self.navTitle;
//        mvc.event.sportType = self.belong;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (allTableDataArray.count > 0) {
        return allTableDataArray.count;
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:YKSummaryCellReuseId];
    Event *event = allTableDataArray[indexPath.row];
    cell.event = event;
    
    return cell;
}
    
@end
