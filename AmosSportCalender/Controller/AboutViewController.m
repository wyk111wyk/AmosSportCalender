//
//  AboutViewController.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/17.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "AboutViewController.h"
#import "TOWebViewController.h"
#import "RESideMenu.h"
#import "DMPasscode.h"
#import "SettingStore.h"

static NSString *const cellID = @"aboutcell";

@interface AboutViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *visionLabel;

@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *tableArray;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_aboutLabel sizeToFit];
    
    NSDictionary *infoDictionary =[[NSBundle mainBundle]infoDictionary];
    NSString *infoStr = [NSString stringWithFormat:@"Amos Sport Diary  V %@.%@", [infoDictionary objectForKey:@"CFBundleShortVersionString"], [infoDictionary objectForKey:@"CFBundleVersion"]];
    
    _visionLabel.text = infoStr;
    [_visionLabel sizeToFit];
    
    _tableArray = [[NSArray alloc] initWithObjects:@"去Apple Store评分", @"瞅瞅作者写的运动心得", nil];
    
    [self.sideMenuViewController setPanFromEdge:NO];
//    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeAndOpenDrawer:(UIBarButtonItem *)sender {
//    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    [self.sideMenuViewController presentLeftMenuViewController];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    cell.textLabel.text = _tableArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/amos-yun-dong-ri-ji/id1031134284"]];
    }
    else {
        NSURL *url = [NSURL URLWithString:@"http://www.zhihu.com/question/21341170/answer/17946003"];
        TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:url];
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

@end
