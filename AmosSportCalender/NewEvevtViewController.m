//
//  NewEvevtViewController.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/7/25.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "NewEvevtViewController.h"
#import "Event.h"
#import "EventStore.h"

@interface NewEvevtViewController ()<UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate, UISearchBarDelegate>


//Data
@property (strong, nonatomic)NSMutableArray *sportNameTemps;
@property (nonatomic) NSInteger indexRow;

//TextField
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UITextField *sportTypeTextField;
@property (weak, nonatomic) IBOutlet UITextField *sportNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *weightTextFeild;
@property (weak, nonatomic) IBOutlet UITextField *timelastFeild;
@property (weak, nonatomic) IBOutlet UITextField *timesFeild;
@property (weak, nonatomic) IBOutlet UITextField *rapFeild;

@property (strong, nonatomic) UITextField *searchBarType;

//Utility
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIPickerView *sportPicker;
@property (strong, nonatomic) UIPickerView *sportTypePicker;
@property (strong, nonatomic) UISearchBar *sportSearchBar;
@property (weak, nonatomic) IBOutlet UISwitch *swithButton;
@property (weak, nonatomic) IBOutlet UISwitch *doneSwitchButton;
@property (weak, nonatomic) IBOutlet UISlider *weightSlider;
@property (weak, nonatomic) IBOutlet UISlider *timelastSlider;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *finishBarButtonItem;
@property (weak, nonatomic) IBOutlet UILabel *weightUnitLabel;

//View
@property (weak, nonatomic) IBOutlet UIView *outsideView; ///<边框和背景View
@property (weak, nonatomic) IBOutlet UIView *seprateView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UILabel *rapLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *doneLabel;

@end

@implementation NewEvevtViewController

- (void)setEvent:(Event *)event
{
    _event = event;
}

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];

    //UIView的初始化
    self.outsideView.layer.cornerRadius = 8;
    self.outsideView.backgroundColor = [UIColor whiteColor];
    self.seprateView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.5];
    if (!self.event.done) {
        //关
        self.doneLabel.textColor = [UIColor lightGrayColor];
        self.outsideView.layer.borderWidth = 1.;
        self.outsideView.layer.borderColor = [[UIColor colorWithWhite:0.7 alpha:0.7] CGColor];
    }else if (self.event.done){
        //开
        self.outsideView.layer.borderWidth = 1.5;
        self.outsideView.layer.borderColor = [[UIColor colorWithRed:0.2000 green:0.6235 blue:0.9882 alpha:1] CGColor];
    }
    
    //datePick初始化
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.datePicker setDate:self.date animated:YES];
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
    //sportPick初始化
    self.sportPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.sportPicker.delegate = self;
    self.sportSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 44.)];
    self.sportSearchBar.delegate = self;
    
    //sportTypePicker初始化
    self.sportTypePicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.sportTypePicker.delegate = self;
    
    //设置sportPicker的属性
    [self getSportPickerData];
    
    //键盘属性
    self.weightTextFeild.keyboardType = UIKeyboardTypeNumberPad;
    self.timelastFeild.keyboardType = UIKeyboardTypeNumberPad;
    self.timesFeild.keyboardType = UIKeyboardTypeNumberPad;
    self.rapFeild.keyboardType = UIKeyboardTypeNumberPad;
    self.dateTextField.inputView = self.datePicker;
    self.dateTextField.tintColor = [UIColor clearColor];
    self.sportTypeTextField.inputView = self.sportPicker;
    self.sportTypeTextField.inputAccessoryView = self.sportSearchBar;
    self.sportTypeTextField.tintColor = [UIColor clearColor];
    self.sportNameTextField.inputView = self.sportPicker;
    self.sportNameTextField.inputAccessoryView = self.sportSearchBar;
    self.sportNameTextField.tintColor = [UIColor clearColor];
    
    self.sportSearchBar.returnKeyType = UIReturnKeySearch;
    self.sportSearchBar.placeholder = @"输入搜索内容、前缀或新建项目名称";
    
    //设置UI显示的属性值
    NSString *dateStr = [NSString stringWithFormat:@"%@", self.date];
    NSString *newStr = [dateStr substringToIndex:10];
    self.navigationItem.title = newStr;
    
    NSString *showStr = [[self dateFormatter] stringFromDate:self.date];
    NSString *compareStr = [[self dateFormatter] stringFromDate:[NSDate date]];
    if ([showStr isEqualToString:compareStr]) {
        self.dateTextField.text = @"今天";
    } else{
    self.dateTextField.text = showStr;
    }
    
    [self.dateTextField sizeToFit];
    
    self.sportTypeTextField.text = self.event.sportType;
    self.sportNameTextField.text = self.event.sportName;
    self.weightTextFeild.text = [NSString stringWithFormat:@"%i", (int)self.event.weight];
    self.timelastFeild.text = [NSString stringWithFormat:@"%d", self.event.timelast];
    self.timesFeild.text = [NSString stringWithFormat:@"%d", self.event.times];
    self.rapFeild.text = [NSString stringWithFormat:@"%d", self.event.rap];
    self.weightSlider.value = self.event.weight;
    self.weightSlider.continuous = YES;
    self.timelastSlider.value = self.event.timelast;
    self.doneSwitchButton.on = self.event.done;
    
    //重量的UI显示
    if ([self.weightTextFeild.text isEqualToString:@"220"]) {
        self.weightTextFeild.textColor = [UIColor clearColor];
        self.weightUnitLabel.text = @"自重";
        self.weightUnitLabel.textAlignment = NSTextAlignmentLeft;
    }else{
        self.weightTextFeild.textColor = [UIColor blackColor];
        self.weightUnitLabel.text = @"Kg";
        self.weightUnitLabel.textAlignment = NSTextAlignmentRight;
    }
}

- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd EEEE";
    }
    
    return dateFormatter;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Method
-(void)dateChanged:(id)sender{
    NSString *newStr = [[self dateFormatter] stringFromDate:self.datePicker.date];
    NSString *compareStr = [[self dateFormatter] stringFromDate:[NSDate date]];
    
    if ([newStr isEqualToString:compareStr]) {
        self.dateTextField.text = @"今天";
    } else{
        self.dateTextField.text = newStr;
    }

}

- (IBAction)isDoneOrNot:(UISwitch *)sender {
    
    if (!self.doneSwitchButton.isOn) {
        //关
        self.doneLabel.textColor = [UIColor lightGrayColor];
        self.outsideView.layer.borderWidth = 1.;
        self.outsideView.layer.borderColor = [[UIColor colorWithWhite:0.7 alpha:0.7] CGColor];
    }else{
        //开
        self.doneLabel.textColor = [UIColor blackColor];
        self.outsideView.layer.borderWidth = 1.5;
        self.outsideView.layer.borderColor = [[UIColor colorWithRed:0.2000 green:0.6235 blue:0.9882 alpha:1] CGColor];
    }
}

- (IBAction)NotHaveRapAndTimes:(UISwitch *)sender {
    if (!self.swithButton.isOn){
        //关
        [self weightChangeValue:self.weightSlider];
        self.weightUnitLabel.text = @"Kg";
        self.weightUnitLabel.textAlignment = NSTextAlignmentRight;
        
        self.timesFeild.text = @"0";
        self.timesFeild.textColor = [UIColor lightGrayColor];
        self.timesFeild.enabled = NO;
        
        self.rapFeild.text = @"0";
        self.rapFeild.textColor = [UIColor lightGrayColor];
        self.rapFeild.enabled = NO;
        
        self.weightTextFeild.text = @"0";
        self.weightTextFeild.textColor = [UIColor lightGrayColor];
        self.weightTextFeild.enabled = NO;
        [self.weightSlider setValue:0 animated:YES];
        self.weightSlider.enabled = NO;
        
        self.rapLabel.textColor = [UIColor lightGrayColor];
        self.weightLabel.textColor = [UIColor lightGrayColor];
    }else{
        //开
        self.timesFeild.textColor = [UIColor blackColor];
        self.timesFeild.enabled = YES;
        self.timesFeild.text = [NSString stringWithFormat:@"%i", self.event.times];
        
        self.rapFeild.textColor = [UIColor blackColor];
        self.rapFeild.enabled = YES;
        self.rapFeild.text = [NSString stringWithFormat:@"%i", self.event.rap];
        
        self.weightTextFeild.textColor = [UIColor blackColor];
        self.weightTextFeild.enabled = YES;
        self.weightTextFeild.text = [NSString stringWithFormat:@"%i", (int)self.event.weight];
        self.weightSlider.enabled = YES;
        [self.weightSlider setValue:self.event.weight animated:YES];
        
        self.rapLabel.textColor = [UIColor darkGrayColor];
        self.weightLabel.textColor = [UIColor darkGrayColor];
        
        [self weightChangeValue:self.weightSlider];
    }
    
}
- (IBAction)weightChangeValue:(UISlider *)sender {
    int i = roundf(sender.value);
    if (i % 5 == 0) {
    self.weightTextFeild.text = [NSString stringWithFormat:@"%i",i];
    }
    
    if ([self.weightTextFeild.text isEqualToString:@"220"]) {
        self.weightTextFeild.textColor = [UIColor clearColor];
        self.weightUnitLabel.text = @"自重";
        self.weightUnitLabel.textAlignment = NSTextAlignmentLeft;
    }else{
        self.weightTextFeild.textColor = [UIColor blackColor];
        self.weightUnitLabel.text = @"Kg";
        self.weightUnitLabel.textAlignment = NSTextAlignmentRight;
    }
    
    Event *event = self.event;
    event.weight = [self.weightTextFeild.text floatValue];
}
- (IBAction)timeChangeValue:(UISlider *)sender {
    self.timelastFeild.text = [NSString stringWithFormat:@"%i", (int)roundf(sender.value)];
}

