//
//  NewEventVC.m
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/9.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//
#import <MobileCoreServices/MobileCoreServices.h>

#import "NewEventVC.h"
#import "CommonMarco.h"
#import "YYKit.h"
#import "NYSegmentedControl.h"
#import "AbstractActionSheetPicker.h"
#import "ActionSheetDatePicker.h"
#import "ActionSheetStringPicker.h"
#import "JVFloatLabeledTextField.h"
#import "NumberValuePicker.h"
#import "TYAlertController.h"
#import "SportPartManageTV.h"
#import "SportEventManage.h"

@interface NewEventVC ()<UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ASEventDelegate>
@property (weak, nonatomic) IBOutlet UIControl *rootView;
@property (weak, nonatomic) IBOutlet NYSegmentedControl *segmentedControl;
@property (strong, nonatomic) TYAlertController *alertController;

@property (weak, nonatomic) IBOutlet UIImageView *doneImageView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIImageView *actionImageView;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;

@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *actionDateField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *equipField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *sportNameField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *serialNumField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *partField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *muscleField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *timeLastField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *weightField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *repeatTimesField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *RMField;

@property (weak, nonatomic) IBOutlet UIView *actionSepView;
@property (weak, nonatomic) IBOutlet UIView *equipSepView;
@property (weak, nonatomic) IBOutlet UIView *sportNameView;
@property (weak, nonatomic) IBOutlet UIView *serialNumView;
@property (weak, nonatomic) IBOutlet UIView *partSepView;
@property (weak, nonatomic) IBOutlet UIView *muscleSepView;
@property (weak, nonatomic) IBOutlet UIView *timeLastSepView;
@property (weak, nonatomic) IBOutlet UIView *weightSepView;
@property (weak, nonatomic) IBOutlet UIView *repeatSepView;
@property (weak, nonatomic) IBOutlet UIView *RMSelView;

@property (nonatomic, strong) NSDate *selectedDateForMark;

@end

@implementation NewEventVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initTheNav];
    [self initFrameUI];
    [self updateStateType];
}

- (void)initTheNav {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:nil];
    cancelButton.tintColor = MyGreenColor;
    [cancelButton setActionBlock:^(id _Nonnull sender) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    if (_pageState == 0 || _pageState == 1) {
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:nil];
    [addButton setActionBlock:^(id _Nonnull sender) {
        if (_sportNameField.text.length == 0 || _partField.text.length == 0) {
            [self alertForNotChooseAnyEvent];
        }else {
            if (_pageState == 0 || _pageState == 1) {
                [self saveCurrentDataForRecord];
                [self dismissViewControllerAnimated:YES completion:nil];
            }else {
                [self saveCurrentDataForEvent];
                [self.navigationController popViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:RefreshSportEventsNotifcation object:nil];
            }
        }
    }];
    
    addButton.tintColor = MyGreenColor;
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.rightBarButtonItem.tintColor = MyGreenColor;
    self.navigationItem.leftBarButtonItem.tintColor = MyGreenColor;
}

- (void)saveCurrentDataForRecord {
    _recordStore.sportEquipment = _equipField.text;
    _recordStore.sportName = _sportNameField.text;
    _recordStore.sportSerialNum = _serialNumField.text;
    _recordStore.sportPart = _partField.text;
    _recordStore.muscles = _muscleField.text;
    _recordStore.timeLast = [_timeLastField.text intValue];
    _recordStore.weight = [_weightField.text intValue];
    _recordStore.repeatSets = [_repeatTimesField.text intValue];
    _recordStore.RM = [_RMField.text intValue];
    _recordStore.sportType = _segmentedControl.selectedSegmentIndex;
    if (_pageState == 0) {
        [_recordStore save];
    }else if (_pageState == 1) {
        [_recordStore update];
    }
}

