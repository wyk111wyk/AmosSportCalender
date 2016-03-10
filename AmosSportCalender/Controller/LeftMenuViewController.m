//
//  LeftMenuViewController.m
//  AmosSportDiary
//
//  Created by Amos Wu on 15/8/20.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "LeftMenuView.h"
#import "RESideMenu.h"
#import "UMFeedback.h"
#import "CommonMarco.h"
#import "SportPartManageTV.h"

@interface LeftMenuViewController ()

@property (weak, nonatomic) IBOutlet LeftMenuView *sportCalendarView;
@property (weak, nonatomic) IBOutlet LeftMenuView *finishedListView;
@property (weak, nonatomic) IBOutlet LeftMenuView *typeManageView;
@property (weak, nonatomic) IBOutlet LeftMenuView *settingView;
@property (weak, nonatomic) IBOutlet LeftMenuView *feedbackView;
@property (weak, nonatomic) IBOutlet LeftMenuView *aboutView;

@property (strong, nonatomic) LeftMenuView *currentSelectedView;
@property (nonatomic, strong)NSArray *menuName;

@end

@implementation LeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.menuName = [[NSArray alloc] initWithObjects:@"运动日历", @"完成列表", @"类型管理", @"设置", @"反馈", @"关于", nil];

    _sportCalendarView.isSelected = YES;
    _sportCalendarView.titleLabel.text = _menuName[0];
    _sportCalendarView.imageView.image = [UIImage imageNamed:@"calendar"];
    _currentSelectedView = _sportCalendarView;
    
    _finishedListView.isSelected = NO;
    _finishedListView.titleLabel.text = _menuName[1];
    _finishedListView.imageView.image = [UIImage imageNamed:@"to_do"];
    
    _typeManageView.isSelected = NO;
    _typeManageView.titleLabel.text = _menuName[2];
    _typeManageView.imageView.image = [UIImage imageNamed:@"manage"];
    
    _settingView.isSelected = NO;
    _settingView.titleLabel.text = _menuName[3];
    _settingView.imageView.image = [UIImage imageNamed:@"settings"];
    
    _feedbackView.isSelected = NO;
    _feedbackView.titleLabel.text = _menuName[4];
    _feedbackView.imageView.image = [UIImage imageNamed:@"feedback"];
    
    _aboutView.isSelected = NO;
    _aboutView.titleLabel.text = _menuName[5];
    _aboutView.imageView.image = [UIImage imageNamed:@"about"];
    
//    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 有新消息
    UMFeedback *feed = [UMFeedback sharedInstance];
    if (feed.theNewReplies != nil && feed.theNewReplies.count > 0) {
        _feedbackView.nMesagePieView.hidden = NO;
        NSUInteger i = feed.theNewReplies.count;
        if (i > 9) {
            i = 9;
        }
        
        _feedbackView.nMessageLabel.text = [NSString stringWithFormat:@"%@", @(i)];
    }
    
//    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (IBAction)menuSelected:(LeftMenuView *)sender {
    
    if (sender == _currentSelectedView) {
        [self.sideMenuViewController hideMenuViewController];
    }else{
        _currentSelectedView.isSelected = NO;
        sender.isSelected = YES;
        _currentSelectedView = sender;
        
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        
        if (sender == _sportCalendarView) {
            if (DeBugMode) { NSLog(@"click 1"); }
            [self.sideMenuViewController setContentViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"nav"] animated:YES];
        }else if (sender == _finishedListView){
            if (DeBugMode) { NSLog(@"click 2"); }
            [self.sideMenuViewController setContentViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"summaryTableNav"] animated:YES];
        }else if (sender == _typeManageView){
            if (DeBugMode) { NSLog(@"click 3"); }
            SportPartManageTV *partTV = [[SportPartManageTV alloc] initWithStyle:UITableViewStylePlain];
            partTV.canEditEvents = YES;
            UINavigationController *partNav = [[UINavigationController alloc] initWithRootViewController:partTV];
            [self.sideMenuViewController setContentViewController:partNav];
        }else if (sender == _settingView){
            if (DeBugMode) { NSLog(@"click 4"); }
            [self.sideMenuViewController setContentViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"settingNav"] animated:YES];
        }else if (sender == _feedbackView){
            if (DeBugMode) { NSLog(@"click 5"); }
            
            UINavigationController *feedbackNav = [[UINavigationController alloc] initWithRootViewController:[UMFeedback feedbackViewController]];
            feedbackNav.navigationBar.tintColor = [UIColor colorWithRed:0.0000 green:0.5608 blue:0.5176 alpha:1];
            
            [self.sideMenuViewController setContentViewController:feedbackNav animated:YES];
            
        }else if (sender == _aboutView){
            if (DeBugMode) { NSLog(@"click 6"); }
            [self.sideMenuViewController setContentViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"aboutNav"] animated:YES];
        }
        
        [self.sideMenuViewController hideMenuViewController];
    }
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
