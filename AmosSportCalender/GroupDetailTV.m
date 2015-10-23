//
//  GroupDetailTV.m
//  AmosSportDiary
//
//  Created by Amos Wu on 15/10/4.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "GroupDetailTV.h"
#import "GroupDetailCell.h"
#import "GroupStore.h"
#import "CommonMarco.h"
#import "NewEvevtViewController.h"

static NSString * const YKSummaryCellReuseId = @"GroupDetailCell";

@interface GroupDetailTV ()<UITableViewDataSource, UITableViewDelegate>
{
    NSInteger selectedSection; ///<点选的行数
    NSMutableArray *allTableDataArray;
    Event *tempEvent;
}
@end

@implementation GroupDetailTV

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = _navTitle;
    UINib *nib = [UINib nibWithNibName:YKSummaryCellReuseId bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:YKSummaryCellReuseId];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backToPresentPage)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    //长按移动cell顺序
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:longPress];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *allEventsByType = [[NSMutableDictionary alloc] initWithDictionary:[[GroupStore sharedStore] allItems] copyItems:NO];
    _allDataArray = [allEventsByType[_belong][_navTitle] copy];
    [self initTheData];
    
    [self.tableView reloadData];
}

- (void)initTheData
{
    tempEvent = nil;
    if (_allDataArray) {
        allTableDataArray = [[NSMutableArray alloc] initWithArray:_allDataArray];
    }
}

- (void)backToPresentPage
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)prepareForSegue:(nonnull UIStoryboardSegue *)segue sender:(nullable id)sender
{
    //    NSLog(@"%@", NSStringFromSelector(_cmd));
    if ([segue.identifier isEqualToString:@"newGroupEvent"]) {
        
        NewEvevtViewController *mvc = (NewEvevtViewController *)segue.destinationViewController;
        Event *event = [[GroupStore sharedStore] createItem];
        
        mvc.event = tempEvent? tempEvent : event;
        mvc.createNewEvent = tempEvent ? NO : YES;
        mvc.groupEdit = YES;
        mvc.belong = self.belong;
        mvc.groupName = self.navTitle;
//        mvc.event.sportType = self.belong;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (allTableDataArray.count > 0) {
        return allTableDataArray.count;
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:YKSummaryCellReuseId];
    Event *event = allTableDataArray[indexPath.row];
    cell.event = event;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

//设置滑动后出现的选项
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //删除的方法
    UITableViewRowAction *deleteAction = [UITableViewRowAction
                                          rowActionWithStyle:UITableViewRowActionStyleDestructive
                                          title:Local(@"Delete")
          handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
              Event *event = allTableDataArray[indexPath.row];
              [allTableDataArray removeObjectAtIndex:indexPath.row];
              [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
              
              [[GroupStore sharedStore] removeItemInGroup:event belong:_belong groupName:_navTitle];
              //储存数据
              BOOL success = [[GroupStore sharedStore] saveGroupData];
              if (DeBugMode) {
                  if (success) {
                      NSLog(@"Group数据 - 删除item后，储存数据成功");
                  }else{
                      NSLog(@"Group数据 - 删除item后，储存数据失败！");
                  }}
                                          }];
    
    //修改内容的方法
    UITableViewRowAction *editAction = [UITableViewRowAction
                                        rowActionWithStyle:UITableViewRowActionStyleNormal
                                        title:Local(@"Edit")
            handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
                tempEvent = allTableDataArray[indexPath.row];
                
                [self performSegueWithIdentifier:@"newGroupEvent" sender:self];
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                                        }];
    editAction.backgroundColor = [UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1];
    
    return @[deleteAction, editAction]; //与实际显示的顺序相反
}

- (IBAction)longPressGestureRecognized:(id)sender {
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshoFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    cell.alpha = 0.0;
                    
                } completion:^(BOOL finished) {
                    
                    cell.hidden = YES;
                    
                }];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
                // ... update data source.
                [[GroupStore sharedStore] moveItemAtIndex:indexPath.row toIndex:sourceIndexPath.row belong:_belong groupName:_navTitle];
                
                // ... move the rows.
                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            break;
        }
            
        default: {
            // Clean up.
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            cell.hidden = NO;
            cell.alpha = 0.0;
            
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                cell.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
                
                //储存数据
                BOOL success = [[GroupStore sharedStore] saveGroupData];
                if (DeBugMode) {
                    if (success) {
                        NSLog(@"Group数据 - 移动item后，储存数据成功");
                    }else{
                        NSLog(@"Group数据 - 移动item后，储存数据失败！");
                    }}
                
            }];
            
            break;
        }
    }
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