- (void)saveCurrentDataForEvent {
    _eventStore.sportEquipment = _equipField.text;
    _eventStore.sportName = _sportNameField.text;
    _eventStore.sportSerialNum = _serialNumField.text;
    _eventStore.sportPart = _partField.text;
    _eventStore.muscles = _muscleField.text;
    _eventStore.sportType = _segmentedControl.selectedSegmentIndex;
    if (_pageState == 2) {
        if ([_eventStore save]) {
            //生成动作编号
            NSArray * partArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SportParts" ofType:@"plist"]];
            NSInteger initialIndex = 0;
            if ([partArray containsObject:_partField.text]) {
                initialIndex = [partArray indexOfObject:_partField.text];
            }
            NSString *serial = [NSString stringWithFormat:@"%@_%d", @(initialIndex), _eventStore.pk];
            _eventStore.sportSerialNum = serial;
            [_eventStore update];
        }
    }else if (_pageState == 3) {
        [_eventStore update];
    }
}

- (void)initFrameUI {
    _rootView.layer.borderColor = MyLightGray.CGColor;
    _rootView.layer.borderWidth = 0.9;
    _rootView.layer.cornerRadius = 8;
    [_rootView addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        [self.view endEditing:YES];
    }];
    
    [self.segmentedControl insertSegmentWithTitle:@"有氧" atIndex:0];
    [self.segmentedControl insertSegmentWithTitle:@"抗阻" atIndex:1];
    [self.segmentedControl insertSegmentWithTitle:@"拉伸" atIndex:2];
    
    self.segmentedControl.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    self.segmentedControl.segmentIndicatorBackgroundColor = MyWhite;
    self.segmentedControl.segmentIndicatorInset = 0.0f;
    self.segmentedControl.titleTextColor = MyLightGray;
    self.segmentedControl.selectedTitleTextColor = MyDarkGray;
    self.segmentedControl.usesSpringAnimations = YES;
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.cornerRadius = CGRectGetHeight(self.segmentedControl.frame) / 2.0f;
    
    [_rootView addSubview:self.segmentedControl];
}

- (void)updateStateType {
    _serialNumField.enabled = NO;
    NSString *titleStr = @"";
    if (_pageState == 0) {
        //添加
        [self updateDoneImageAndDateLabel];
        
        titleStr = @"添加项目";
        _equipField.enabled = NO;
        _partField.enabled = NO;
        _muscleField.enabled = NO;
        _segmentedControl.enabled = NO;
        _imageButton.enabled = NO;
        
        _actionSepView.backgroundColor = MYBlueColor;
        _sportNameView.backgroundColor = MYBlueColor;
        _timeLastSepView.backgroundColor = MYBlueColor;
        _weightSepView.backgroundColor = MYBlueColor;
        _repeatSepView.backgroundColor = MYBlueColor;
        _RMSelView.backgroundColor = MYBlueColor;
    }else if (_pageState == 1) {
        //编辑
        [self updateDoneImageAndDateLabel];
        
        titleStr = @"编辑项目";
        _equipField.enabled = NO;
        _partField.enabled = NO;
        _muscleField.enabled = NO;
        _segmentedControl.enabled = NO;
        _imageButton.enabled = NO;
        
        _actionSepView.backgroundColor = MYBlueColor;
        _sportNameView.backgroundColor = MYBlueColor;
        _timeLastSepView.backgroundColor = MYBlueColor;
        _weightSepView.backgroundColor = MYBlueColor;
        _repeatSepView.backgroundColor = MYBlueColor;
        _RMSelView.backgroundColor = MYBlueColor;
    }else if (_pageState == 2) {
        //新建
        [self updateEventDataAndUI];
        
        titleStr = @"新建项目";
        _actionDateField.enabled = NO;
        _doneButton.hidden = YES;
        _doneImageView.hidden = YES;
        _timeLastField.enabled = NO;
        _weightField.enabled = NO;
        _repeatTimesField.enabled = NO;
        _RMField.enabled = NO;
        
        _equipSepView.backgroundColor = MYBlueColor;
        _sportNameView.backgroundColor = MYBlueColor;
        _partSepView.backgroundColor = MYBlueColor;
        _muscleSepView.backgroundColor = MYBlueColor;
        _segmentedControl.borderColor = MYBlueColor;
    }else if (_pageState == 3) {
        [self updateEventDataAndUI];
        
        titleStr = @"修改项目";
        _actionDateField.enabled = NO;
        _doneButton.hidden = YES;
        _doneImageView.hidden = YES;
        _timeLastField.enabled = NO;
        _weightField.enabled = NO;
        _repeatTimesField.enabled = NO;
        _RMField.enabled = NO;
        //如果是系统自带的，那么不允许修改名字和器械
        
        _equipSepView.backgroundColor = MYBlueColor;
        _sportNameView.backgroundColor = MYBlueColor;
        _partSepView.backgroundColor = MYBlueColor;
        _muscleSepView.backgroundColor = MYBlueColor;
        _segmentedControl.borderColor = MYBlueColor;
    }
    self.navigationItem.title = titleStr;
}

