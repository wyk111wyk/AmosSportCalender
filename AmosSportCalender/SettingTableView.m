//
//  SettingTableView.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/10.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <PgySDK/PgyManager.h>

#import "EventStore.h"
#import "SettingTableView.h"
#import "SettingStore.h"
//#import "UIViewController+MMDrawerController.h"
#import "ViewController.h"
#import "DMPasscode.h"
#import "DMKeychain.h"
#import "RESideMenu.h"
#import "DMPasscode.h"

static const NSString* KEYCHAIN_NAME = @"passcode";

@interface SettingTableView ()<UITextFieldDelegate, UIPickerViewDelegate,UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UITextField *genderTextField;

@property (weak, nonatomic) IBOutlet UILabel *iCloudLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UILabel *imageTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *iconBadgeNumberLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *imageTypeSegment;
@property (weak, nonatomic) IBOutlet UISwitch *iCloudSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *passwordSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *iconBadgeNumberSwitch;

@property (strong, nonatomic) UIPickerView *agePicker;
@property (strong, nonatomic) UIPickerView *genderPicker;
@property (strong, nonatomic) NSArray *ageArray;
@property (strong, nonatomic) NSArray *genderArray;
@property (weak, nonatomic) IBOutlet UILabel *lastestEdtionLabel;

@property (strong, nonatomic) UIBarButtonItem *finishButton;

@end

@implementation SettingTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.sideMenuViewController setPanFromEdge:NO];
//    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    
    SettingStore *setting = [SettingStore sharedSetting];
    
    self.finishButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(textFieldShouldReturn:)];
    
    //Picker初始化
    self.agePicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.agePicker.delegate = self;
    NSMutableArray *tempNumberArray = [NSMutableArray array];
    for (int i = 0; i < 5000; i = i+99) {
        for (int k = 0; k < 100; k++) {
            [tempNumberArray addObject:[NSString stringWithFormat:@"%i", k]];
        }
    }
    self.ageArray = tempNumberArray.copy;
    [self.agePicker selectRow:(5100/2 - 30) inComponent:0 animated:NO];
    
    self.genderPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.genderPicker.delegate = self;
    self.genderArray = [[NSArray alloc] initWithObjects:@"男", @"女", nil];
    
    //键盘初始化
    _nameTextField.returnKeyType = UIReturnKeyDone;
    _ageTextField.inputView = _agePicker;
    _genderTextField.inputView = _genderPicker;
    
    //UI显示数据初始化
    _nameTextField.text = setting.name;
    _ageTextField.text = setting.age;
    _genderTextField.text = setting.gender;
    
    _iCloudSwitch.on = setting.iCloud;
    
    _iconBadgeNumberSwitch.on = setting.iconBadgeNumber;
    
    if (setting.sportTypeImageMale) {
        _imageTypeSegment.selectedSegmentIndex = 0;
    }else{
        _imageTypeSegment.selectedSegmentIndex = 1;
    }
    
    if ([DMPasscode isPasscodeSet]) {
        _passwordLabel.textColor = [UIColor blackColor];
        _passwordSwitch.on = YES;
    }else{
        _passwordLabel.textColor = [UIColor lightGrayColor];
        _passwordSwitch.on = NO;
    }
    
    [self setLabelStatus:setting];
    
    NSDictionary *infoDictionary =[[NSBundle mainBundle]infoDictionary];
    NSString *infoStr = [NSString stringWithFormat:@"当前版本 V %@.%@", [infoDictionary objectForKey:@"CFBundleShortVersionString"], [infoDictionary objectForKey:@"CFBundleVersion"]];
    
    _lastestEdtionLabel.text = infoStr;
    _lastestEdtionLabel.textColor = [UIColor lightGrayColor];
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

- (IBAction)openAndCloseDrower:(UIBarButtonItem *)sender {
//    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
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
                    
                }else{
                    [_passwordSwitch setOn:NO animated:YES];
                    _passwordLabel.textColor = [UIColor lightGrayColor];
                }
            }];
            _passwordLabel.textColor = [UIColor blackColor];
            
            
        }else{
            [DMPasscode removePasscode];
            _passwordLabel.textColor = [UIColor lightGrayColor];
        }
    }
    
    [self setLabelStatus:setting];
    
//     [[NSNotificationCenter defaultCenter] postNotificationName:@"iconMessage" object:nil];
}