- (IBAction)finishAndCreateEvent:(UIBarButtonItem *)sender {
    //保存更改后的值
    Event *event = self.event;
    event.sportType = self.sportTypeTextField.text;
    event.eventDate = self.datePicker.date;
    event.sportName = self.sportNameTextField.text;
    event.weight = [self.weightTextFeild.text floatValue];
    event.timelast = [self.timelastFeild.text intValue];
    event.times = [self.timesFeild.text intValue];
    event.rap = [self.rapFeild.text intValue];
    event.done = self.doneSwitchButton.on;
    
    if (self.createNewEvent){
    [[EventStore sharedStore] createItem:event date:self.event.eventDate];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        BOOL success = [[EventStore sharedStore] saveChanges];
        if (success) {
            NSLog(@"新建事件后，储存数据成功");
        }else{
            NSLog(@"新建事件后，储存数据失败！");
        }
    }];
}
- (IBAction)finishThisEventAndCreateAnotherEvent:(UIBarButtonItem *)sender {
    [self finishAndCreateEvent:self.finishBarButtonItem];

    if (self.creatEventBlock) {
        self.creatEventBlock();
    }
}

- (IBAction)cancelTheEvent:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)backgroundTapped:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark - Textfield Delegate
- (IBAction)sportTypeAndNameText:(UITextField *)sender {
    
    NSString *componentStr1 = self.sportNameTextField.text;
    
    unsigned long index = 0;
    int row1 = 9999;
    int row2 = 0;
    
    //搜索方法
    for (int i = 0; i < self.sportTypes.count; i++){
        NSArray *tepArray =[[self.sportTypes objectAtIndex:i] objectForKey:@"sportName"];
        if ([tepArray containsObject:componentStr1]){
            index = [tepArray indexOfObject:componentStr1];
            row1 = i;
            row2 = (int)index;
            break;
        }
    }
    
    if (row1 == 9999) {
        
    }else{
        NSLog(@"row1 = %i, row2 = %i", row1, row2);
        
        [self.sportPicker selectRow:(NSInteger)row1 inComponent:0 animated:YES];
        self.sportNames = [[self.sportTypes objectAtIndex:row1] objectForKey:@"sportName"];
        [self.sportPicker reloadComponent:1];
        [self.sportPicker selectRow:(NSInteger)row2 inComponent:1 animated:YES];
    }
}

- (BOOL)textFieldShouldBeginEditing:(nonnull UITextField *)textField
{
    if (textField == self.searchBarType) {
        textField.textColor = [UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:0.8];
    }else{
    textField.text = @"";
    }
    return YES;
}