//添加和编辑
- (void)updateDoneImageAndDateLabel {
    if (_recordStore) {
        _selectedDateForMark = [NSDate dateWithTimeIntervalSince1970:_recordStore.eventTimeStamp];
        _actionDateField.text = [[ASBaseManage dateFormatterForDMYE] stringFromDate:_selectedDateForMark];
        _sportNameField.text = _recordStore.sportName;
        _equipField.text = _recordStore.sportEquipment;
        _sportNameField.text = _recordStore.sportName;
        _serialNumField.text = _recordStore.sportSerialNum;
        _partField.text = _recordStore.sportPart;
        _muscleField.text = _recordStore.muscles;
        
        if (_pageState == 1) {
            _timeLastField.text = [NSString stringWithFormat:@"%d 分钟", _recordStore.timeLast];
            NSString *unitText = @"";
            SettingStore *setting = [SettingStore sharedSetting];
            if (setting.weightUnit == 0) {
                unitText = @"Kg";
            }else if (setting.weightUnit == 1) {
                unitText = Local(@"lb");
            }
            _weightField.text = [NSString stringWithFormat:@"%d %@", _recordStore.weight, unitText];
            _repeatTimesField.text = [NSString stringWithFormat:@"%d 组", _recordStore.repeatSets];
            _RMField.text = [NSString stringWithFormat:@"%d 次/组", _recordStore.RM];
            [_segmentedControl setSelectedSegmentIndex:_recordStore.sportType animated:YES];
        }
        
        _doneImageView.image = [UIImage imageNamed:@"DonePicHorizontal-Right"];
        _doneImageView.image = [_doneImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        if (_recordStore.isDone) {
            _doneImageView.tintColor = [UIColor redColor];
            _rootView.layer.borderColor = MYBlueColor.CGColor;
        }else {
            _doneImageView.tintColor = MyLightGray;
            _rootView.layer.borderColor = MyLightGray.CGColor;
        }
        
        if (_recordStore.isSystemMade) {
            NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"SportImages.bundle"];
            NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
            UIImage *(^getBundleImage)(NSString *) = ^(NSString *n) {
                return [UIImage imageWithContentsOfFile:[bundle pathForResource:n ofType:@"jpg"]];
            };
            
            UIImage *myImg = getBundleImage(_recordStore.imageKey);
            _actionImageView.image = myImg;
        }
    }
}

