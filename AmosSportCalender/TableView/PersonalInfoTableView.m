//
//  PersonalInfoTableView.m
//  AmosSportDiary
//
//  Created by Amos Wu on 15/8/26.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "PersonalInfoTableView.h"
#import "RESideMenu.h"
#import "CommonMarco.h"

@interface PersonalInfoTableView ()<UITextFieldDelegate, UIPickerViewDelegate,UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UITextField *genderTextField;

@property (weak, nonatomic) IBOutlet UITextField *wanjuWeightLabel;
@property (weak, nonatomic) IBOutlet UITextField *wutuiWeightLabel;
@property (weak, nonatomic) IBOutlet UITextField *shendunWeightLabel;
@property (weak, nonatomic) IBOutlet UITextField *yinlaWeightLabel;

@property (weak, nonatomic) IBOutlet UISlider *wanjuSlider;
@property (weak, nonatomic) IBOutlet UISlider *wotuiSlider;
@property (weak, nonatomic) IBOutlet UISlider *shendunSlider;
@property (weak, nonatomic) IBOutlet UISlider *yinglaSlider;

@property (weak, nonatomic) IBOutlet UISegmentedControl *purposeSeg;
@property (weak, nonatomic) IBOutlet UISegmentedControl *staminaSeg;
@property (weak, nonatomic) IBOutlet UISegmentedControl *frequencySeg;

@property (strong, nonatomic) UIPickerView *agePicker;
@property (strong, nonatomic) UIPickerView *genderPicker;
@property (strong, nonatomic) NSArray *ageArray;
@property (strong, nonatomic) NSArray *genderArray;

@property (nonatomic) NSInteger purpose; ///<运动目的
@property (nonatomic) NSInteger stamina; ///<体能水准
@property (nonatomic) NSInteger frequency; ///<运动频率

@end

@implementation PersonalInfoTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initThePickers];
    [self initFrameData];
}

- (void)initThePickers {
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
}

- (void)initFrameData {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        [self.view endEditing:YES];
    }];
    if ([tapGesture respondsToSelector:@selector(locationInView:)]) {
        tapGesture.numberOfTapsRequired = 1; // The default value is 1.
        tapGesture.numberOfTouchesRequired = 1; // The default value is 1.
        [self.tableView addGestureRecognizer:tapGesture];
    }
    
    NSMutableDictionary *tempDic = _allUserData[_mainIndex];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:nil];
    saveButton.tintColor = MyGreenColor;
    [saveButton setActionBlock:^(id _Nonnull sender) {
        if (_nameTextField.text.length == 0) {
            [self alertForSampleWarning:@"姓名不可为空"];
        }else {
            [self saveAllUserData:tempDic];
            if (_mainIndex == 0) {
                [[ASBaseManage sharedManage] updateBugTagsInfo];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    //键盘初始化
    _nameTextField.returnKeyType = UIReturnKeyDone;
    _ageTextField.inputView = _agePicker;
    _genderTextField.inputView = _genderPicker;
    
    //UI显示数据初始化
    _nameTextField.text = tempDic[@"userName"];
    _ageTextField.text = tempDic[@"age"];
    _genderTextField.text = tempDic[@"gender"];
    _purpose = [tempDic[@"purpose"] integerValue];
    _stamina = [tempDic[@"stamina"] integerValue];
    _frequency = [tempDic[@"frequency"] integerValue];
    
    //设置UI的显示属性
    _wanjuWeightLabel.text = tempDic[@"wanju"];
    _wutuiWeightLabel.text = tempDic[@"wutui"];
    _shendunWeightLabel.text = tempDic[@"shendun"];
    _yinlaWeightLabel.text = tempDic[@"yinla"];
    
    _wanjuSlider.value = [tempDic[@"wanju"] floatValue];
    _wotuiSlider.value = [tempDic[@"wutui"] floatValue];
    _shendunSlider.value = [tempDic[@"shendun"] floatValue];
    _yinglaSlider.value = [tempDic[@"yinla"] floatValue];
    
    _purposeSeg.selectedSegmentIndex = _purpose;
    _staminaSeg.selectedSegmentIndex = _stamina;
    _frequencySeg.selectedSegmentIndex = _frequency;
}

- (void)saveAllUserData: (NSMutableDictionary *)tempDic{
    [tempDic setObject:_nameTextField.text forKey:@"userName"];
    [tempDic setObject:_ageTextField.text forKey:@"age"];
    [tempDic setObject:_genderTextField.text forKey:@"gender"];
    [tempDic setObject:[NSString stringWithFormat:@"%@",@(_purposeSeg.selectedSegmentIndex)] forKey:@"purpose"];
    [tempDic setObject:[NSString stringWithFormat:@"%@",@(_staminaSeg.selectedSegmentIndex)] forKey:@"stamina"];
    [tempDic setObject:[NSString stringWithFormat:@"%@",@(_frequencySeg.selectedSegmentIndex)] forKey:@"frequency"];
    [tempDic setObject:_wanjuWeightLabel.text forKey:@"wanju"];
    [tempDic setObject:_wutuiWeightLabel.text forKey:@"wutui"];
    [tempDic setObject:_shendunWeightLabel.text forKey:@"shendun"];
    [tempDic setObject:_yinlaWeightLabel.text forKey:@"yinla"];
    
    [_allUserData replaceObjectAtIndex:_mainIndex withObject:tempDic];
    [_allUserData writeToFile:_userDataPath atomically:YES];
    [[SettingStore sharedSetting] setUserName:_nameTextField.text];
}

- (IBAction)sliderChangeValue:(UISlider *)sender {
    
    int i = roundf(sender.value);
    
    if (sender == _wanjuSlider) {
        if (i % 5 == 0) {
            _wanjuWeightLabel.text = [NSString stringWithFormat:@"%i Kg", i];
        }
    }else if (sender == _wotuiSlider){
        if (i % 5 == 0) {
            _wutuiWeightLabel.text = [NSString stringWithFormat:@"%i Kg", i];
        }
    }else if (sender == _shendunSlider){
        if (i % 5 == 0) {
            _shendunWeightLabel.text = [NSString stringWithFormat:@"%i Kg", i];
        }
    }else if (sender == _yinglaSlider){
        if (i % 5 == 0) {
            _yinlaWeightLabel.text = [NSString stringWithFormat:@"%i Kg", i];
        }
    }
}

#pragma mark - TextField

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.tintColor = [UIColor clearColor];
    
    if (textField == _ageTextField) {
        if (_ageTextField.text.length == 0) {
            _ageTextField.text = [NSString stringWithFormat:@"%d", 20];
        }
        int i = [textField.text intValue];
        [self.agePicker selectRow:(5100/2 - 50 + i) inComponent:0 animated:NO];
    }else if (textField == _genderTextField) {
        if (_genderTextField.text.length == 0) {
            _genderTextField.text = @"男";
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
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

- (void)alertForSampleWarning: (NSString *)titleStr
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:titleStr
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
