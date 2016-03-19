//
//  SportPartManageTV.m
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/10.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import "SportPartManageTV.h"
#import "CommonMarco.h"
#import "TypeDisplayCell.h"
#import "ColorPickerViewController.h"
#import "SportEventManage.h"
#import "RESideMenu.h"
#import "GroupDetailTV.h"

@interface SportPartManageTV ()<ASEventDelegate>

@property (nonatomic, strong) NSArray *allSportParts;
@property (nonatomic, strong) NSArray *allSportImages;

@end

@implementation SportPartManageTV

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_pageState == 0) {
        self.navigationItem.title = @"运动项目管理";
        UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menuIcon"] style:UIBarButtonItemStylePlain target:self action:nil];
        [menuButton setActionBlock:^(id _Nonnull sender) {
            [self.sideMenuViewController presentLeftMenuViewController];
        }];
        self.navigationItem.leftBarButtonItem = menuButton;
        menuButton.tintColor = MyGreenColor;
    }else if(_pageState == 1) {
        self.navigationItem.title = @"预置组合";
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:nil];
        [cancelButton setActionBlock:^(id _Nonnull sender) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        self.navigationItem.leftBarButtonItem = cancelButton;
        cancelButton.tintColor = MyGreenColor;
    }else if (_pageState == 2) {
        self.navigationItem.title = @"挑选部位";
    }
    
    
    _allSportParts = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SportParts" ofType:@"plist"]];
    _allSportImages = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SportImages" ofType:@"plist"]];
    [self setExtraCellLineHidden:self.tableView];
}

//没有内容的cell分割线隐藏
- (void)setExtraCellLineHidden: (UITableView *)tableView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _allSportParts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"TypeDisplayCell";
    TypeDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:cellIdentifier owner:nil options:nil] firstObject];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = CellBackgoundColor;
    }
    
    NSString *sportPart = _allSportParts[indexPath.row];
    NSString *imageName = _allSportImages[indexPath.row];
    cell.iconImageView.image = [UIImage imageNamed:imageName];
    if (_pageState == 0 || _pageState == 2) {
        cell.iconLabel.text = sportPart;
        NSString *criStr = [NSString stringWithFormat:@" WHERE sportPart = '%@' ", sportPart];
        NSInteger countNum = [SportEventStore findCounts:criStr];
        cell.stateLabel.text = [NSString stringWithFormat:@"包含数目：%@项", @(countNum)];
    }else if (_pageState == 1) {
        cell.iconLabel.text = [NSString stringWithFormat:@"%@-组合", sportPart];
        NSString *criStr = [NSString stringWithFormat:@" WHERE groupPart = '%@' ", sportPart];
        NSInteger countNum = [GroupSetStore findCounts:criStr];
        cell.stateLabel.text = [NSString stringWithFormat:@"共计：%@组", @(countNum)];
    }
    
    //字体颜色
    SettingStore *setting = [SettingStore sharedSetting];
    NSArray *oneColor = [setting.typeColorArray objectAtIndex:indexPath.row];
    UIColor *pickedColor = [UIColor colorWithRed:[oneColor[0] floatValue] green:[oneColor[1] floatValue] blue:[oneColor[2] floatValue] alpha:1];
    cell.themeColor = pickedColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_pageState == 0 || _pageState == 2) {
        SportEventManage *eventTV = [[SportEventManage alloc] initWithStyle:UITableViewStylePlain];
        eventTV.delegate = self;
        eventTV.colorIndex = indexPath.row;
        eventTV.sportPart = _allSportParts[indexPath.row];
        eventTV.canEditEvents = _canEditEvents;
        [self.navigationController pushViewController:eventTV animated:YES];
    }else if (_pageState == 1) {
        GroupDetailTV *groupDetail = [[GroupDetailTV alloc] initWithStyle:UITableViewStylePlain];
        groupDetail.groupPart = _allSportParts[indexPath.row];
        groupDetail.imageIndex = indexPath.row;
        [self.navigationController pushViewController:groupDetail animated:YES];
    }
}


- (void)ASEventDidChoose:(SportEventStore *)eventStore {
    if (self.chooseSportBlock) {
        self.chooseSportBlock(eventStore);
    }
}

//这两个方法是必须的
-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

//设置滑动后出现的选项
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingStore *setting = [SettingStore sharedSetting];
    
    UITableViewRowAction *editColorAction = [UITableViewRowAction
                                             rowActionWithStyle:UITableViewRowActionStyleDestructive
                                             title:@"改变颜色"
                                             handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
         NSArray *oneColor = [setting.typeColorArray objectAtIndex:indexPath.row];
         UIColor *pickedColor = [UIColor colorWithRed:[oneColor[0] floatValue] green:[oneColor[1] floatValue] blue:[oneColor[2] floatValue] alpha:1];
         
         ColorPickerViewController *controller;
         controller = [[ColorPickerViewController alloc] initWithColor:pickedColor fullColor:YES];
         controller.indexPathRow = indexPath.row;
         controller.refreshBlock = ^{
             [tableView reloadData];
         };
         [self.navigationController pushViewController:controller animated:YES];
                                             }];
    
    editColorAction.backgroundColor = MyGreenColor;
    
    return @[editColorAction]; //与实际显示的顺序相反
}

@end