//新建和修改
- (void)updateEventDataAndUI {
    if (_eventStore) {
        _sportNameField.text = _eventStore.sportName;
        _equipField.text = _eventStore.sportEquipment;
        _sportNameField.text = _eventStore.sportName;
        _serialNumField.text = _eventStore.sportSerialNum;
        _partField.text = _eventStore.sportPart;
        _muscleField.text = _eventStore.muscles;
        
        if (_eventStore.isSystemMade) {
            NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"SportImages.bundle"];
            NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
            UIImage *(^getBundleImage)(NSString *) = ^(NSString *n) {
                return [UIImage imageWithContentsOfFile:[bundle pathForResource:n ofType:@"jpg"]];
            };
            UIImage *myImg = getBundleImage(_eventStore.imageKey);
            _actionImageView.image = myImg;
        }
        
        [_segmentedControl setSelectedSegmentIndex:_eventStore.sportType animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Method

- (IBAction)buttonClickedMethod:(UIButton *)sender {
    if (sender == _doneButton) {
        //完成项目
        _recordStore.isDone = !_recordStore.isDone;
        [self updateDoneImageAndDateLabel];
        
    }else if (sender == _imageButton) {
        //更改图片
        [self alertForChooseCreate];
    }
}

- (IBAction)infoButtonClicked:(UIBarButtonItem *)sender {
    
}

- (void)clickToChangeDate:(UITextField *)sender {
    [self.view endEditing:YES];
    AbstractActionSheetPicker *newDatePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"选择运动日期" datePickerMode:UIDatePickerModeDate selectedDate:_selectedDateForMark doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        NSString *newStr = [[ASBaseManage dateFormatterForDMYE] stringFromDate:selectedDate];
        NSString *compareStr = [[ASBaseManage dateFormatterForDMYE] stringFromDate:[NSDate date]];
        if (_recordStore) {
            _recordStore.eventTimeStamp = [selectedDate timeIntervalSince1970];
        }
        
        if ([newStr isEqualToString:compareStr]) {
            self.actionDateField.text = Local(@"Today");
        } else{
            self.actionDateField.text = newStr;
        }
    } cancelBlock:^(ActionSheetDatePicker *picker) {
        
    } origin:self.view];
    [newDatePicker addCustomButtonWithTitle:Local(@"Today") value:[NSDate date]];
    newDatePicker.tapDismissAction = TapActionSuccess;
    newDatePicker.hideCancel = YES;
    
    [newDatePicker showActionSheetPicker];
}

- (void)clickToChangeSportAttribute:(UITextField *)sender {
    [self.view endEditing:YES];
    ActionSheetStringPicker *newPicker;
    if (sender == _equipField) {
        newPicker = [[ActionSheetStringPicker alloc] initWithTitle:@"挑选运动器械" rows:@[@"无",@"弹力绳"] initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            _equipField.text = (NSString *)selectedValue;
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            _equipField.text = @"";
        } origin:self.view];
    }else if (sender == _partField) {
        NSArray * partArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SportParts" ofType:@"plist"]];
        NSInteger initialIndex = 0;
        if ([partArray containsObject:_partField.text]) {
            initialIndex = [partArray indexOfObject:_partField.text];
        }
        newPicker = [[ActionSheetStringPicker alloc] initWithTitle:@"挑选运动部位" rows:partArray initialSelection:initialIndex doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            _partField.text = (NSString *)selectedValue;
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            _partField.text = @"";
        } origin:self.view];
    }
    
    newPicker.tapDismissAction = TapActionSuccess;
    [newPicker showActionSheetPicker];
}

#pragma mark - 图片编辑

