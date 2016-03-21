//
//  PersonalDataChangeTV.m
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/18.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import "PersonalDataChangeTV.h"
#import "PersonalInfoCell.h"
#import "PersonalInfoTableView.h"
#import "CommonMarco.h"
#import "RESideMenu.h"
#import "JKDBHelper.h"

@interface PersonalDataChangeTV ()

@property (nonatomic, strong) NSMutableArray *allUserData;
@property (nonatomic) NSInteger mainIndex;
@property (nonatomic, strong) NSString *userDataPath;

@property (nonatomic) BOOL isFirstIn;

@end

@implementation PersonalDataChangeTV

- (void)viewDidLoad {
    [super viewDidLoad];
    _isFirstIn = YES;
    self.navigationItem.title = Local(@"User Manage");
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menuIcon"] style:UIBarButtonItemStylePlain target:self action:nil];
    menuButton.tintColor = MyGreenColor;
    [menuButton setActionBlock:^(id _Nonnull sender) {
        [self.sideMenuViewController presentLeftMenuViewController];
    }];
    self.navigationItem.leftBarButtonItem = menuButton;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus"] style:UIBarButtonItemStylePlain target:self action:nil];
    addButton.tintColor = MyGreenColor;
    [addButton setActionBlock:^(id _Nonnull sender) {
        [self alertForAddNewUser];
    }];
    self.navigationItem.rightBarButtonItem = addButton;
    
    [self getTheFreshData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!_isFirstIn) {
        [self getTheFreshData];
        [self.tableView reloadData];
    }
    _isFirstIn = NO;
}

- (void)getTheFreshData {
    _userDataPath = [[ASDataManage sharedManage] getFilePathInLibWithFolder:UserFolderName fileName:UserFileName];
    _allUserData = [[NSMutableArray alloc] initWithContentsOfFile:_userDataPath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _allUserData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"PersonalInfoCell";
    PersonalInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:cellIdentifier owner:nil options:nil] firstObject];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = CellBackgoundColor;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    NSMutableDictionary *tempDic = _allUserData[indexPath.row];
    NSString *userName = tempDic[@"userName"];
    if (userName.length == 0) {
        cell.nameLabel.text = Local(@"Default User");
    }else {
        cell.nameLabel.text = userName;
    }
    NSInteger timeStamp = [tempDic[@"addDate"] integerValue];
    NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSString *dateText = [[ASBaseManage dateFormatterForDMYE] stringFromDate:createDate];
    cell.createDateLabel.text = dateText;
    
    NSString *currentUser = [[SettingStore sharedSetting] userDataName];
    NSString *compareUser = tempDic[@"dataName"];
    if ([currentUser isEqualToString:compareUser]) {
        cell.isMain = YES;
        cell.nameLabel.textColor = MyDarkGray;
        _mainIndex = indexPath.row;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else {
        cell.nameLabel.textColor = MyLightGray;
        cell.isMain = NO;
    }
    cell.userDataName = compareUser;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == _mainIndex) {
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        PersonalInfoTableView *infoTV = [mainStoryboard instantiateViewControllerWithIdentifier:@"personalInfoPage"];
        infoTV.allUserData = _allUserData;
        infoTV.mainIndex = indexPath.row;
        infoTV.userDataPath = _userDataPath;
        [self.navigationController pushViewController:infoTV animated:YES];
        
    }else {
        NSMutableDictionary *tempDic = _allUserData[indexPath.row];
        NSString *userName = tempDic[@"userName"];
        NSString *dataName = tempDic[@"dataName"];
        [self alertForExchangeUser:userName dataName:dataName];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.row == _mainIndex) {
            //不可删除正在使用的用户
            [self alertForSampleWarning:Local(@"Can’t delete current user" )];
        }else {
            NSMutableDictionary *tempDic = _allUserData[indexPath.row];
            NSString *userName = tempDic[@"userName"];
            NSString *dataName = tempDic[@"dataName"];
            [self alertForDelete:indexPath userName:userName dataName:dataName];
        }
    }
}

#pragma mark - Alert Method

- (void)alertForDelete: (NSIndexPath *)indexPath userName: (NSString *)userName dataName:(NSString *)dataName
{
    NSString *title = [NSString stringWithFormat:Local(@"Confirm to delete this user ：%@" ), userName];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:Local(@"This is going to clear all user’s data！")
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Okay")
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * action) {
                                                
        //删除数据库
        NSFileManager * defaultManager = [NSFileManager defaultManager];
        NSURL * libraryPath = [[defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]firstObject];
        NSString * fileContainFloder = [libraryPath.path stringByAppendingPathComponent:dataName];
        [defaultManager removeItemAtPath:fileContainFloder error:nil];
                                                
        //删除文件
        [_allUserData removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
        [_allUserData writeToFile:_userDataPath atomically:YES];
                                                
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertForExchangeUser: (NSString *)userName dataName:(NSString *)dataName
{
    NSString *title = [NSString stringWithFormat:Local(@"Switch to user：%@"), userName];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:Local(@"Switch user")
                                                                   message:title
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Okay")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
        [[JKDBHelper shareInstance] changeDBWithDirectoryName:dataName];
        [[SettingStore sharedSetting] setUserDataName:dataName];
        [[SettingStore sharedSetting] setUserName:userName];
        [[ASDataManage sharedManage] inputFirstData];
        [self.tableView reloadData];
        [KVNProgress showSuccessWithStatus:Local(@"Switch success！")];
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertForAddNewUser
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:Local(@"New User")
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = Local(@"Please type in user’s name");
        textField.tintColor = MyGreenColor;
    }];
    
    UITextField *alertTextField = alert.textFields[0];
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Okay")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                if (alertTextField.text.length == 0) {
                                                    [self alertForSampleWarning:Local(@"User’s name can’t be blank")];
                                                }else {
                                                    [self addNewUserData:alertTextField.text];
                                                }
                                                
                                            }]];
    
    
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)addNewUserData: (NSString *)userName {
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    NSInteger timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *userDataName = [NSString stringWithFormat:@"AmosSportData_%@", @(timeStamp)];
    NSString *timeStampStr = [NSString stringWithFormat:@"%@", @(timeStamp)];
    
    [tempDic setObject:userName forKey:@"userName"];
    [tempDic setObject:userDataName forKey:@"dataName"];
    [tempDic setObject:timeStampStr forKey:@"addDate"];
    [_allUserData addObject:tempDic];
    
    [self.tableView reloadData];
    
    [_allUserData writeToFile:_userDataPath atomically:YES];
    //导入初始数据
    [KVNProgress showSuccessWithStatus:Local(@"Initialize success!")];
}

- (void)alertForSampleWarning: (NSString *)titleStr
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:titleStr
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Okay")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
