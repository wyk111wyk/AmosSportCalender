//
//  PersonalInfoTableView.m
//  AmosSportDiary
//
//  Created by Amos Wu on 15/8/26.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "PersonalInfoTableView.h"
#import "PersonInfoStore.h"

@interface PersonalInfoTableView ()

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

@end

@implementation PersonalInfoTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PersonInfoStore *personal = [PersonInfoStore sharedSetting];
    
    //设置UI的显示属性
    _wanjuWeightLabel.text = [NSString stringWithFormat:@"%.0f Kg", personal.wanjuWeight];
    _wutuiWeightLabel.text = [NSString stringWithFormat:@"%.0f Kg", personal.woutuiWeight];
    _shendunWeightLabel.text = [NSString stringWithFormat:@"%.0f Kg", personal.shengdunWeight];
    _yinlaWeightLabel.text = [NSString stringWithFormat:@"%.0f Kg", personal.yinglaWeight];
    
    _wanjuSlider.value = personal.wanjuWeight;
    _wotuiSlider.value = personal.woutuiWeight;
    _shendunSlider.value = personal.shengdunWeight;
    _yinglaSlider.value = personal.yinglaWeight;
    
    _purposeSeg.selectedSegmentIndex = (int)personal.purpose;
    _staminaSeg.selectedSegmentIndex = (int)personal.stamina;
    _frequencySeg.selectedSegmentIndex = (int)personal.frequency;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    PersonInfoStore *personal = [PersonInfoStore sharedSetting];
    personal.wanjuWeight = [_wanjuWeightLabel.text floatValue];
    personal.woutuiWeight = [_wutuiWeightLabel.text floatValue];
    personal.shengdunWeight = [_shendunWeightLabel.text floatValue];
    personal.yinglaWeight = [_yinlaWeightLabel.text floatValue];
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

- (IBAction)segmentValueChange:(UISegmentedControl *)sender {
    
    PersonInfoStore *personal = [PersonInfoStore sharedSetting];
    
    if (sender == _purposeSeg) {
        if (_purposeSeg.selectedSegmentIndex == 0) {
            personal.purpose = 0;
        }else if(_purposeSeg.selectedSegmentIndex == 1) {
            personal.purpose = 1;
        }else if (_purposeSeg.selectedSegmentIndex == 2) {
            personal.purpose = 2;
        }else if (_purposeSeg.selectedSegmentIndex == 3) {
            personal.purpose = 3;
        }
    }else if (sender == _staminaSeg) {
        if (_staminaSeg.selectedSegmentIndex == 0) {
            personal.stamina = 0;
        }else if(_staminaSeg.selectedSegmentIndex == 1) {
            personal.stamina = 1;
        }else if (_staminaSeg.selectedSegmentIndex == 2) {
            personal.stamina = 2;
        }
    }else if (sender == _frequencySeg) {
        if (_frequencySeg.selectedSegmentIndex == 0) {
            personal.frequency = 0;
        }else if(_frequencySeg.selectedSegmentIndex == 1) {
            personal.frequency = 1;
        }else if (_frequencySeg.selectedSegmentIndex == 2) {
            personal.frequency = 2;
        }
    }
}

@end
