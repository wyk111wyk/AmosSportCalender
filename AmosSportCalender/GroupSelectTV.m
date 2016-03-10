//
//  GroupSelectTV.m
//  AmosSportDiary
//
//  Created by Amos Wu on 15/10/4.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "CommonMarco.h"
#import "GroupSelectTV.h"
#import "GroupSelectCell.h"
#import "GroupDetailTV.h"
#import "SettingStore.h"
#import "GroupStore.h"
#import "EventStore.h"
#import "AbstractActionSheetPicker.h"
#import "ActionSheetDatePicker.h"

static NSString* const typeManageCellReuseId = @"groupManageCell";

@interface GroupSelectTV ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    UIView *keyboardView;
    UIBarButtonItem *rightButton;
    NSInteger selectedSection; ///<点选的行数
    NSMutableDictionary *allEventsByType; ///<储存所有事件的Dic
    NSString *newName;
    NSString *oldName;
    UITextField *groupNameField;
    NSDate *selectedDate;
}
@property (nonatomic, strong)NSArray *sportTypes;
@property (nonatomic, strong)NSString *sportType;
@property (nonatomic, strong)NSArray *sportNames;
@property (nonatomic)NSInteger indexRow;

@end

@implementation GroupSelectTV

- (void)viewDidLoad {
    [super viewDidLoad];
    
    rightButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(changeToEditMood)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.title = @"精选组合";
    
    NSFileManager * defaultManager = [NSFileManager defaultManager];
    NSURL * documentPath = [[defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]firstObject];
    NSString * fileContainFloder = [documentPath.path stringByAppendingPathComponent:@"sportEventData"];
    NSString * fileSavePath = [fileContainFloder stringByAppendingPathComponent:@"sportTypeArray.plist"];
    NSArray * array = [NSArray arrayWithContentsOfFile:fileSavePath];
    self.sportTypes = array;
    
    //从数据库里载入所有数据
    [self initTheKeyboardView];
}

- (void)initTheKeyboardView
{
    //键盘上放的View
    keyboardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 30)];
    keyboardView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    UIView *sepView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0.5)];
    sepView.backgroundColor = [UIColor lightGrayColor];
    
    UIButton *finishButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 80, 0, 60, 30)];
    [finishButton setTitle:@"完成" forState:UIControlStateNormal];
    [finishButton setTitleColor:MyGreenColor forState:UIControlStateNormal];
    finishButton.tintColor = MyGreenColor;
    [finishButton addTarget:self action:@selector(finishTyping) forControlEvents:UIControlEventTouchUpInside];
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:MyGreenColor forState:UIControlStateNormal];
    cancelButton.tintColor = MyGreenColor;
    [cancelButton addTarget:self action:@selector(cancelTyping) forControlEvents:UIControlEventTouchUpInside];
    [keyboardView addSubview:sepView];
    [keyboardView addSubview:cancelButton];
    [keyboardView addSubview:finishButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //每次重新载入就更新数据
    [[GroupStore sharedStore] updateAllData];
    [self initAllData];
    
    [self.tableView reloadData];
}

- (void)initAllData
{
    allEventsByType = [[NSMutableDictionary alloc] initWithDictionary:[[GroupStore sharedStore] allItems] copyItems:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button method
- (void)changeToEditMood
{
    if (!self.tableView.editing) {
        [self.tableView setEditing:YES];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveTheEditMood)];
        self.navigationItem.rightBarButtonItem = doneButton;
    }
    
    [self.tableView reloadData];
}

- (void)saveTheEditMood
{
    if (self.tableView.editing) {
        [self.tableView setEditing:NO];
        self.navigationItem.rightBarButtonItem = rightButton;
    }
    
    [self.tableView reloadData];
}

- (void)finishTyping
{
    [self.view endEditing:YES];
    
    NSString *type = [[self.sportTypes objectAtIndex:selectedSection] objectForKey:@"sportType"];
    
    if ([self findSameName:type name:newName]) {
        [self alertForHaveSameName];
    }else{
        NSMutableArray *array = allEventsByType[type][oldName];
        [allEventsByType[type] removeObjectForKey:oldName];
        [allEventsByType[type] setObject:array forKey:newName];
        
        [[GroupStore sharedStore] editTheNameOfGroup:type groupName:oldName newName:newName];
        //储存数据
        BOOL success = [[GroupStore sharedStore] saveGroupData];
        if (DeBugMode) {
            if (success) {
                NSLog(@"Group数据 - 修改name后，储存数据成功");
            }else{
                NSLog(@"Group数据 - 修改name后，储存数据失败！");
            }}
    }
}

- (void)cancelTyping
{
    [self.view endEditing:YES];
}

- (void)clickToPlusGroupName: (UIButton*)sender
{
    if (sender) {
        selectedSection = sender.tag;
    }
    [self alertForplusGroupName];
}

#pragma mark - Alert Method

