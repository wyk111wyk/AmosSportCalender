//
//  SummaryTableView.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/4.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "SummaryTableView.h"
#import "UIViewController+MMDrawerController.h"

static NSString * const YKSummaryCellReuseId = @"summaryCell";

@interface SummaryTableView ()

@end

@implementation SummaryTableView

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:YKSummaryCellReuseId forIndexPath:indexPath];
    
    return cell;
}

@end
