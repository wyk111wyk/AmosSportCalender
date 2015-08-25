//
//  NewEvevtViewController.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/7/25.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

#import "NewEvevtViewController.h"
#import "Event.h"
#import "EventStore.h"
#import "ImageStore.h"
#import "DMPasscode.h"
#import "SettingStore.h"

@interface NewEvevtViewController ()<UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate, UISearchBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

//Data
@property (strong, nonatomic)NSMutableArray *sportNameTemps;
@property (nonatomic) NSInteger indexRow;
@property (strong, nonatomic) NSArray *numberArray; ///<numberPicker的数据
@property (strong, nonatomic) NSString *selectedNumber; ///<numberPicker点选后的值

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
@property (strong, nonatomic) UIPickerView *numberPicker;

@property (strong, nonatomic) UISearchBar *sportSearchBar;
@property (nonatomic, strong) UISearchController *searchController;
@property (strong, nonatomic) UITableViewController *searchTVC;

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

// EKEventStore instance associated with the current Calendar application
@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) EKEvent *ekevent;
@property (nonatomic, strong) NSString *idf;

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
    
    UIBarButtonItem *addOneMoreButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plusOneMore"] style:UIBarButtonItemStylePlain target:self action:@selector(createOneMoreEvent:)];
    UIBarButtonItem *createNewButton = [[UIBarButtonItem alloc] initWithTitle:@"新建" style:UIBarButtonItemStylePlain target:self action:@selector(finishAndCreateEvent:)];
    UIBarButtonItem *editEventButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finishAndCreateEvent:)];
    
    if (self.createNewEvent) {
        NSArray *createButtons = [[NSArray alloc] initWithObjects:createNewButton, addOneMoreButton, nil];
        self.navigationItem.rightBarButtonItems = createButtons;
    }else{
        NSArray *editButtons = [[NSArray alloc] initWithObjects:editEventButton, addOneMoreButton, nil];
        self.navigationItem.rightBarButtonItems = editButtons;
    }
    
    //datePick初始化
    NSString *minDate = @"1990-01-01";
    NSString *maxDate = @"2030-01-01";
    NSDateFormatter *limtedDateFormatter = [NSDateFormatter new];
    limtedDateFormatter.dateFormat = @"yyyy-MM-dd";
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.minimumDate = [limtedDateFormatter dateFromString:minDate];
    self.datePicker.maximumDate = [limtedDateFormatter dateFromString:maxDate];
    [self.datePicker setDate:self.date animated:YES];
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
    //sportPicker初始化
    self.sportPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.sportPicker.delegate = self;
    
    self.sportSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 44.)];
    self.sportSearchBar.delegate = self;
    [self.sportSearchBar sizeToFit];
    self.sportSearchBar.returnKeyType = UIReturnKeySearch;
    self.sportSearchBar.placeholder = @"搜索或者新建运动项目";
    [self getSportPickerData];
//    
//    self.searchTVC = [[UITableViewController alloc]initWithStyle:UITableViewStylePlain];
//    _searchTVC.tableView.dataSource = self;
//    _searchTVC.tableView.delegate = self;
//    
//    self.searchController = [[UISearchController alloc] initWithSearchResultsController:_searchTVC];
//    self.searchController.searchResultsUpdater = self;
//    self.searchController.delegate = self;
//    [self.searchController.searchBar sizeToFit];
//    [self presentViewController:self.searchController animated:YES completion:nil];
    
    //sportTypePicker初始化
    self.sportTypePicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.sportTypePicker.delegate = self;

    //numberPicker初始化
    self.numberPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.numberPicker.delegate = self;
    
    NSMutableArray *tempNumberArray = [NSMutableArray array];
    for (int i = 0; i < 5000; i = i+99) {
        for (int k = 0; k < 100; k++) {
            [tempNumberArray addObject:[NSString stringWithFormat:@"%i", k]];
        }
    }
    self.numberArray = tempNumberArray.copy;
    
    //键盘属性
    self.weightTextFeild.tintColor = [UIColor clearColor];
    self.weightTextFeild.inputView = self.numberPicker;
    self.timelastFeild.tintColor = [UIColor clearColor];
    self.timelastFeild.inputView = self.numberPicker;
    self.timesFeild.tintColor = [UIColor clearColor];
    self.timesFeild.inputView = self.numberPicker;
    self.rapFeild.tintColor = [UIColor clearColor];
    self.rapFeild.inputView = self.numberPicker;
    
    self.dateTextField.inputView = self.datePicker;
    self.dateTextField.tintColor = [UIColor clearColor];
    self.sportTypeTextField.inputView = self.sportPicker;
    self.sportTypeTextField.inputAccessoryView = self.sportSearchBar;
    self.sportTypeTextField.tintColor = [UIColor clearColor];
    self.sportNameTextField.inputView = self.sportPicker;
    self.sportNameTextField.inputAccessoryView = self.sportSearchBar;
    self.sportNameTextField.tintColor = [UIColor clearColor];
    
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
    
    //图片显示
    NSString *itemKey = self.event.itemKey;
    if ([[ImageStore shareStore] imageForKey:itemKey]) {
    UIImage *imageToDisplay = [[ImageStore shareStore] imageForKey:itemKey];
    if (imageToDisplay) {self.imageView.image = imageToDisplay;};
    }
    
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

