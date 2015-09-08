//
//  AlertTV.m
//  AmosSportDiary
//
//  Created by Amos Wu on 15/9/8.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "AlertTV.h"
#import "SettingStore.h"

@interface AlertTV ()<UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *isAlertSwitch;
@property (nonatomic, strong) SettingStore *setting;
@property (weak, nonatomic) IBOutlet UITextField *alertDayField;

@property (strong, nonatomic) UIPickerView *agePicker;
@property (strong, nonatomic) NSArray *ageArray;

@end

@implementation AlertTV

- (void)viewDidLoad {
    [super viewDidLoad];
    _setting = [SettingStore sharedSetting];
    
    self.isAlertSwitch.on = _setting.alertForSport;
    self.alertDayField.text = [NSString stringWithFormat:@"%@", @(_setting.alertForDays)];
    
    //Picker初始化
    self.agePicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.agePicker.delegate = self;
    NSMutableArray *tempNumberArray = [NSMutableArray array];
    for (NSInteger i = 1; i < 26; i ++) {
        [tempNumberArray addObject:[NSString stringWithFormat:@"%@", @(i)]];
    }
    self.ageArray = tempNumberArray.copy;
    [self.agePicker selectRow:_setting.alertForDays-1 inComponent:0 animated:NO];
    
    self.alertDayField.inputView = self.agePicker;
    self.alertDayField.tintColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeSwitchValue:(UISwitch *)sender {
    if (self.isAlertSwitch.on) {
        _setting.alertForSport = YES;
    }else{
        _setting.alertForSport = NO;
    }

    [self.tableView reloadData];
}

#pragma mark - TextField

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(resignTheKeyboard)];
    self.navigationItem.rightBarButtonItem = doneButton;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem = nil;
    return YES;
}

- (void)resignTheKeyboard
{
    [self.alertDayField resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _setting.alertForSport ? 2 : 1;
}

#pragma mark - Picker

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.ageArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return self.ageArray[row];

}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.alertDayField.text = self.ageArray[row];
    _setting.alertForDays = [self.ageArray[row] integerValue];
}

@end
