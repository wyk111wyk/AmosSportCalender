//
//  GroupDetailTV.m
//  AmosSportDiary
//
//  Created by Amos Wu on 15/10/4.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "GroupDetailTV.h"
#import "GroupDetailCell.h"
#import "NewGroupVC.h"
#import "CommonMarco.h"
#import "AbstractActionSheetPicker.h"
#import "ActionSheetDatePicker.h"

@interface GroupDetailTV ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *allGroupSets;
@property (nonatomic, strong) NSArray *allSportImages;

@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) UITextField *groupNameField;
@property (nonatomic) BOOL isFirstIn;

@end

@implementation GroupDetailTV

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isFirstIn = YES;
    self.navigationItem.title = [NSString stringWithFormat:Local(@"Choose %@ Comb"), _groupPart];
    [self setExtraCellLineHidden:self.tableView];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus"] style:UIBarButtonItemStylePlain target:self action:nil];
    addButton.tintColor = MyGreenColor;
    [addButton setActionBlock:^(id _Nonnull sender) {
        NewGroupVC *newGroup = [[NewGroupVC alloc] init];
        newGroup.isNew = YES;
        GroupSetStore *newStore = [GroupSetStore new];
        newStore.groupPart = _groupPart;
        [newStore save];
        newGroup.groupStore = newStore;
        [self.navigationController pushViewController:newGroup animated:YES];
    }];
    self.navigationItem.rightBarButtonItem = addButton;
    
    _allSportImages = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SportImages" ofType:@"plist"]];
    [self getTheFreshData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_isFirstIn) {
        [self getTheFreshData];
        [self.tableView reloadData];
    }
    _isFirstIn = NO;
}

- (void)getTheFreshData {
    NSString *criStr = [NSString stringWithFormat:@" WHERE groupPart = '%@' ORDER by groupLevel ", _groupPart];
    _allGroupSets = [[NSMutableArray alloc] initWithArray:[GroupSetStore findByCriteria:criStr]];
}

//没有内容的cell分割线隐藏
- (void)setExtraCellLineHidden: (UITableView *)tableView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _allGroupSets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"GroupDetailCell";
    GroupDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:cellIdentifier owner:nil options:nil] firstObject];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = CellBackgoundColor;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.iconImageView.image = [UIImage imageNamed:_allSportImages[_imageIndex]];
    }
    
    GroupSetStore *groupStore = _allGroupSets[indexPath.row];
    cell.groupSetName.text = groupStore.groupName;
    cell.levelLabel.text = [NSString stringWithFormat:@"%@", @(groupStore.groupLevel)];
    if (groupStore.groupLevel == 1) {
        cell.levelLabel.textColor = ColorForLevel1;
        cell.levelBGView.layer.borderColor = ColorForLevel1.CGColor;
    }else if (groupStore.groupLevel == 2) {
        cell.levelLabel.textColor = ColorForLevel2;
        cell.levelBGView.layer.borderColor = ColorForLevel2.CGColor;
    }else if (groupStore.groupLevel == 3) {
        cell.levelLabel.textColor = ColorForLevel3;
        cell.levelBGView.layer.borderColor = ColorForLevel3.CGColor;
    }
    
    NSString *criStr = [NSString stringWithFormat:@" WHERE isGroupSet = '1' AND groupSetPK = '%d' ", groupStore.pk];
    NSInteger countNum = [SportRecordStore findCounts:criStr];
    cell.numOfEvent.text = [NSString stringWithFormat:Local(@"Include Sports：%@"), @(countNum)];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GroupSetStore *groupStore = _allGroupSets[indexPath.row];
    NSString *criStr = [NSString stringWithFormat:@" WHERE isGroupSet = '1' AND groupSetPK = '%d' ", groupStore.pk];
    NSInteger countNum = [SportRecordStore findCounts:criStr];
    if (countNum == 0) {
        [self alertForHaveNoEvent];
    }else {
        [self alertForAddIndexPath:indexPath];
    }
}