- (void)textFieldDidEndEditing:(nonnull UITextField *)textField
{

    if (textField == self.searchBarType) {
        textField.textColor = [UIColor blackColor];
    }else{
    
    if ([self ifEnterNumber:textField.text]) {

    int weight = [self.weightTextFeild.text intValue];
    if (weight > 220) {
        weight = 220;
        [self actionAlert];
    }
    
    int time = [self.timelastFeild.text intValue];
    if (time > 90) {
        time = 90;
        [self actionAlert];
    }
        
    self.weightTextFeild.text = [NSString stringWithFormat:@"%i", weight];
    self.weightSlider.value = weight;
    self.timelastFeild.text = [NSString stringWithFormat:@"%i", time];
    self.timelastSlider.value = time;
    
    int times = [self.timesFeild.text intValue];
    if (times > 99) {
        times = 99;
        [self actionAlert];
    }
    self.timesFeild.text = [NSString stringWithFormat:@"%i", times];
    
    int rap = [self.rapFeild.text intValue];
    if (rap > 99) {
        rap = 99;
        [self actionAlert];
    }
    self.rapFeild.text = [NSString stringWithFormat:@"%i", rap];
        
    Event *event = self.event;
    event.timelast = [self.timelastFeild.text intValue];
    event.times = [self.timesFeild.text intValue];
    event.rap = [self.rapFeild.text intValue];
    event.weight = [self.weightTextFeild.text floatValue];
    }else{
        textField.text = @"";
        [self alertForOnlyNumber];
    }}
}

- (BOOL)textFieldShouldReturn:(nonnull UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)actionAlert
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"不好意思"
                                                               message:@"你设的值超出了作者的运动极限，所以本软件懒得支持"
                                                        preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"(ˑˆᴗˆˑ)"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Picker Data Source Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    if (pickerView == self.sportPicker) {
        return 2;
    }else{
        return 1;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (pickerView == self.sportPicker) {
    switch (component) {
        case 0:
            return [self.sportTypes count];
            break;
        case 1:
            return [self.sportNames count]?[self.sportNames count]:0;
            break;
        default:
            return 0;
            break;
    }}else{
        return [self.sportTypes count];
    }
        
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (pickerView == self.sportPicker) {
        switch (component) {
            case 0:
                return [[self.sportTypes objectAtIndex:row] objectForKey:@"sportType"];
                break;
            case 1:
                return [self.sportNames objectAtIndex:row];
                break;
            default:
                return nil;
                break;
        }}else{
            return [[self.sportTypes objectAtIndex:row] objectForKey:@"sportType"];
        }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (pickerView == self.sportPicker) {
    switch (component) {
        case 0:
            self.sportNames = [[self.sportTypes objectAtIndex:row] objectForKey:@"sportName"];
            [self.sportPicker selectRow:0 inComponent:1 animated:YES];
            [self.sportPicker reloadComponent:1];
            
            self.sportTypeTextField.text = [[self.sportTypes objectAtIndex:row] objectForKey:@"sportType"];
            self.sportNameTextField.text = [self.sportNames objectAtIndex:0];
            break;
        case 1:
            self.sportNameTextField.text = [self.sportNames objectAtIndex:row];
            break;
        default:
            break;
    }
        //如果选择了体力类别，则关闭组数等选项
    if ([self.sportTypeTextField.text isEqualToString:@"体力"]) {
        [self.swithButton setOn:NO animated:YES];
        [self NotHaveRapAndTimes:self.swithButton];
    }else if (![self.sportTypeTextField.text isEqualToString:@"体力"]){
        [self.swithButton setOn:YES animated:YES];
        [self NotHaveRapAndTimes:self.swithButton];
    }}else{
        
        self.indexRow = row;
        self.searchBarType.text = [[self.sportTypes objectAtIndex:row] objectForKey:@"sportType"];
        
        self.sportNameTemps = [[self.sportTypes objectAtIndex:row] objectForKey:@"sportName"];
        
    }
}