- (void)alertForplusGroupName
{
    NSString *type = [[self.sportTypes objectAtIndex:selectedSection] objectForKey:@"sportType"];
    NSString *titleStr = [NSString stringWithFormat:@"新建一个组合：%@", type];
    NSString *textStr = [NSString stringWithFormat:@"%@运动组合", type];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:titleStr
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = textStr;
        textField.placeholder = @"输入组合的名称";
        textField.tintColor = MyGreenColor;
    }];
    
    UITextField *groupNameField1 = alert.textFields[0];
    groupNameField1.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * action) {
            NSString *name = groupNameField1.text;
            
            if ([self findSameName:type name:name]) {
                [self alertForHaveSameName];
            }else{
                NSMutableArray *temArray = [NSMutableArray array];
                //修改临时的表格数据
                if (!allEventsByType[type]){
                    allEventsByType[type] = [NSMutableDictionary dictionary];
                }
                [allEventsByType[type] setObject:temArray forKey:name];
                //刷新TableView
                [self.tableView reloadData];
                //修改本地储存的数据
                [[GroupStore sharedStore] createGroup:type groupName:name];
                //储存数据
                BOOL success = [[GroupStore sharedStore] saveGroupData];
                if (DeBugMode) {
                    if (success) {
                        NSLog(@"Group数据 - 新建name后，储存数据成功");
                    }else{
                        NSLog(@"Group数据 - 新建name后，储存数据失败！");
                    }}
            }
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertForHaveSameName
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"无法完成操作"
                                                                   message:@"原因：该名称已存在"
                                                            preferredStyle:UIAlertControllerStyleAlert];
                      
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertForHaveNoEvent
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"无法完成操作"
                                                                   message:@"原因：该组合内没有任何运动项目"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertForAddEvents: (NSArray *)eventArray name:(NSString *)name
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:name
                                                                   message:@"选择需要添加的日期"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"今天";
        textField.tintColor = [UIColor clearColor];
    }];
    
    groupNameField = alert.textFields[0];
    groupNameField.delegate = self;
    [groupNameField addTarget:self action:@selector(clickToChangeDate:) forControlEvents:UIControlEventTouchDown];
    //初始化日期到今天
    selectedDate = [NSDate date];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault
            handler:^(UIAlertAction * action) {
                [[EventStore sharedStore] createArray:eventArray date:selectedDate];
                [[EventStore sharedStore] saveChanges];
                [self.navigationController popToRootViewControllerAnimated:YES];
                
                //取消所有通知
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - TextField

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == groupNameField) {
        return NO;
    }
    oldName = textField.text;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    newName = textField.text;
    selectedSection = textField.tag;
    self.navigationItem.rightBarButtonItem.enabled = YES;

    NSString *type = [[self.sportTypes objectAtIndex:selectedSection] objectForKey:@"sportType"];
    if ([self findSameName:type name:newName]){
        textField.text = oldName;
    }
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sportTypes.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 5, screenWidth, 35)];
    header.backgroundColor = [UIColor clearColor];
    
    //Title
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 150, 25)];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    
    NSString *tempStr = [[self.sportTypes objectAtIndex:section] objectForKey:@"sportType"];
    label.text = tempStr;
    label.center = header.center;
    
    SettingStore *setting = [SettingStore sharedSetting];
    NSArray *oneColor = [setting.typeColorArray objectAtIndex:section];
    UIColor *pickedColor = [UIColor colorWithRed:[oneColor[0] floatValue] green:[oneColor[1] floatValue] blue:[oneColor[2] floatValue] alpha:1];
    label.textColor = pickedColor;
    
    //Button
    UIButton *plusButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 60, 10, 60, 25)];
    UIImageView *plus = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"plus"]];
    plus.image = [plus.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    plus.tintColor = MyGreenColor;
    
    [plusButton setImage:plus.image forState:UIControlStateNormal];
    plusButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -5);
    plusButton.tag = section;
    [plusButton addTarget:self action:@selector(clickToPlusGroupName:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.tableView.editing) {
        plusButton.hidden = YES;
    }else{
        plusButton.hidden = NO;
    }
    
    [header addSubview:plusButton];
    [header addSubview:label];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [self.sportTypes[section] objectForKey:@"sportType"];
    if ([allEventsByType[key] count] > 0) {
        return [allEventsByType[key] count];
    }else{
        return 1;
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSString *key = [self.sportTypes[indexPath.section] objectForKey:@"sportType"];
    GroupSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:typeManageCellReuseId forIndexPath:indexPath];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = CellBackgoundColor;
    cell.groupTypeField.delegate = self;
    cell.groupTypeField.tag = indexPath.section;
    
    if ([allEventsByType[key] count] > 0) {
        
        if (tableView.editing) {
            cell.groupTypeField.borderStyle = UITextBorderStyleRoundedRect;
            cell.groupTypeField.enabled = YES;
        }else{
            cell.groupTypeField.borderStyle = UITextBorderStyleNone;
            cell.groupTypeField.enabled = NO;
        }
        
        NSString *tempStr = [allEventsByType[key] allKeys][indexPath.row];
        cell.groupTypeField.text = tempStr;
        cell.groupTypeField.textColor = [UIColor darkGrayColor];
        cell.groupTypeField.inputAccessoryView = keyboardView;
        
        cell.groupNumLabel.hidden = NO;
        NSUInteger i = allEventsByType[key][tempStr] ? [allEventsByType[key][tempStr] count] : 0;
        cell.groupNumLabel.text = [NSString stringWithFormat:@"包含：%@ 项", @(i)];
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
        
        return cell;
    }else{
        
        cell.groupTypeField.borderStyle = UITextBorderStyleNone;
        cell.groupTypeField.enabled = NO;
        cell.groupTypeField.text = @"创建第一个运动组合";
        cell.groupTypeField.textColor = [UIColor lightGrayColor];
        cell.groupNumLabel.hidden = YES;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [self.sportTypes[indexPath.section] objectForKey:@"sportType"];
    if ([allEventsByType[key] count] > 0) {
        return YES;
    }else{
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [self.sportTypes[indexPath.section] objectForKey:@"sportType"];
    NSArray *keyArray = [allEventsByType[key] allKeys];
    [allEventsByType[key] removeObjectForKey:(keyArray[indexPath.row])];
    if ([allEventsByType[key] count]>1) {
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [[GroupStore sharedStore] removeGroup:key groupName:keyArray[indexPath.row]];
    //储存数据
    BOOL success = [[GroupStore sharedStore] saveGroupData];
    if (DeBugMode) {
        if (success) {
            NSLog(@"Group数据 - 删除name后，储存数据成功");
        }else{
            NSLog(@"Group数据 - 删除name后，储存数据失败！");
        }}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *key = [self.sportTypes[indexPath.section] objectForKey:@"sportType"];
    NSArray *eventArray = [NSArray array];
    
    if ([allEventsByType[key] count] > 0) {
        
         NSString *name = [allEventsByType[key] allKeys][indexPath.row];
        eventArray = [allEventsByType[key][name] copy];
        
        if (eventArray.count > 0) {
            [self alertForAddEvents:eventArray name:name];
        }else{
            [self alertForHaveNoEvent];
        }
        
    }else{
        selectedSection = indexPath.section;
        [self clickToPlusGroupName:nil];
    }
}

#pragma mark - Other Method

- (void)prepareForSegue:(nonnull UIStoryboardSegue *)segue sender:(nullable id)sender
{
    //    NSLog(@"%@", NSStringFromSelector(_cmd));
    if ([segue.identifier isEqualToString:@"groupDetailSegue"]) {
        
        UINavigationController *nc = (UINavigationController *)segue.destinationViewController;
        GroupDetailTV *groupDetail = (GroupDetailTV *)[nc topViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        NSString *key = [[self.sportTypes objectAtIndex:indexPath.section] objectForKey:@"sportType"];
        NSArray *keyArray = [allEventsByType[key] allKeys];
        NSString *name = keyArray[indexPath.row];
    
        groupDetail.belong = key;
        groupDetail.navTitle = name;
//        groupDetail.allDataArray = [allEventsByType[key][name] copy];
    }
}

- (BOOL)findSameName: (NSString *)type name:(NSString *)name
{
    NSArray *nameArray = [allEventsByType[type] allKeys];
    return [nameArray containsObject:name];
}

- (void)clickToChangeDate:(UITextField *)sender {
    
    NSString *minDate = @"2000-01-01";
    NSString *maxDate = @"2030-01-01";
    NSDateFormatter *limtedDateFormatter = [NSDateFormatter new];
    limtedDateFormatter.dateFormat = @"yyyy-MM-dd";
    
    AbstractActionSheetPicker *newDatePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"选择添加日期" datePickerMode:UIDatePickerModeDate selectedDate:[NSDate date] minimumDate:[limtedDateFormatter dateFromString:minDate] maximumDate:[limtedDateFormatter dateFromString:maxDate] target:self action:@selector(dateWasSelected:) origin:self.view];
    [newDatePicker addCustomButtonWithTitle:@"今天" value:[NSDate date]];
    
    newDatePicker.tapDismissAction = TapActionSuccess;
    newDatePicker.hideCancel = YES;
    
    [newDatePicker showActionSheetPicker];
}

- (void)dateWasSelected:(NSDate *)selecteDate{
    groupNameField.textColor = [UIColor blackColor];
    selectedDate = selecteDate;
    
    NSString *newStr = [[self dateFormatter] stringFromDate:selecteDate];
    NSString *compareStr = [[self dateFormatter] stringFromDate:[NSDate date]];
    
    if ([newStr isEqualToString:compareStr]) {
        groupNameField.text = Local(@"Today");
    } else{
        groupNameField.text = newStr;
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
@end
