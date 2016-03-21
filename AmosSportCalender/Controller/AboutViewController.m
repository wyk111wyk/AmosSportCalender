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
#import "CommonMarco.h"

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
    
    self.navigationItem.title = Local(@"About");
    
    NSDictionary *infoDictionary =[[NSBundle mainBundle]infoDictionary];
    NSString *infoStr = [NSString stringWithFormat:@"Amos Sport Diary  V %@.%@", [infoDictionary objectForKey:@"CFBundleShortVersionString"], [infoDictionary objectForKey:@"CFBundleVersion"]];
    
    _visionLabel.text = infoStr;
    [_visionLabel sizeToFit];
    
    _aboutLabel.text = @"欢迎使用Amos运动日记！\n这是一款强大的健身协助软件，通过记录、回顾、计划，清晰的了解自己的状态和已经完成的工作。\n欢迎大家在使用后给我反馈和心得，包括交流运动的经验等，一起让软件变得更好用和顺手。（摇晃屏幕即可“反馈”）";
    _tableArray = [[NSArray alloc] initWithObjects:Local(@"Review in Apple Store"), Local(@"Read something from Amos"), nil];
    
    [self.sideMenuViewController setPanFromEdge:NO];
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
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = CellBackgoundColor;
    
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
