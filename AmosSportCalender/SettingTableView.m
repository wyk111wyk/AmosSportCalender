//
//  SettingTableView.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/10.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "SettingTableView.h"
#import "SettingStore.h"
#import "CommonMarco.h"

#import "ViewController.h"
#import "DMPasscode.h"
#import "DMKeychain.h"
#import "RESideMenu.h"
#import "DMPasscode.h"

static const NSString* KEYCHAIN_NAME = @"passcode";

@interface SettingTableView ()

@property (weak, nonatomic) IBOutlet UILabel *alertDaysLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UILabel *imageTypeLabel;

@property (weak, nonatomic) IBOutlet UILabel *iconBadgeNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstDayOfWeekLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightUnit;

@property (weak, nonatomic) IBOutlet UISegmentedControl *imageTypeSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *firstDayOfWeekSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *unitSegment;

@property (weak, nonatomic) IBOutlet UISwitch *passwordSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *iconBadgeNumberSwitch;

@end

@implementation SettingTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SettingStore *setting = [SettingStore sharedSetting];
    _iconBadgeNumberSwitch.on = setting.iconBadgeNumber;
    
    if (setting.sportTypeImageMale) {
        _imageTypeSegment.selectedSegmentIndex = 0;
    }else{
        _imageTypeSegment.selectedSegmentIndex = 1;
    }
    
    if (setting.firstDayOfWeek) {
        _firstDayOfWeekSegment.selectedSegmentIndex = 0;
    }else{
        _firstDayOfWeekSegment.selectedSegmentIndex = 1;
    }
    
    _unitSegment.selectedSegmentIndex = setting.weightUnit;
    
    if ([DMPasscode isPasscodeSet]) {
        _passwordLabel.textColor = [UIColor blackColor];
        _passwordSwitch.on = YES;
    }else{
        _passwordLabel.textColor = [UIColor lightGrayColor];
        _passwordSwitch.on = NO;
    }
    
    [self setLabelStatus:setting];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    SettingStore *setting = [SettingStore sharedSetting];
    
    if (setting.alertForSport) {
        self.alertDayLabel.text = [NSString stringWithFormat:Local(@"%@ day"), @(setting.alertForDays)];
    }else{
        self.alertDayLabel.text = [NSString stringWithFormat:Local(@"No alert")];
    }
    
    [self.alertDayLabel sizeToFit];
}

- (void)setLabelStatus: (SettingStore *)setting
{
    if (setting.iconBadgeNumber) {
        _iconBadgeNumberLabel.textColor = [UIColor blackColor];
    }else{
        _iconBadgeNumberLabel.textColor = [UIColor lightGrayColor];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Method

- (IBAction)openAndCloseDrower:(UIBarButtonItem *)sender {
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (IBAction)changeSwitchView:(UISwitch *)sender {
    SettingStore *setting = [SettingStore sharedSetting];
    //是否显示角标
    if (sender == _iconBadgeNumberSwitch) {
        if (_iconBadgeNumberSwitch.on) {
            setting.iconBadgeNumber = YES;
        }else{
            setting.iconBadgeNumber = NO;
        }
        
    //是否启用TouchID
    }else if(sender == _passwordSwitch){
        if (_passwordSwitch.on) {
       
            [DMPasscode setupPasscodeInViewController:self completion:^(BOOL success, NSError *error) {
                if (success) {
                    setting.isTouchIDOn = YES;
                }else{
                    [_passwordSwitch setOn:NO animated:YES];
                    _passwordLabel.textColor = [UIColor lightGrayColor];
                }
            }];
            _passwordLabel.textColor = [UIColor blackColor];
        
        }else{
            [DMPasscode removePasscode];
            _passwordLabel.textColor = [UIColor lightGrayColor];
            setting.isTouchIDOn = NO;
        }
    }
    
    [self setLabelStatus:setting];
}

- (IBAction)switchValueChange:(UISegmentedControl *)sender {
    SettingStore *setting = [SettingStore sharedSetting];
    //图片类型选择
    if (_imageTypeSegment.selectedSegmentIndex == 0){
        setting.sportTypeImageMale = YES;
    }else if(_imageTypeSegment.selectedSegmentIndex == 1){
        setting.sportTypeImageMale = NO;
    }
    //每周第一天的选择
    if (_firstDayOfWeekSegment.selectedSegmentIndex == 0){
        setting.firstDayOfWeek = YES; //周日
    }else if(_firstDayOfWeekSegment.selectedSegmentIndex == 1){
        setting.firstDayOfWeek = NO;  //周一
    }
    if (_unitSegment.selectedSegmentIndex == 0) {
        setting.weightUnit = 0;
    }else {
        setting.weightUnit = 1;
    }
}

#pragma mark -TableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
            
            break;
        case 1:
            if (indexPath.row == 0){
                
            }else if (indexPath.row == 1){
                //清空所有数据
                [self alertForClearAllData];
            }
            break;
        default:
            break;
    }
}

#pragma mark - alert Method

- (void)alertForClearAllData
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:Local(@"Warning")                                                                   message:Local(@"Confirm to delete all user data？")
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Okay")
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * action) {
                                                if ([SportRecordStore clearTable]){
                                                    [DateEventStore clearTable];
                                                    [self alertForDataCleared];
                                                }
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertForDataCleared
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:Local(@"All user data has been clear" )
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Okay")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