#pragma mark - searchBar
- (BOOL)searchBarShouldBeginEditing:(nonnull UISearchBar *)searchBar
{
    self.sportSearchBar.showsCancelButton = YES;
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(nonnull UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarCancelButtonClicked:(nonnull UISearchBar *)searchBar
{
    self.sportSearchBar.text = @"";
    [self.sportSearchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(nonnull UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    NSString *searchResult = searchBar.text;
    unsigned long index = 0;
    int row1 = 9999;
    int row2 = 0;
    
    //搜索方法
    for (int i = 0; i < self.sportTypes.count; i++){
        NSArray *tepArray =[[self.sportTypes objectAtIndex:i] objectForKey:@"sportName"];
        if ([tepArray containsObject:searchResult]){
            index = [tepArray indexOfObject:searchResult];
            row1 = i;
            row2 = (int)index;
            break;
        }
        for (int k = 0; k < tepArray.count; k++) {
            if ([tepArray[k] hasPrefix:searchResult]) {
                row1 = i;
                row2 = k;
                break;
            }
        }
    }
    
    if (row1 == 9999) {
        [self actionAlertForNotSearchResult: searchBar.text];
    }else{
        NSLog(@"row1 = %i, row2 = %i", row1, row2);
        [self.sportPicker selectRow:(NSInteger)row1 inComponent:0 animated:YES];
        self.sportNames = [[self.sportTypes objectAtIndex:row1] objectForKey:@"sportName"];
        [self.sportPicker reloadComponent:1];
        [self.sportPicker selectRow:(NSInteger)row2 inComponent:1 animated:YES];
        
        self.sportTypeTextField.text = [[self.sportTypes objectAtIndex:row1] objectForKey:@"sportType"];
        self.sportNameTextField.text = [self.sportNames objectAtIndex:row2];
    }
}

#pragma mark - data Method
- (void)actionAlertForNotSearchResult: (NSString *)searchResult
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"新建"
                                                                   message:@"不好意思，没有收录名称相同的项目。根据需要，可以新建运动项目。"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"胸部";
        textField.tintColor = [UIColor clearColor];
        textField.inputView = self.sportTypePicker;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = searchResult;
        textField.placeholder = @"请在此输入运动名称";
        
        [textField becomeFirstResponder];
    }];
    
    self.searchBarType = alert.textFields[0];
    self.searchBarType.delegate = self;
    
    UITextField *sportNameField = alert.textFields[1];
    self.sportNameTemps = [NSMutableArray array];
    self.sportNameTemps = [[self.sportTypes objectAtIndex:0] objectForKey:@"sportName"];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确认"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                
    [self.sportNameTemps addObject:sportNameField.text];
    [self saveTheDate];
    [self getSportPickerData];
    [self.sportPicker reloadAllComponents];
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {
                                                
                                            }]];

    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertForOnlyNumber
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"不好意思"
                                                                   message:@"不要测试了，只能输入数字滴。"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"明白了"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {
                                            }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)getSportPickerData{
    //设置sportPicker的属性
    NSFileManager * defaultManager = [NSFileManager defaultManager];
    NSURL * documentPath = [[defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]firstObject];
    NSString * fileContainFloder = [documentPath.path stringByAppendingPathComponent:@"sportEventData"];
    NSString * fileSavePath = [fileContainFloder stringByAppendingPathComponent:@"sportTypeArray.plist"];
    NSArray * array = [NSArray arrayWithContentsOfFile:fileSavePath];

    self.sportTypes = array;
        
    if (!self.sportNames) {
        self.sportNames = [NSArray array];
    }
    self.sportNames = [[self.sportTypes objectAtIndex:0] objectForKey:@"sportName"];
}

- (void)saveTheDate
{
    NSFileManager * defaultManager = [NSFileManager defaultManager];
    NSURL * documentPath = [[defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]firstObject];
    NSString * fileContainFloder = [documentPath.path stringByAppendingPathComponent:@"sportEventData"];
    NSString * fileSavePath = [fileContainFloder stringByAppendingPathComponent:@"sportTypeArray.plist"];
    NSArray * array = [NSArray arrayWithContentsOfFile:fileSavePath];
    
    NSMutableArray *MuSportTypes = [[NSMutableArray alloc] initWithArray:array];
    
    [[[MuSportTypes objectAtIndex:self.indexRow] objectForKey:@"sportName"] removeAllObjects];
    [[[MuSportTypes objectAtIndex:self.indexRow] objectForKey:@"sportName"] addObjectsFromArray:self.sportNameTemps];
    
    BOOL successWrited = [MuSportTypes writeToFile:fileSavePath atomically:YES];
    
    if (successWrited) {
        NSLog(@"已更新运动项目plist数据！");
    }else{
        NSLog(@"更新失败！");
    }
}

//是否输入的是数字
- (BOOL)ifEnterNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}
@end
