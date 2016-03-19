//
//  SportEventManage.m
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/10.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import "SportEventManage.h"
#import "EventDisplayCell.h"
#import "CommonMarco.h"
#import "NewEventVC.h"

@interface SportEventManage ()

@property (nonatomic, strong) NSMutableArray *allStarEventData;
@property (nonatomic, strong) NSMutableArray *allUnstarEventData;

@end

@implementation SportEventManage

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getAllFreshData];
    self.navigationItem.title = [NSString stringWithFormat:@"%@(%@)", _sportPart, @(_allStarEventData.count+_allUnstarEventData.count)];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus"] style:UIBarButtonItemStylePlain target:self action:nil];
    [addButton setActionBlock:^(id _Nonnull sender) {
        NewEventVC *newEvent = [NewEventVC new];
        newEvent.pageState = 2;
        
        SportEventStore *eventStore = [SportEventStore new];

        eventStore.isSystemMade = NO;
        eventStore.sportPart = _sportPart;
        if ([_sportPart isEqualToString:@"拉伸"]) {
            eventStore.sportType = 2;
        }else if ([_sportPart isEqualToString:@"耐力"]) {
            eventStore.sportType = 1;
        }
        newEvent.eventStore = eventStore;
        [self.navigationController pushViewController:newEvent animated:YES];
    }];
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.rightBarButtonItem.tintColor = MyGreenColor;
    self.navigationItem.leftBarButtonItem.tintColor = MyGreenColor;
    
    NSNotificationCenter *nc1 = [NSNotificationCenter defaultCenter];
    [nc1 addObserver:self selector:@selector(refreshAllEventsData) name:RefreshSportEventsNotifcation object:nil];
}

- (void)getAllFreshData {
    NSString *criStarStr = [NSString stringWithFormat:@" WHERE sportPart = '%@' AND isStar = '1' ", _sportPart];
    NSString *criUnstarStr = [NSString stringWithFormat:@" WHERE sportPart = '%@' AND isStar = '0' ", _sportPart];
    _allStarEventData = [[NSMutableArray alloc] initWithArray:[SportEventStore findByCriteria:criStarStr]];
    _allUnstarEventData = [[NSMutableArray alloc] initWithArray:[SportEventStore findByCriteria:criUnstarStr]];
}

- (void)refreshAllEventsData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getAllFreshData];
        [self.tableView reloadData];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 30)];
    header.backgroundColor = MyWhite;
    UIView *sepView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, screenWidth, 0.6)];
    sepView.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.8];
    
    //Title
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 150, 18)];
    label.font = [UIFont boldSystemFontOfSize:13];
    label.textColor = [[UIColor purpleColor] colorWithAlphaComponent:0.8];
    
    if (section == 0) {
        label.text = @"★ 星标动作";
    }else if (section == 1) {
        label.text = @"其他";
    }
    
    [header addSubview:sepView];
    [header addSubview:label];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    footer.backgroundColor = MyWhite;
    UIView *upSepView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, screenWidth-15, 0.6)];
    upSepView.backgroundColor = [UIColor colorWithRed:0.7843 green:0.7804 blue:0.8000 alpha:1];
    [footer addSubview:upSepView];
    
    return footer;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _allStarEventData.count;
    }else if (section == 1) {
        return _allUnstarEventData.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 57;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"EventDisplayCell";
    EventDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:cellIdentifier owner:nil options:nil] firstObject];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = CellBackgoundColor;
        if (_canEditEvents) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    SportEventStore *eventStore;
    if (indexPath.section == 0) {
        eventStore = _allStarEventData[indexPath.row];
    }else if (indexPath.section == 1) {
        eventStore = _allUnstarEventData[indexPath.row];
    }
    
    cell.equipLabel.text = eventStore.sportEquipment;
    cell.sportNameLabel.text = eventStore.sportName;
    cell.muscleLabel.text = eventStore.muscles;
    cell.partLabel.text = _sportPart;
    
    if (eventStore.isStar) {
        cell.starImageView.hidden = NO;
    }else {
        cell.starWeigh.constant = 0;
    }
    
    //字体颜色
    SettingStore *setting = [SettingStore sharedSetting];
    NSArray *oneColor = [setting.typeColorArray objectAtIndex:_colorIndex];
    UIColor *pickedColor = [UIColor colorWithRed:[oneColor[0] floatValue] green:[oneColor[1] floatValue] blue:[oneColor[2] floatValue] alpha:1];
    cell.themeColor = pickedColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SportEventStore *eventStore;
    if (indexPath.section == 0) {
        eventStore = _allStarEventData[indexPath.row];
    }else if (indexPath.section == 1) {
        eventStore = _allUnstarEventData[indexPath.row];
    }
    if (_canEditEvents) {
        NewEventVC *newEvent = [NewEventVC new];
        newEvent.pageState = 3;
        newEvent.eventStore = eventStore;
        [self.navigationController pushViewController:newEvent animated:YES];
    }else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ASEventDidChoose:)])
        {
            [self.delegate ASEventDidChoose:eventStore];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

//这两个方法是必须的
-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

//实现协议规定的方法，需要向UITableView发送该消息
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

//设置滑动后出现的选项
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SportEventStore *eventStore;
    if (indexPath.section == 0) {
        eventStore = _allStarEventData[indexPath.row];
    }else if (indexPath.section == 1) {
        eventStore = _allUnstarEventData[indexPath.row];
    }
    
    UITableViewRowAction *starColorAction = [UITableViewRowAction
                                             rowActionWithStyle:UITableViewRowActionStyleDefault
                                             title:@"★星标"
                                             handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
     eventStore.isStar = !eventStore.isStar;
     if (eventStore.isStar) {
         [_allStarEventData addObject:eventStore];
         [_allUnstarEventData removeObject:eventStore];
     }else {
         [_allUnstarEventData addObject:eventStore];
         [_allStarEventData removeObject:eventStore];
     }
     if ([eventStore update]) {
         [tableView reloadData];
     }
                                             }];
    UITableViewRowAction *deleteColorAction = [UITableViewRowAction
                                             rowActionWithStyle:UITableViewRowActionStyleDestructive
                                             title:@"删除"
                                             handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
                                                 [self alertForDelete:eventStore indexPath:indexPath];
                                             }];
    starColorAction.backgroundColor = [UIColor colorWithRed:0.9529 green:0.7725 blue:0.1765 alpha:1];
    
    return @[starColorAction, deleteColorAction]; //与实际显示的顺序相反
}

- (void)alertForDelete: (SportEventStore *)eventStore indexPath:(NSIndexPath *)indexPath
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"删除这项运动"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确认"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * action) {
    if ([eventStore deleteObject]){
        if (indexPath.section == 0) {
            [_allStarEventData removeObject:eventStore];
        }else if (indexPath.section == 1) {
            [_allUnstarEventData removeObject:eventStore];
        }
        [SportImageStore deleteObjectsWithFormat:@" WHERE sportEventPK = '%d' ", eventStore.pk];
        [self.tableView deleteRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
    }
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