#pragma mark - Utility Button Method
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

#pragma mark - NavBar Button Method

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
    
    //假如是新建的事项，进行数据库新建
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
- (IBAction)createOneMoreEvent:(UIBarButtonItem *)sender {
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

- (IBAction)cameraButtonClick:(UIBarButtonItem *)sender {
    [self alertForCameraButton];
}

- (IBAction)tipsButtonClick:(UIBarButtonItem *)sender {
    [self alertForTips];
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
    }else if(textField == self.timelastFeild || textField == self.weightTextFeild || textField == self.rapFeild || textField == self.timesFeild){
        textField.textColor = [UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:0.8];
        int i = [textField.text intValue];
        [self.numberPicker selectRow:(5100/2 - 50 + i) inComponent:0 animated:NO];
    }else{
        textField.textColor = [UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:0.8];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(nonnull UITextField *)textField
{

    if (textField == self.searchBarType) {
        textField.textColor = [UIColor blackColor];
    }else if(textField == self.timelastFeild || textField == self.weightTextFeild || textField == self.rapFeild || textField == self.timesFeild){
            textField.textColor = [UIColor blackColor];
            if ([self ifEnterNumber:textField.text]) {

            int weight = [self.weightTextFeild.text intValue];
            if (weight > 220) {
                weight = 220;
                [self alertForOverLimit];
            }
            
            int time = [self.timelastFeild.text intValue];
            if (time > 90) {
                time = 90;
                [self alertForOverLimit];
            }
                
            self.weightTextFeild.text = [NSString stringWithFormat:@"%i", weight];
            self.weightSlider.value = weight;
            self.timelastFeild.text = [NSString stringWithFormat:@"%i", time];
            self.timelastSlider.value = time;
            
            int times = [self.timesFeild.text intValue];
            if (times > 99) {
                times = 99;
                [self alertForOverLimit];
            }
            self.timesFeild.text = [NSString stringWithFormat:@"%i", times];
            
            int rap = [self.rapFeild.text intValue];
            if (rap > 99) {
                rap = 99;
                [self alertForOverLimit];
            }
            self.rapFeild.text = [NSString stringWithFormat:@"%i", rap];
                
            Event *event = self.event;
            event.timelast = [self.timelastFeild.text intValue];
            event.times = [self.timesFeild.text intValue];
            event.rap = [self.rapFeild.text intValue];
            event.weight = [self.weightTextFeild.text floatValue];
        }else{
            textField.textColor = [UIColor blackColor];
            textField.text = @"";
            [self alertForOnlyNumber];
        }
    }else{
        textField.textColor = [UIColor blackColor];
    }
}

- (BOOL)textFieldShouldReturn:(nonnull UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - Picker Data Source Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    if (pickerView == self.sportPicker) {
        return 2;
    }else if(pickerView == self.sportTypePicker){
        return 1;
    }else if (pickerView == self.numberPicker){
        return 1;
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
    }}else if(pickerView == self.sportTypePicker){
        return [self.sportTypes count];
    }else if(pickerView == self.numberPicker){
        return 5100;
    }else{
        return 1;
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
        }}else if(pickerView == self.sportTypePicker){
            return [[self.sportTypes objectAtIndex:row] objectForKey:@"sportType"];
        }else{
            return [self.numberArray objectAtIndex:row];
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
        }
    }else if(pickerView == self.sportTypePicker){
        self.indexRow = row;
        self.searchBarType.text = [[self.sportTypes objectAtIndex:row] objectForKey:@"sportType"];
        self.sportNameTemps = [[self.sportTypes objectAtIndex:row] objectForKey:@"sportName"];
        
    }else{
        self.selectedNumber = self.numberArray[row];
        
        if ([self.timelastFeild isFirstResponder]) {
            self.timelastFeild.text = self.numberArray[row];
            self.timelastSlider.value = [self.numberArray[row] floatValue];
        }else if([self.timesFeild isFirstResponder]){
            self.timesFeild.text = self.numberArray[row];
        }else if ([self.rapFeild isFirstResponder]){
            self.rapFeild.text = self.numberArray[row];
        }else if ([self.weightTextFeild isFirstResponder]){
            self.weightTextFeild.text = self.numberArray[row];
            self.weightSlider.value = [self.numberArray[row] floatValue];
        }

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
    
    if (searchBar.text.length > 0) {
        
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
}

#pragma mark - alert Method

- (void)alertForOverLimit
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"不好意思"
                                                                   message:@"你设的值超出了作者的运动极限，所以本软件懒得支持"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"(ˑˆᴗˆˑ)"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertForTips
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"根据运动目的的不同"
                                                                   message:@"\n1.减脂\n先做些大肌群的中等重量复合动作训练，比如空杆的深蹲，蹲跳等。无氧后采用强度和时间都相对长的HIIT。\n\n2.紧致的线条\n可以采用多组数（20组以上），多次数（每组20次以上），中等重量（最大负重的50%）的循环力量训练。搭配强度较大，时间中等的HIIT。\n\n3.增加某部位肌肉\n大重量小组数，下落时候要有控制的非常慢，也就是注意离心收缩。"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Go！"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

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

- (void)alertForCameraButton
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"添加照片"
                                                                   message:@"放一张运动时候的英姿吧:-D"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"从图库选取"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                [self chooseTheImage];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"用相机拍摄"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                [self takePicture];
                                            }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Camera
