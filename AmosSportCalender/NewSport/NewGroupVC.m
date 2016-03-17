//
//  NewGroupVC.m
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/17.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import "NewGroupVC.h"
#import "CommonMarco.h"
#import "NewEventVC.h"
#import "SportTVCell.h"

@interface NewGroupVC ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *groupSetNameText;
@property (weak, nonatomic) IBOutlet UILabel *eventNumberLabel;

@property (weak, nonatomic) IBOutlet UIControl *levelOneView;
@property (weak, nonatomic) IBOutlet UIControl *levelTwoView;
@property (weak, nonatomic) IBOutlet UIControl *levelThreeView;

@property (weak, nonatomic) IBOutlet UILabel *levelOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelTwoLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelThreeLabel;
@property (weak, nonatomic) IBOutlet UIView *sepView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) BOOL isFirstIn;
@property (nonatomic, strong) NSMutableArray *allRecordData;
@property (nonatomic, strong) NSString *criStr;

@end

@implementation NewGroupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isFirstIn = YES;
    _criStr = [NSString stringWithFormat:@" WHERE isGroupSet = '1' AND groupSetPK = '%d' ", _groupStore.pk];
    [self getTheFreshData];
    [self initTheFrameUI];
    [self updateButtonState];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:nil];
    saveButton.tintColor = MyGreenColor;
    [saveButton setActionBlock:^(id _Nonnull sender) {
        if (_groupSetNameText.text.length == 0) {
            [self alertForNeedText];
        }else {
            _groupStore.groupName = _groupSetNameText.text;
            if ([_groupStore update]) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus"] style:UIBarButtonItemStylePlain target:self action:nil];
    addButton.tintColor = MyGreenColor;
    [addButton setActionBlock:^(id _Nonnull sender) {
        NewEventVC *newEvent = [[NewEventVC alloc] init];
        SportRecordStore *recordStore = [SportRecordStore new];
        newEvent.recordStore = recordStore;
        newEvent.pageState = 4;
        newEvent.groupSetPK = _groupStore.pk;
        UINavigationController *eventNav = [[UINavigationController alloc] initWithRootViewController:newEvent];
        
        [self presentViewController:eventNav animated:YES completion:nil];
    }];
    self.navigationItem.rightBarButtonItems = @[saveButton, addButton];
    
    if (_isNew) {
        self.navigationItem.title = [NSString stringWithFormat:@"新建组合-%@", _groupStore.groupPart];
        _groupSetNameText.text = @"";
        [_groupSetNameText becomeFirstResponder];
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:nil];
        cancelButton.tintColor = MyGreenColor;
        [cancelButton setActionBlock:^(id _Nonnull sender) {
            [self alertForNotSave];
        }];
        self.navigationItem.leftBarButtonItem = cancelButton;
        
    }else {
        self.navigationItem.title = [NSString stringWithFormat:@"修改组合-%@", _groupStore.groupPart];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_isFirstIn) {
        [self getTheFreshData];
        NSInteger countNum = [_allRecordData count];
        _eventNumberLabel.text = [NSString stringWithFormat:@"包含运动项目数量：%@项", @(countNum)];
        [self.tableView reloadData];
    }
    _isFirstIn = NO;
}

- (void)getTheFreshData {
    _allRecordData = [[NSMutableArray alloc] initWithArray:[SportRecordStore findByCriteria:_criStr]];
}

- (IBAction)clickToChangeLevel:(UIControl *)sender {
    [_groupSetNameText resignFirstResponder];
    _groupStore.groupLevel = sender.tag;
    [self updateButtonState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _allRecordData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SportTVCell";
    SportTVCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:cellIdentifier owner:nil options:nil] firstObject];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = CellBackgoundColor;
        cell.sepView.hidden = YES;
        cell.couldBeDone = NO;
    }
    
    SportRecordStore *recordStore = _allRecordData[indexPath.row];
    cell.recordStore = recordStore;
    
    return cell;
}

