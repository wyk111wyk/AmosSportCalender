//
//  NewEvevtViewController.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/7/25.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "NewEvevtViewController.h"
#import "Event.h"

@interface NewEvevtViewController ()<UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate, UISearchBarDelegate>
@property (nonatomic) BOOL datePickerisUp;
@property (nonatomic) BOOL sportPickerisUp;

@property (weak, nonatomic) IBOutlet UIView *sportTypePickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *sportTypePicker;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLabel;

@property (weak, nonatomic) IBOutlet UILabel *sportNameLabel;

@property (weak, nonatomic) IBOutlet UITextField *weightTextFeild;
@property (weak, nonatomic) IBOutlet UITextField *timelastFeild;
@property (weak, nonatomic) IBOutlet UITextField *timesFeild;
@property (weak, nonatomic) IBOutlet UITextField *rapFeild;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@end

@implementation NewEvevtViewController

- (void)setEvent:(Event *)event
{
    _event = event;
}

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_date) {
        
        self.datePicker.date = _date;
            
        NSString *dateStr = [NSString stringWithFormat:@"%@", _date];
        NSString *newStr = [dateStr substringToIndex:10];
        
        self.navigationItem.title = newStr;
        self.dateLabel.text = newStr;
    }
    
    //键盘属性
    self.weightTextFeild.keyboardType = UIKeyboardTypeDecimalPad;
    self.timelastFeild.keyboardType = UIKeyboardTypeDecimalPad;
    self.timesFeild.keyboardType = UIKeyboardTypeDecimalPad;
    self.rapFeild.keyboardType = UIKeyboardTypeDecimalPad;
    
    //设置Picker的初始位置
    CGRect datePickerRect = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.datePicker.frame.size.width, self.datePicker.frame.size.height);
    self.datePicker.frame = datePickerRect;
    self.datePicker.hidden = YES;
    self.datePickerisUp = NO;

    CGRect sportTypePickerRect = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, self.sportTypePickerView.frame.size.height);
    self.sportTypePickerView.frame = sportTypePickerRect;
    self.sportTypePicker.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height + self.searchBar.frame.size.height, self.sportTypePicker.frame.size.width, self.sportTypePicker.frame.size.height);
    self.sportTypePickerView.hidden = YES;
    self.sportPickerisUp = NO;
    
    //设置显示的属性值
    self.eventLabel.text = self.event.sportType;
    self.sportNameLabel.text = self.event.sportName;
    self.weightTextFeild.text = [NSString stringWithFormat:@"%.1f", self.event.weight];
    self.timelastFeild.text = [NSString stringWithFormat:@"%d", self.event.timelast];
    self.timesFeild.text = [NSString stringWithFormat:@"%d", self.event.times];
    self.rapFeild.text = [NSString stringWithFormat:@"%d", self.event.rap];
    
    NSFileManager * defaultManager = [NSFileManager defaultManager];
    NSURL * documentPath = [[defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]firstObject];
    NSString * fileContainFloder = [documentPath.path stringByAppendingPathComponent:@"sportEventData"];
    NSString * fileSavePath = [fileContainFloder stringByAppendingPathComponent:@"chestArray.plist"];
    NSArray * array = [NSArray arrayWithContentsOfFile:fileSavePath];
    
    self.sportTypes = array;
    self.sportNames = [[self.sportTypes objectAtIndex:0] objectForKey:@"sportName"];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //保存更改后的值
    Event *event = self.event;
    event.sportType = self.eventLabel.text;
    event.eventDate = self.datePicker.date;
    event.sportName = self.sportNameLabel.text;
    event.weight = [self.weightTextFeild.text floatValue];
    event.timelast = [self.timelastFeild.text intValue];
    event.times = [self.timesFeild.text intValue];
    event.rap = [self.rapFeild.text intValue];
}

#pragma mark - Button Method
- (IBAction)datePicker:(UIDatePicker *)sender {
    NSString *dateStr = [NSString stringWithFormat:@"%@", sender.date];
    NSString *newStr = [dateStr substringToIndex:10];
    self.dateLabel.text = newStr;
}

- (void)closeDatePicker
{
    [self.view endEditing:YES];
    if (self.datePickerisUp == YES) {
        [self ViewDateAnimation:self.datePicker willUp:NO];
    }
}

- (void)closeSportEventPicker
{
    [self.view endEditing:YES];
    if (self.sportPickerisUp == YES) {
        [self ViewSportEventAnimation:self.sportTypePickerView willUp:NO];
    }
}

