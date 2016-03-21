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
#import "NYSegmentedControl.h"
#import "AbstractActionSheetPicker.h"
#import "ActionSheetDatePicker.h"
#import "ActionSheetStringPicker.h"
#import "JVFloatLabeledTextField.h"
#import "NumberValuePicker.h"
#import "TYAlertController.h"
#import "SportPartManageTV.h"
#import "SportEventManage.h"
#import "TOCropViewController.h"

@interface NewEventVC ()<UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ASEventDelegate, TOCropViewControllerDelegate>
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
@property (weak, nonatomic) IBOutlet UIImageView *editableMarkImageView;

@property (nonatomic, strong) NSDate *selectedDateForMark;
@property (nonatomic) BOOL initDone; ///<刚开始是不是完成
@property (nonatomic, strong) NSString *unitText;

@end

@implementation NewEventVC

- (void)viewDidLoad {
    [super viewDidLoad];

    _initDone = _recordStore.isDone;
    SettingStore *setting = [SettingStore sharedSetting];
    if (setting.weightUnit == 0) {
        _unitText = @"Kg";
    }else if (setting.weightUnit == 1) {
        _unitText = Local(@"lb");
    }
    
    [self initTheNav];
    [self initFrameUI];
    [self updateStateType];
}

- (void)initTheNav {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:Local(@"Cancel") style:UIBarButtonItemStylePlain target:self action:nil];
    cancelButton.tintColor = MyGreenColor;
    [cancelButton setActionBlock:^(id _Nonnull sender) {
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }];
    if (_pageState == 0 || _pageState == 1 || _pageState == 4) {
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:Local(@"Save") style:UIBarButtonItemStyleDone target:self action:nil];
    [addButton setActionBlock:^(id _Nonnull sender) {
        if (_sportNameField.text.length == 0 || _partField.text.length == 0) {
            [self alertForNotChooseAnyEvent];
        }else {
            if (_pageState == 0 || _pageState == 1) {
                [self saveCurrentDataForRecord];
                [[ASDataManage sharedManage] refreshSportEventsForDate:_selectedDateForMark];
                [self dismissViewControllerAnimated:YES completion:^{
                    [[UIApplication sharedApplication] cancelAllLocalNotifications];
                }];
            }else if(_pageState == 2 || _pageState == 3) {
                [self saveCurrentDataForEvent];
                [self.navigationController popViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:RefreshSportEventsNotifcation object:nil];
            }else if (_pageState == 4) {
                [self saveCurrentDataForRecord];
                [self dismissViewControllerAnimated:YES completion:nil];
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
    _recordStore.repeatSets = [_repeatTimesField.text intValue];
    _recordStore.RM = [_RMField.text intValue];
    _recordStore.sportType = _segmentedControl.selectedSegmentIndex;
    BOOL isNew = ![@(self.pageState) boolValue];
    _recordStore.datePart = [[ASDataManage sharedManage] getTheSportPartForRecord:_recordStore isNew:isNew];
    if (_recordStore.isDone && _recordStore.isDone !=_initDone) {
        [[ASDataManage sharedManage] addNewDateEventRecord:_recordStore];
    }
    
    if (_pageState == 0) {
        [_recordStore save];
    }else if (_pageState == 1) {
        [_recordStore update];
    }else if (_pageState == 4) {
        _recordStore.isGroupSet = YES;
        _recordStore.groupSetPK = _groupSetPK;
        [_recordStore saveOrUpdate];
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
    
    [self.segmentedControl insertSegmentWithTitle:Local(@"Aerobic") atIndex:0];
    [self.segmentedControl insertSegmentWithTitle:Local(@"Resistance") atIndex:1];
    [self.segmentedControl insertSegmentWithTitle:Local(@"Stretch") atIndex:2];
    
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
    if (_pageState == 0 || _pageState == 1 || _pageState == 4) {
        //添加
        [self updateDoneImageAndDateLabel];
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
        
        if (_pageState == 0) {
            titleStr = Local(@"Add Sport");
        }else if (_pageState == 1) {
            titleStr = Local(@"Edit Sport");
        }else if (_pageState == 4) {
            titleStr = Local(@"Set Sport");
            _actionDateField.enabled = NO;
            _actionSepView.backgroundColor = MyLightGray;
            _doneButton.enabled = NO;
            _actionDateField.text = @"-";
        }
    }else if (_pageState == 2 || _pageState == 3) {
        //新建
        [self updateEventDataAndUI];
        if (_pageState == 2) {
            titleStr = Local(@"New Sport");
        }else if (_pageState == 3) {
            titleStr = Local(@"Modify Sport");
        }
        
        _editableMarkImageView.hidden = NO;
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
    }
    self.navigationItem.title = titleStr;
    //判断是否是有氧
    [self updateNotWeightSport];
}

//添加和编辑
- (void)updateDoneImageAndDateLabel {
    if (_recordStore) {
        _selectedDateForMark = [NSDate dateWithTimeIntervalSince1970:_recordStore.eventTimeStamp];
        NSString *newStr = [[ASBaseManage dateFormatterForDMYE] stringFromDate:_selectedDateForMark];
        NSString *compareStr = [[ASBaseManage dateFormatterForDMYE] stringFromDate:[NSDate date]];
        
        if ([newStr isEqualToString:compareStr]) {
            self.actionDateField.text = Local(@"Today");
        } else{
            NSString *gapDays = [[ASBaseManage sharedManage] getDaysWith:_selectedDateForMark];
            self.actionDateField.text = [NSString stringWithFormat:@"%@ %@", newStr, gapDays];
        }
        
        _sportNameField.text = _recordStore.sportName;
        _equipField.text = _recordStore.sportEquipment;
        _sportNameField.text = _recordStore.sportName;
        _serialNumField.text = _recordStore.sportSerialNum;
        _partField.text = _recordStore.sportPart;
        _muscleField.text = _recordStore.muscles;
        
        if (_pageState == 1 || _pageState == 4) {
            if (_recordStore.timeLast > 0) {
                _timeLastField.text = [NSString stringWithFormat:Local(@"%d min"), _recordStore.timeLast];
            }
            
            if (_recordStore.weight == 999) {
                _weightField.text = Local(@"Self-weight");
            }else {
                _weightField.text = [NSString stringWithFormat:@"%d %@", _recordStore.weight, _unitText];
            }
            _repeatTimesField.text = [NSString stringWithFormat:Local(@"%d sets"), _recordStore.repeatSets];
            _RMField.text = [NSString stringWithFormat:Local(@"%d reps"), _recordStore.RM];
            [_segmentedControl setSelectedSegmentIndex:_recordStore.sportType animated:YES];
        }
        
        [self updateDoneState];
        //图片
        [self updateTheSportImage:_recordStore.imageKey isSystem:_recordStore.isSystemMade];
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
        
        [_segmentedControl setSelectedSegmentIndex:_eventStore.sportType animated:YES];
        [self updateTheSportImage: _eventStore.imageKey isSystem:_eventStore.isSystemMade];
    }
}

- (void)updateNotWeightSport {
    if (_recordStore.sportType == 0 || _recordStore.sportType == 2) {
        _weightField.enabled = NO;
        _repeatTimesField.enabled = NO;
        _RMField.enabled = NO;
        _weightSepView.backgroundColor = MyLightGray;
        _repeatSepView.backgroundColor = MyLightGray;
        _RMSelView.backgroundColor = MyLightGray;
        
        _weightField.text = @"";
        _repeatTimesField.text = @"";
        _RMField.text = @"";
    }else {
        _weightField.enabled = YES;
        _repeatTimesField.enabled = YES;
        _RMField.enabled = YES;
        _weightSepView.backgroundColor = MYBlueColor;
        _repeatSepView.backgroundColor = MYBlueColor;
        _RMSelView.backgroundColor = MYBlueColor;
    }
}

- (void)updateTheSportImage: (NSString *)ImageKey isSystem:(BOOL) isSystem {
    if (isSystem) {
        NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"SportImages.bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        UIImage *(^getBundleImage)(NSString *) = ^(NSString *n) {
            return [UIImage imageWithContentsOfFile:[bundle pathForResource:n ofType:@"jpg"]];
        };
        UIImage *myImg = getBundleImage(ImageKey);
        if (myImg) {
            _actionImageView.image = myImg;
        }else {
            self.actionImageView.image = [UIImage imageNamed:@"funPic4"];
        }
    }else {
        NSString *imageKey = _eventStore?_eventStore.imageKey:_recordStore.imageKey;
        NSString *imageCacheCode = [NSString stringWithFormat:@"photo_%@", imageKey];
        UIImage *photoImage = [[TMCache sharedCache] objectForKey:ATCacheKey(imageCacheCode)];
        if (photoImage == nil) {
            SportImageStore *imageStore = [SportImageStore findFirstWithFormat:@" WHERE imageKey = '%@' ", imageKey];
            if (imageStore) {
                NSString *avatarStr = imageStore.sportPhoto;
                NSData *imageData = [[NSData alloc] initWithBase64EncodedString:avatarStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
                photoImage = [UIImage imageWithData:imageData];
                [[TMCache sharedCache] setObject:photoImage forKey:ATCacheKey(imageCacheCode)];
            }else {
                self.actionImageView.image = [UIImage imageNamed:@"funPic4"];
            }
        }else {
            self.actionImageView.image = photoImage;
        }
    }
}

- (void)updateDoneState {
    //完成
    _doneImageView.image = [UIImage imageNamed:@"DonePicHorizontal-Right"];
    _doneImageView.image = [_doneImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if (_recordStore.isDone) {
        _doneImageView.tintColor = [UIColor redColor];
        _rootView.layer.borderColor = MYBlueColor.CGColor;
        _rootView.layer.borderWidth = 1.5;
    }else {
        _doneImageView.tintColor = MyLightGray;
        _rootView.layer.borderColor = MyLightGray.CGColor;
        _rootView.layer.borderWidth = 0.7;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                _timeLastField.text = [NSString stringWithFormat:Local(@"%d min"), initNum];
            }
            [numPicker configUITitle:textField.placeholder unit:Local(@"Min") min:0 max:90 step:1 initNum:initNum];
            numPicker.valueChangeBlock = ^(int value) {
                _timeLastField.text = [NSString stringWithFormat:Local(@"%d min"), value];
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
                _recordStore.weight = value;
            };
            numPicker.clearBlock = ^{
                _weightField.text = @"";
                _recordStore.weight = 0;
                [self dismissValuePicker];
            };
            numPicker.selfWeghtBlock = ^{
                _weightField.text = Local(@"Self-weight");
                _recordStore.weight = 999;
                [self dismissValuePicker];
            };
        }
        else if (textField == _repeatTimesField) {
            //时间的Picker
            int initNum = 4;
            if (_repeatTimesField.text.length > 0) {
                initNum = [_repeatTimesField.text intValue];
            }else {
                _repeatTimesField.text = [NSString stringWithFormat:Local(@"%d sets"), initNum];
            }
            [numPicker configUITitle:textField.placeholder unit:Local(@"sets") min:0 max:20 step:1 initNum:initNum];
            numPicker.valueChangeBlock = ^(int value) {
                _repeatTimesField.text = [NSString stringWithFormat:Local(@"%d sets"), value];
                [self updateTheTimeLast:0 repeats:value];
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
                _RMField.text = [NSString stringWithFormat:Local(@"%d reps"), initNum];
            }
            [numPicker configUITitle:textField.placeholder unit:Local(@"reps") min:0 max:90 step:1 initNum:initNum];
            numPicker.valueChangeBlock = ^(int value) {
                _RMField.text = [NSString stringWithFormat:Local(@"%d reps"), value];
                [self updateTheTimeLast:value repeats:0];
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
        if (_pageState == 0 || _pageState == 1  || _pageState == 4) {
            SportPartManageTV *partTV = [[SportPartManageTV alloc] initWithStyle:UITableViewStylePlain];
            partTV.canEditEvents = NO;
            partTV.pageState = 2;
            partTV.chooseSportBlock = ^(SportEventStore *eventStore) {
                _recordStore.isSystemMade = eventStore.isSystemMade;
                _recordStore.imageKey = eventStore.imageKey;
                _recordStore.sportType = eventStore.sportType;
                _recordStore.sportTips = eventStore.sportTips;
                
                _sportNameField.text = eventStore.sportName;
                _equipField.text = eventStore.sportEquipment;
                _serialNumField.text = eventStore.sportSerialNum;
                _partField.text = eventStore.sportPart;
                _muscleField.text = eventStore.muscles;
                [_segmentedControl setSelectedSegmentIndex:eventStore.sportType animated:YES];
                //图片
                [self updateTheSportImage:eventStore.imageKey isSystem:eventStore.isSystemMade];
                //智能推荐
                if (eventStore.sportType == 1) {
                    [self setupAdviceNum: eventStore.sportPart];
                }
                //根据运动类型设置不可编辑部分
                [self updateNotWeightSport];
                
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

//生成智能推荐的数目
- (void)setupAdviceNum:(NSString *)sportPart {
    //根据个人设置生成组数等
    NSString *userDataPath = [[ASDataManage sharedManage] getFilePathInLibWithFolder:UserFolderName fileName:UserFileName];
    NSArray *allUserData = [[NSArray alloc] initWithContentsOfFile:userDataPath];
    NSDictionary *tempDic = [NSDictionary dictionary];
    for (NSDictionary *tempNewDic in allUserData){
        NSString *currentUser = [[SettingStore sharedSetting] userDataName];
        NSString *compareUser = tempDic[@"dataName"];
        if ([currentUser isEqualToString:compareUser]) {
            tempDic = tempNewDic;
            break;
        }
    }
    int weight = [[ASDataManage sharedManage] weightValueWithPart:sportPart data:tempDic];
    int times = [[ASDataManage sharedManage] rapsValuedata:tempDic];
    int repests = [[ASDataManage sharedManage] timesValuedata:tempDic];
    
    _weightField.text = [NSString stringWithFormat:@"%d %@", weight, _unitText];
    _repeatTimesField.text = [NSString stringWithFormat:Local(@"%d sets"), times];
    _RMField.text = [NSString stringWithFormat:Local(@"%d reps"), repests];
    
    [self updateTheTimeLast:times repeats:repests];
}

- (void)updateTheTimeLast: (int)times repeats:(int)repeats {
    if (times == 0) {
        times = [_RMField.text intValue];
    }
    if (repeats == 0) {
        repeats = [_repeatTimesField.text intValue];
    }
    
    if (times > 0 && repeats > 0) {
        int mins = times * repeats * 10 / 60;
        _timeLastField.text = [NSString stringWithFormat:Local(@"%d min"), mins];
    }
}

- (void)dismissValuePicker {
    [_alertController dismissViewControllerAnimated:YES];
}

#pragma mark - Button Method

- (IBAction)buttonClickedMethod:(UIButton *)sender {
    if (sender == _doneButton) {
        //完成项目
        _recordStore.isDone = !_recordStore.isDone;
        [self updateDoneState];
        
    }else if (sender == _imageButton) {
        //更改图片
        [self alertForChooseCreate];
    }
}

- (IBAction)infoButtonClicked:(UIBarButtonItem *)sender {
    NSString *messStr = _eventStore?_eventStore.sportTips:_recordStore.sportTips;
    if (messStr.length == 0) {
        messStr = Local(@"\n1.Lose fat\n Do some medium weight compound action training on bigger muscle group first, such as deep squat, squat jump. Do HIIT after anaerobic exercise, both the strength and the time are relatively long。\n\n2.Compact line\n May use circle strength training, multiple sets (more than 20 sets), multiple times (more than 20 times per set) and medium weight (50% of biggest negative heavy). Together with HIIT, greater strength, medium time. \n\n3.Increase certain muscle\n Heavier weight, less sets, slow down while put down, which means mind the centrifugal contraction.");
    }
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:Local(@"Tips")
                                                                   message:messStr
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Okay")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)clickToChangeDate:(UITextField *)sender {
    [self.view endEditing:YES];
    AbstractActionSheetPicker *newDatePicker = [[ActionSheetDatePicker alloc] initWithTitle: Local (@"Choose date to exercise")datePickerMode:UIDatePickerModeDate selectedDate:_selectedDateForMark doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        _selectedDateForMark = selectedDate;
        NSString *newStr = [[ASBaseManage dateFormatterForDMYE] stringFromDate:selectedDate];
        NSString *compareStr = [[ASBaseManage dateFormatterForDMYE] stringFromDate:[NSDate date]];
        if (_recordStore) {
            _recordStore.eventTimeStamp = [selectedDate timeIntervalSince1970];
            _recordStore.dateKey = [[ASBaseManage dateFormatterForDMY] stringFromDate:selectedDate];
        }
        
        if ([newStr isEqualToString:compareStr]) {
            self.actionDateField.text = Local(@"Today");
        } else{
            NSString *gapDays = [[ASBaseManage sharedManage] getDaysWith:selectedDate];
            self.actionDateField.text = [NSString stringWithFormat:@"%@ %@", newStr, gapDays];
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
        NSArray *equipmentArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"EquipmentList" ofType:@"plist"]];
        NSInteger initialIndex = 0;
        if ([equipmentArr containsObject:_equipField.text]) {
            initialIndex = [equipmentArr indexOfObject:_equipField.text];
        }
        newPicker = [[ActionSheetStringPicker alloc] initWithTitle:Local(@"Choose the equipment") rows:equipmentArr initialSelection:initialIndex doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
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
        newPicker = [[ActionSheetStringPicker alloc] initWithTitle:Local(@"Choose sport part") rows:partArray initialSelection:initialIndex doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
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
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:Local(@"Sport part and name are necessary")
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Okay")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertForChooseCreate
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:Local(@"Choose Image operation")
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Take photo")
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
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Choose from library")
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
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Delete the photo")
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * action) {
        //删除
                                                if (_eventStore.isSystemMade) {
                                                    [self alertForCanNotDeleteImage];
                                                }else {
                                                    _actionImageView.image = [UIImage imageNamed:@"funPic4"];
                                                    [SportImageStore deleteObjectsWithFormat:@" WHERE sportEventPK = '%d' ", _eventStore.pk];
                                                    NSString *imageCacheCode = [NSString stringWithFormat:@"photo_%@", _eventStore.imageKey];
                                                    [[TMCache sharedCache] removeObjectForKey:ATCacheKey(imageCacheCode)];
                                                }
                                                
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - 拍完照后的回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    //先将拍摄的图片缩小，按比例，最长的边为500
    portraitImg = [[ASBaseManage sharedManage] scaleToSize:portraitImg size:portraitImg.size sizeLine:500];
    //将缩小后的图片再进行压缩
    NSData *dataImg3 = UIImageJPEGRepresentation(portraitImg, 0.7);
    //最后将压缩的文件保存为图片，大概300kb ~ 400kb
    UIImage *newImage = [UIImage imageWithData:dataImg3];
    
    [picker dismissViewControllerAnimated:YES completion:^() {
        TOCropViewController *cropController = [[TOCropViewController alloc] initWithImage:newImage];
        cropController.delegate = self;
        [self presentViewController:cropController animated:YES completion:nil];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    //照片被取消
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Cropper Delegate -
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    CGRect viewFrame = [self.view convertRect:self.actionImageView.frame toView:self.navigationController.view];
    [cropViewController dismissAnimatedFromParentViewController:cropViewController toFrame:viewFrame completion:^{
        _actionImageView.image = image;
        _actionImageView.layer.masksToBounds = YES;
        
        UIImage *thumbnailPic = [[ASBaseManage sharedManage] scaleToSize:image size:image.size sizeLine:100];
        NSData *imgData = UIImageJPEGRepresentation(image, 1);
        NSData *thumbnailPicData = UIImageJPEGRepresentation(thumbnailPic, 1);
        
        NSString* pictureDataString = [imgData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        NSString *thumbnailStr = [thumbnailPicData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        
        if (!_eventStore.isSystemMade) {
            SportImageStore *imageStore = [SportImageStore findFirstWithFormat:@" WHERE imageKey = '%@' ", _eventStore.imageKey];
            if (imageStore) {
                imageStore.sportPhoto = pictureDataString;
                imageStore.sportThumbnailPhoto = thumbnailStr;
                [imageStore update];
            }else {
                SportImageStore *imageStore = [SportImageStore new];
                imageStore.imageKey = _eventStore.imageKey;
                imageStore.sportPhoto = pictureDataString;
                imageStore.sportThumbnailPhoto = thumbnailStr;
                [imageStore save];
            }
        }
        NSString *imageCacheCode = [NSString stringWithFormat:@"photo_%@", _eventStore.imageKey];
        [[TMCache sharedCache] setObject:image forKey:ATCacheKey(imageCacheCode)];
    }];
}

- (void)alertForCanNotDeleteImage
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:Local(@"Error operation")
                                                                   message:Local(@"Reason：system image can’t be deleted")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Okay")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
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