//11.1 添加照片的方法
- (IBAction)takePicture
{
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    
    //如果设备支持相机，则使用拍照；不然就让用户从相册中挑选
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //11.12 添加摄像功能
        NSArray *availableTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        imagePicker.mediaTypes = availableTypes;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)chooseTheImage
{
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

//11.2 保存照片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //通过info字典获取选择的照片
    UIImage *image = [self setThumbnailFromImage:info[UIImagePickerControllerOriginalImage]];
    
    //    11.5 根据itemKey的键，将照片存入YKImageStore对象
    [[ImageStore shareStore] setImage:image forKey:self.event.itemKey];
    
    //    将照片放入UIImageView对象
    self.imageView.image = image;

    //    关闭UIImagePicjerController对象
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //    11.12 获取包含视频的目录
    NSURL *mediaURL = info[UIImagePickerControllerMediaURL];
    
    //将文件移至其他目录
    //检查设备是否支持视频功能
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([mediaURL path])) {
        //将视频存入相册
        UISaveVideoAtPathToSavedPhotosAlbum([mediaURL path], nil, nil, nil);
        //删除临时目录下的视频
        [[NSFileManager defaultManager] removeItemAtPath:[mediaURL path] error:nil];
    }
}

#pragma mark - data sources

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

//生成缩略图
- (UIImage *)setThumbnailFromImage:(UIImage *)image
{
    CGSize origImageSize = image.size;
    
    //缩略图的大小
    CGRect newRect = CGRectMake(0, 0, 400, 350);
    
    //确定缩放倍数并保持 宽高比例 不变
    float ratio = MAX(newRect.size.width / origImageSize.width, newRect.size.height / origImageSize.height);
    
    //根据当前设备的屏幕scaling factor创建透明的位图上下文
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    
    //创建表示圆角矩形的UIBezierPath对象
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect
                                                    cornerRadius:5.0];
    
    //根据UIBezierPath对象裁剪图形上下文
    [path addClip];
    
    //让图片在缩略图绘制的范围内居中
    CGRect projectRect;
    projectRect.size.width = ratio * origImageSize.width;
    projectRect.size.height = ratio * origImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
    
    //在上下文中绘制图片
    [image drawInRect:projectRect];
    
    //通过图形上下文得到UIImage对象，并赋给thumbnail属性
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();

    //清理图形上下文
    UIGraphicsEndPDFContext();
    
    return smallImage;
}
@end