- (void)alertForNotChooseAnyEvent {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"运动项目和部位是必填的"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertForChooseCreate
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"选择对图片的操作"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"拍照"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
        //拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                //先启动后置相机
                controller.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:nil];
        }
                                                
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"从相册中选取"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
        //从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:nil];
        }
                                                
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"删除图片"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * action) {
        //删除
                                                
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == _actionDateField) {
        [self clickToChangeDate:_actionDateField];
        return NO;
    }else if (textField == _equipField || textField == _partField) {
        [self clickToChangeSportAttribute:textField];
        return NO;
    }else if (textField == _timeLastField ||
              textField == _weightField ||
              textField == _repeatTimesField ||
              textField == _RMField) {
        NumberValuePicker *numPicker = [NumberValuePicker viewFromNib];
        if (textField == _timeLastField) {
            //时间的Picker
            int initNum = 10;
            if (_timeLastField.text.length > 0) {
                initNum = [_timeLastField.text intValue];
            }else {
                _timeLastField.text = [NSString stringWithFormat:@"%d 分钟", initNum];
            }
            [numPicker configUITitle:textField.placeholder unit:Local(@"Min") min:0 max:90 step:1 initNum:initNum];
            numPicker.valueChangeBlock = ^(int value) {
                _timeLastField.text = [NSString stringWithFormat:@"%d 分钟", value];
            };
            numPicker.clearBlock = ^{
                _timeLastField.text = @"";
                [self dismissValuePicker];
            };
        }
        else if (textField == _weightField) {
            //负重
            int initNum = 30;
            NSString *unitText = @"";
            SettingStore *setting = [SettingStore sharedSetting];
            if (setting.weightUnit == 0) {
                unitText = @"Kg";
            }else if (setting.weightUnit == 1) {
                unitText = Local(@"lb");
            }
            
            if (_weightField.text.length > 0) {
                initNum = [_weightField.text intValue];
            }else {
                _weightField.text = [NSString stringWithFormat:@"%d %@", initNum, unitText];
            }
            [numPicker configUITitle:textField.placeholder unit:unitText min:0 max:200 step:1 initNum:initNum];
            numPicker.valueChangeBlock = ^(int value) {
                _weightField.text = [NSString stringWithFormat:@"%d %@", value, unitText];
            };
            numPicker.clearBlock = ^{
                _weightField.text = @"";
                [self dismissValuePicker];
            };
            numPicker.selfWeghtBlock = ^{
                _weightField.text = @"自身重量";
                [self dismissValuePicker];
            };
        }
        else if (textField == _repeatTimesField) {
            //时间的Picker
            int initNum = 4;
            if (_repeatTimesField.text.length > 0) {
                initNum = [_repeatTimesField.text intValue];
            }else {
                _repeatTimesField.text = [NSString stringWithFormat:@"%d 组", initNum];
            }
            [numPicker configUITitle:textField.placeholder unit:@"组" min:0 max:20 step:1 initNum:initNum];
            numPicker.valueChangeBlock = ^(int value) {
                _repeatTimesField.text = [NSString stringWithFormat:@"%d 组", value];
            };
            numPicker.clearBlock = ^{
                _repeatTimesField.text = @"";
                [self dismissValuePicker];
            };
        }
        else if (textField == _RMField) {
            //时间的Picker
            int initNum = 12;
            if (_RMField.text.length > 0) {
                initNum = [_RMField.text intValue];
            }else {
                _RMField.text = [NSString stringWithFormat:@"%d 次/组", initNum];
            }
            [numPicker configUITitle:textField.placeholder unit:@"次/组" min:0 max:90 step:1 initNum:initNum];
            numPicker.valueChangeBlock = ^(int value) {
                _RMField.text = [NSString stringWithFormat:@"%d 次/组", value];
            };
            numPicker.clearBlock = ^{
                _RMField.text = @"";
                [self dismissValuePicker];
            };
        }
        
        _alertController = [TYAlertController alertControllerWithAlertView:numPicker preferredStyle:TYAlertControllerStyleActionSheet];
        _alertController.backgoundTapDismissEnable = YES;
        [self presentViewController:_alertController animated:YES completion:nil];
        
        return NO;
    }
    else if (textField == _sportNameField) {
        //运动名称
        if (_pageState == 0 || _pageState == 1) {
            SportPartManageTV *partTV = [[SportPartManageTV alloc] initWithStyle:UITableViewStylePlain];
            partTV.canEditEvents = NO;
            partTV.chooseSportBlock = ^(SportEventStore *eventStore) {
                _recordStore.isSystemMade = eventStore.isSystemMade;
                _recordStore.imageKey = eventStore.imageKey;
                
                _sportNameField.text = eventStore.sportName;
                _equipField.text = eventStore.sportEquipment;
                _serialNumField.text = eventStore.sportSerialNum;
                _partField.text = eventStore.sportPart;
                _muscleField.text = eventStore.muscles;
                [_segmentedControl setSelectedSegmentIndex:eventStore.sportType animated:YES];
                if (eventStore.isSystemMade) {
                    NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"SportImages.bundle"];
                    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
                    UIImage *(^getBundleImage)(NSString *) = ^(NSString *n) {
                        return [UIImage imageWithContentsOfFile:[bundle pathForResource:n ofType:@"jpg"]];
                    };
                    
                    UIImage *myImg = getBundleImage(eventStore.imageKey);
                    _actionImageView.image = myImg;
                }
            };
            [self.navigationController pushViewController:partTV animated:YES];
            return NO;
        }
        else {
            return YES;
        }
        
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (void)dismissValuePicker {
    [_alertController dismissViewControllerAnimated:YES];
}

#pragma mark - Camera Utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

@end