//设置滑动后出现的选项
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //删除的方法
    UITableViewRowAction *deleteAction = [UITableViewRowAction
                                          rowActionWithStyle:UITableViewRowActionStyleDestructive
                                          title:Local(@"Delete")
          handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
              GroupSetStore *groupStore = _allGroupSets[indexPath.row];
              if ([groupStore deleteObject]) {
                  NSString *criStr = [NSString stringWithFormat:@" WHERE isGroupSet = '1' AND groupSetPK = '%d' ", groupStore.pk];
                  [SportRecordStore deleteObjectsByCriteria:criStr];
                  [_allGroupSets removeObject:groupStore];
                  [tableView deleteRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
              }
                                          }];
    
    //修改内容的方法
    UITableViewRowAction *editAction = [UITableViewRowAction
                                        rowActionWithStyle:UITableViewRowActionStyleNormal
                                        title:Local(@"Edit")
            handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
                NewGroupVC *newGroup = [[NewGroupVC alloc] init];
                newGroup.isNew = NO;
                GroupSetStore *newStore = _allGroupSets[indexPath.row];
                newGroup.groupStore = newStore;
                
                [self.navigationController pushViewController:newGroup animated:YES];
                                        }];
    editAction.backgroundColor = [UIColor orangeColor];
    
    return @[deleteAction, editAction]; //与实际显示的顺序相反
}

#pragma mark - Alert 

- (void)alertForHaveNoEvent
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:Local(@"Can not choose this combination")
                                                                   message:Local(@"Reason：this combination does not include any sport，please add one first")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Okay")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertForAddIndexPath: (NSIndexPath*)indexPath
{
    GroupSetStore *groupStore = _allGroupSets[indexPath.row];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:groupStore.groupName
                                                                   message:Local(@"Choose date to adding combination")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = Local(@"Today");
        textField.tintColor = [UIColor clearColor];
    }];
    
    _groupNameField = alert.textFields[0];
    _groupNameField.delegate = self;
    
    __weak typeof(self)
    weakSelf = self;
    [_groupNameField addBlockForControlEvents:UIControlEventTouchDown block:^(id  _Nonnull sender) {
        [weakSelf clickToChangeDate];
    }];
    _selectedDate = [NSDate date];
    
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Okay")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
        NSString *criStr = [NSString stringWithFormat:@" WHERE isGroupSet = '1' AND groupSetPK = '%d' ", groupStore.pk];
        NSMutableArray *recordData = [[NSMutableArray alloc] initWithArray:[SportRecordStore findByCriteria:criStr]];
        for (SportRecordStore *recordStore in recordData){
            SportRecordStore *newStore = [SportRecordStore new];
            
            newStore.sportName = recordStore.sportName;
            newStore.sportEquipment = recordStore.sportEquipment;
            newStore.sportPart = recordStore.sportPart;
            newStore.sportSerialNum = recordStore.sportSerialNum;
            newStore.sportType = recordStore.sportType;
            newStore.muscles = recordStore.muscles;
            newStore.isSystemMade = recordStore.isSystemMade;
            newStore.weight = recordStore.weight;
            newStore.RM = recordStore.RM;
            newStore.repeatSets = recordStore.repeatSets;
            newStore.timeLast = recordStore.timeLast;
            newStore.imageKey = recordStore.imageKey;
            
            newStore.isGroupSet = NO;
            newStore.groupSetPK = 0;
            newStore.eventTimeStamp = [_selectedDate timeIntervalSince1970];
            newStore.dateKey = [[ASBaseManage dateFormatterForDMY] stringFromDate:_selectedDate];
            newStore.datePart = [[ASDataManage sharedManage] getTheSportPartForRecord:newStore isNew:YES];
            [newStore save];
        }
                                             
        [[ASDataManage sharedManage] refreshSportEventsForDate:_selectedDate];
        [self dismissViewControllerAnimated:YES completion:^{
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
        }];
        
    }]];
                                            
    
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return NO;
}

- (void)clickToChangeDate {
    AbstractActionSheetPicker *newDatePicker = [[ActionSheetDatePicker alloc]initWithTitle:Local(@"Choose date to exercise") datePickerMode:UIDatePickerModeDate selectedDate:[NSDate date] doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        _selectedDate = selectedDate;
        NSString *newStr = [[ASBaseManage dateFormatterForDMYE] stringFromDate:selectedDate];
        NSString *compareStr = [[ASBaseManage dateFormatterForDMYE] stringFromDate:[NSDate date]];
        if ([newStr isEqualToString:compareStr]) {
            _groupNameField.text = Local(@"Today");
        } else{
            NSString *gapDays = [[ASBaseManage sharedManage] getDaysWith:selectedDate];
            _groupNameField.text = [NSString stringWithFormat:@"%@ %@", newStr, gapDays];
        }
    } cancelBlock:^(ActionSheetDatePicker *picker) {
        
    } origin:self.view];
    [newDatePicker addCustomButtonWithTitle:Local(@"Today") value:[NSDate date]];
    
    newDatePicker.tapDismissAction = TapActionSuccess;
    newDatePicker.hideCancel = YES;
    
    [newDatePicker showActionSheetPicker];
}

- (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

@end
