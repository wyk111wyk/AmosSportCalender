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
@property (nonatomic, strong) NSArray *levelArr;

@end

@implementation NewGroupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isFirstIn = YES;
    _levelArr = @[Local(@"Beginner level"), Local(@"Middle level"), Local(@"High level")];
    _criStr = [NSString stringWithFormat:@" WHERE isGroupSet = '1' AND groupSetPK = '%d' ", _groupStore.pk];
    [self getTheFreshData];
    [self initTheFrameUI];
    [self updateButtonState];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:Local(@"Save") style:UIBarButtonItemStyleDone target:self action:nil];
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
        newEvent.isNew = YES;
        newEvent.groupSetPK = _groupStore.pk;
        UINavigationController *eventNav = [[UINavigationController alloc] initWithRootViewController:newEvent];
        
        [self presentViewController:eventNav animated:YES completion:nil];
    }];
    self.navigationItem.rightBarButtonItems = @[saveButton, addButton];
    
    if (_isNew) {
        self.navigationItem.title = [NSString stringWithFormat:Local(@"New combin - %@"), _groupStore.groupPart];
//        _groupSetNameText.text = @"";
        [_groupSetNameText becomeFirstResponder];
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:Local(@"Cancel") style:UIBarButtonItemStylePlain target:self action:nil];
        cancelButton.tintColor = MyGreenColor;
        [cancelButton setActionBlock:^(id _Nonnull sender) {
            [self alertForNotSave];
        }];
        self.navigationItem.leftBarButtonItem = cancelButton;
        
    }else {
        self.navigationItem.title = [NSString stringWithFormat:Local(@"Modify combin - %@"), _groupStore.groupPart];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_isFirstIn) {
        [self getTheFreshData];
        NSInteger countNum = [_allRecordData count];
        _eventNumberLabel.text = [NSString stringWithFormat:Local(@"Include Sports：%@"), @(countNum)];
        [self.tableView reloadData];
    }
    _isFirstIn = NO;
}

- (void)getTheFreshData {
    _allRecordData = [[NSMutableArray alloc] initWithArray:[SportRecordStore findByCriteria:_criStr]];
}

- (IBAction)clickToChangeLevel:(UIControl *)sender {
    [_groupSetNameText resignFirstResponder];
    NSString *oldLevelStr = _levelArr[_groupStore.groupLevel-1];
    _groupStore.groupLevel = sender.tag;
    NSString *newLevelStr = _levelArr[_groupStore.groupLevel-1];
    
    if ([_groupSetNameText.text containsString:oldLevelStr]) {
        NSRange strRang = [_groupSetNameText.text rangeOfString:oldLevelStr];
        _groupSetNameText.text = [_groupSetNameText.text stringByReplacingCharactersInRange:strRang withString:newLevelStr];
    }
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
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.sepView.hidden = YES;
        cell.couldBeDone = NO;
    }
    
    SportRecordStore *recordStore = _allRecordData[indexPath.row];
    cell.recordStore = recordStore;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NewEventVC *newEvent = [[NewEventVC alloc] init];
    SportRecordStore *recordStore = _allRecordData[indexPath.row];
    newEvent.recordStore = recordStore;
    newEvent.pageState = 4;
    newEvent.isNew = NO;
    newEvent.groupSetPK = _groupStore.pk;
    UINavigationController *eventNav = [[UINavigationController alloc] initWithRootViewController:newEvent];
    
    [self presentViewController:eventNav animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        SportRecordStore *recordStore = _allRecordData[indexPath.row];
        if ([recordStore deleteObject]) {
            [_allRecordData removeObject:recordStore];
            [tableView deleteRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
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
    
    UIColor *partColor = [[ASBaseManage sharedManage] colorForsportType:_groupStore.groupPart];
    _sepView.backgroundColor = partColor;
    if (_isNew) {
        NSString *levelStr = _levelArr[_groupStore.groupLevel-1];
        NSString *groupSetName = [NSString stringWithFormat:Local(@"%@%@ Sport combination"), levelStr, _groupStore.groupPart];
        _groupStore.groupName = groupSetName;
    }
    _groupSetNameText.text = _groupStore.groupName;
    _groupSetNameText.delegate = self;
    
    NSInteger countNum = [_allRecordData count];
    _eventNumberLabel.text = [NSString stringWithFormat:Local(@"Include Sports：%@"), @(countNum)];
    _eventNumberLabel.textColor = partColor;
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
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:Local(@"Exit without saving")
                                                                   message:Local(@"This is going to clear all unsaved data")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Okay")
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * action) {
        if ([_groupStore deleteObject]) {
            [SportRecordStore deleteObjectsByCriteria:_criStr];
            [self.navigationController popViewControllerAnimated:YES];
        }
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertForNeedText {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:Local(@"Combination name cannot be blank")
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Okay")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
