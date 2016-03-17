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

@interface GroupDetailTV ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *allGroupSets;
@property (nonatomic, strong) NSArray *allSportImages;

@property (nonatomic) BOOL isFirstIn;

@end

@implementation GroupDetailTV

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isFirstIn = YES;
    self.navigationItem.title = [NSString stringWithFormat:@"%@-组合", _groupPart];
    [self setExtraCellLineHidden:self.tableView];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus"] style:UIBarButtonItemStylePlain target:self action:nil];
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
    }else if (groupStore.groupLevel == 2) {
        cell.levelLabel.textColor = ColorForLevel2;
    }else if (groupStore.groupLevel == 3) {
        cell.levelLabel.textColor = ColorForLevel3;
    }
    
    NSString *criStr = [NSString stringWithFormat:@" WHERE isGroupSet = '1' AND groupSetPK = '%d' ", groupStore.pk];
    NSInteger countNum = [SportRecordStore findCounts:criStr];
    cell.numOfEvent.text = [NSString stringWithFormat:@"包含运动项目数量：%@项", @(countNum)];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
    editAction.backgroundColor = [UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1];
    
    return @[deleteAction, editAction]; //与实际显示的顺序相反
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