//设置滑动后出现的选项
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //删除的方法
    UITableViewRowAction *deleteAction = [UITableViewRowAction
                                          rowActionWithStyle:UITableViewRowActionStyleDestructive
                                          title:Local(@"Delete")
                                          handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        SportRecordStore *recordStore = _allRecordData[indexPath.row];
        if ([recordStore deleteObject]) {
          [_allRecordData removeObject:recordStore];
          [tableView deleteRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
        }
                                          }];
    
    //修改内容的方法
    UITableViewRowAction *editAction = [UITableViewRowAction
                                        rowActionWithStyle:UITableViewRowActionStyleNormal
                                        title:Local(@"Edit")
                                        handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        NewEventVC *newEvent = [[NewEventVC alloc] init];
        SportRecordStore *recordStore = _allRecordData[indexPath.row];
        newEvent.recordStore = recordStore;
        newEvent.pageState = 4;
        newEvent.groupSetPK = _groupStore.pk;
        UINavigationController *eventNav = [[UINavigationController alloc] initWithRootViewController:newEvent];
        
        [self presentViewController:eventNav animated:YES completion:nil];
                                        }];
    editAction.backgroundColor = [UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1];
    
    return @[deleteAction, editAction]; //与实际显示的顺序相反
}

#pragma mark - Helper Method

- (void)initTheFrameUI {
    _levelOneView.layer.cornerRadius = 5;
    _levelOneView.layer.borderWidth = 0.7;
    _levelTwoView.layer.cornerRadius = 5;
    _levelTwoView.layer.borderWidth = 0.7;
    _levelThreeView.layer.cornerRadius = 5;
    _levelThreeView.layer.borderWidth = 0.7;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _sepView.backgroundColor = [[ASBaseManage sharedManage] colorForsportType:_groupStore.groupPart];
    _groupSetNameText.text = _groupStore.groupName;
    _groupSetNameText.delegate = self;
    
    NSInteger countNum = [_allRecordData count];
    _eventNumberLabel.text = [NSString stringWithFormat:@"包含运动项目数量：%@项", @(countNum)];
    _eventNumberLabel.textColor = MyLightGray;
}

- (void)updateButtonState {
    _levelOneView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _levelOneView.backgroundColor = MyWhite;
    _levelOneLabel.textColor = [UIColor lightGrayColor];
    _levelTwoView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _levelTwoView.backgroundColor = MyWhite;
    _levelTwoLabel.textColor = [UIColor lightGrayColor];
    _levelThreeView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _levelThreeView.backgroundColor = MyWhite;
    _levelThreeLabel.textColor = [UIColor lightGrayColor];
    
    if (_groupStore.groupLevel == 1) {
        _levelOneLabel.textColor = MyWhite;
        _levelOneView.backgroundColor = ColorForLevel1;
        _levelOneView.layer.borderColor = ColorForLevel1.CGColor;
    }else if (_groupStore.groupLevel == 2) {
        _levelTwoLabel.textColor = MyWhite;
        _levelTwoView.backgroundColor = ColorForLevel2;
        _levelTwoView.layer.borderColor = ColorForLevel2.CGColor;
    }else if (_groupStore.groupLevel == 3) {
        _levelThreeLabel.textColor = MyWhite;
        _levelThreeView.backgroundColor = ColorForLevel3;
        _levelThreeView.layer.borderColor = ColorForLevel3.CGColor;
    }
}

#pragma mark - Alert Method

- (void)alertForNotSave {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"在编辑中退出"
                                                                   message:@"这将清空所有未保存的数据"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确认"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * action) {
        if ([_groupStore deleteObject]) {
            [SportRecordStore deleteObjectsByCriteria:_criStr];
            [self.navigationController popViewControllerAnimated:YES];
        }
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertForNeedText {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"组合名称不可为空"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确认"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