- (IBAction)switchValueChange:(UISegmentedControl *)sender {
    SettingStore *setting = [SettingStore sharedSetting];
    if (_imageTypeSegment.selectedSegmentIndex == 0) {
        setting.sportTypeImageMale = YES;
    }else if(_imageTypeSegment.selectedSegmentIndex == 1){
        setting.sportTypeImageMale = NO;
    }
}

#pragma mark - TextField

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.textColor = [UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:0.6];
    self.navigationItem.rightBarButtonItem = self.finishButton;
    
    if (textField == _ageTextField) {
        int i = [textField.text intValue];
        [self.agePicker selectRow:(5100/2 - 50 + i) inComponent:0 animated:NO];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.textColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = nil;
    
    SettingStore *setting = [SettingStore sharedSetting];
    
    setting.name = _nameTextField.text;
    setting.age = _ageTextField.text;
    setting.gender = _genderTextField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];;
    return YES;
}

#pragma mark - Picker

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    if (pickerView == self.agePicker) {
        return 1;
    }else if(pickerView == self.genderPicker){
        return 1;
    }else{
        return 1;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (pickerView == self.agePicker) {
        return self.ageArray.count;
    }else if(pickerView == self.genderPicker){
        return [self.genderArray count];
    }else{
        return 1;
    }
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (pickerView == self.agePicker) {
        return self.ageArray[row];
    }else{
        return self.genderArray[row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.agePicker) {
        _ageTextField.text = self.ageArray[row];
    }else{
        _genderTextField.text = _genderArray[row];
    }
}

#pragma mark -TableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            
            break;
        case 1:
            
            break;
        case 2:
            if (indexPath.row == 0) {
                [[PgyManager sharedPgyManager] checkUpdateWithDelegete:self selector:@selector(updateMethod:)];
            }else if (indexPath.row == 1.0){
                [self alertForResetSportType];
            }else if (indexPath.row == 2.0){
                [self alertForClearAllData];
            }
            break;
        default:
            break;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)updateMethod:sender
{
    [[PgyManager sharedPgyManager] checkUpdate];
    [[PgyManager sharedPgyManager] updateLocalBuildNumber];
}

#pragma mark - alert Method

- (void)alertForClearAllData
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"警告"
                                                                   message:@"你确定要清空所有的用户数据吗？"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * action) {
                                                [[EventStore sharedStore] removeAllItem];
                                                [[EventStore sharedStore] saveChanges];
                                                [self alertForDataCleared];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertForResetSportType
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"警告"
                                                                   message:@"确定吗？这会使所有自定义项目都失去。"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * action) {
                                                [self createAllSportTypeArray];
                                                [self alertForSportTypeResetted];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertForDataCleared
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"所有用户数据已被清空"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertForSportTypeResetted
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"运动项目选项已被重置"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Data

- (void)createAllSportTypeArray
{
    //获取Library目录
    /*  1. document是那些暴露给用户的数据文件，用户可见，可读写；
     2. library目录是App替用户管理的数据文件，对用户透明。所以，那些用户显式访问不到的文件要存储到这里，可读写。*/
    NSFileManager * defaultManager = [NSFileManager defaultManager];
    NSURL * documentPath = [[defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]firstObject];
    
    //新建一个目录存放该文件（如目录不存在，则新建一个）
    NSString * fileContainFloder = [documentPath.path stringByAppendingPathComponent:@"sportEventData"];
    
    //用函数判断该文件夹是否存在（不存在就写入会直接崩溃）
    BOOL isDic = YES;
    if (![defaultManager fileExistsAtPath:fileContainFloder isDirectory:&isDic]) // isDir判断是否为文件夹
    {   // 假如该文件夹不存在，直接新建一个
        
        [defaultManager createDirectoryAtPath:fileContainFloder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //设置创建的文件的目录和名字
    NSString * fileSavePath = [fileContainFloder stringByAppendingPathComponent:@"sportTypeArray.plist"];
    
    BOOL isDic1 = NO;
    if ([defaultManager fileExistsAtPath:fileSavePath isDirectory:&isDic1]) {
        
        NSArray *sportTypes = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sportTypes" ofType:@"plist"]];
        
        BOOL successWrited = [sportTypes writeToFile:fileSavePath atomically:YES];
        
        if (successWrited) {
            NSLog(@"已写入plist数据！");
        }else{
            NSLog(@"写入失败！");
        }
    }
}
@end