- (IBAction)changeTheDate:(UIButton *)sender {
    [self closeSportEventPicker];
    
    if (self.datePickerisUp == NO) {
        [self ViewDateAnimation:self.datePicker willUp:YES];
    }else{
        [self ViewDateAnimation:self.datePicker willUp:NO];
    }
}
- (IBAction)changeTheSportType:(UIButton *)sender {
    [self closeDatePicker];
    
    if (self.sportPickerisUp == NO) {
        [self ViewSportEventAnimation:self.sportTypePickerView willUp:YES];
    }else{
        [self ViewSportEventAnimation:self.sportTypePickerView willUp:NO];
    }
}

- (IBAction)finishAndCreateEvent:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)cancelTheEvent:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)backgroundTapped:(id)sender
{
    [self closeDatePicker];
    [self closeSportEventPicker];
}

- (BOOL)textFieldShouldBeginEditing:(nonnull UITextField *)textField
{
    if (self.datePickerisUp == YES) {
        [self ViewDateAnimation:self.datePicker willUp:NO];
    }
    if (self.datePickerisUp == YES) {
        [self ViewSportEventAnimation:self.sportTypePickerView willUp:NO];
    }
    textField.text = @"";
    return YES;
}

- (BOOL)textFieldShouldReturn:(nonnull UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)ViewDateAnimation:(UIView*)view willUp:(BOOL)up
{
    if (up == YES) {
    view.hidden = NO;
        [UIView animateWithDuration:0.3
                              delay:0
                            options: UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                            view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - view.frame.size.height - self.toolBar.frame.size.height, view.frame.size.width, view.frame.size.height);
                             
                         } completion:^(BOOL finished) {
                             NSLog(@"++ date上升一次"); // up = YES
                             if (self.datePickerisUp == !up) {
                                 self.datePickerisUp = up;
                             }
                         }];
    }else{
        [UIView animateWithDuration:0.3
                              delay:0
                            options: UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, view.frame.size.width, view.frame.size.height);
                             
                         } completion:^(BOOL finished) {
                             NSLog(@"-- date下降一次"); // up = NO
                             if (self.datePickerisUp == !up) {
                                 self.datePickerisUp = up;
                             }
                         }];
    }
}

- (void)ViewSportEventAnimation:(UIView*)view willUp:(BOOL)up
{
    if (up == YES) {
        view.hidden = NO;
        [UIView animateWithDuration:0.3
                         animations:^{
                             
                             view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - view.frame.size.height - self.toolBar.frame.size.height, view.frame.size.width, view.frame.size.height);
                             
                         } completion:^(BOOL finished) {
                             NSLog(@"+ event上升一次"); // up = YES
                             if (self.sportPickerisUp == !up) {
                                 self.sportPickerisUp = up;
                             }
                         }];
    }else{
        [UIView animateWithDuration:0.3
                         animations:^{
                             
                             view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, view.frame.size.width, view.frame.size.height);
                             
                         } completion:^(BOOL finished) {
                             NSLog(@"- event下降一次"); // up = NO
                             if (self.sportPickerisUp == !up) {
                                 self.sportPickerisUp = up;
                             }
                         }];
    }
}

- (void)showInView:(UIView *) view
{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [view setAlpha:1.0f];
    [view.layer addAnimation:animation forKey:@"DDLocateView"];
    
    view.frame = CGRectMake(0, view.frame.size.height - [UIScreen mainScreen].bounds.size.height, view.frame.size.width, view.frame.size.height);
}

#pragma mark -
#pragma mark Picker Data Source Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
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
    }
}

#pragma mark Picker Delegate Methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
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
        }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    switch (component) {
        case 0:
            self.sportNames = [[self.sportTypes objectAtIndex:row] objectForKey:@"sportName"];
            [self.sportTypePicker selectRow:0 inComponent:1 animated:YES];
            [self.sportTypePicker reloadComponent:1];
            
            self.eventLabel.text = [[self.sportTypes objectAtIndex:row] objectForKey:@"sportType"];
            break;
        case 1:
            self.sportNameLabel.text = [self.sportNames objectAtIndex:row];
            break;
        default:
            break;
    }
}

#pragma mark - searchBar
- (BOOL)searchBarShouldBeginEditing:(nonnull UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = YES;
    return YES;
}

- (void)searchBarCancelButtonClicked:(nonnull UISearchBar *)searchBar
{
    [self closeSportEventPicker];
}

- (void)searchBarSearchButtonClicked:(nonnull UISearchBar *)searchBar
{
    [self closeDatePicker];
    [self closeSportEventPicker];
}

@end
