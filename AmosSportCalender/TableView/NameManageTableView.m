//
//  NameManageTableView.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/6.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "NameManageTableView.h"
#import "NameManageTVCell.h"

static NSString* const typeManageCellReuseId = @"sportNameManageCell";

@interface NameManageTableView ()<UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong)NSMutableArray *sportNameTemps;
@property (nonatomic)unsigned long index;
@property (nonatomic, strong)NSString *editedText;
@property (nonatomic, strong)NSArray *buttonArray;


@property (nonatomic ,strong)NameManageTVCell *cell;

@end

@implementation NameManageTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.allowsSelection = NO;
    self.tableView.editing = YES;
    self.sportNameTemps = [[NSMutableArray alloc] initWithArray:self.sportNames];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewSportName)];
    UIBarButtonItem *sortButton = [[UIBarButtonItem alloc] initWithTitle:@"排序" style:UIBarButtonItemStylePlain target:self action:@selector(sortTheOrder)];
    self.buttonArray = [[NSArray alloc] initWithObjects:addButton, sortButton, nil];
    
    self.navigationItem.rightBarButtonItems = self.buttonArray;
    self.navigationItem.title = [NSString stringWithFormat: @"%@ - 编辑", self.sportType];
    
    //长按移动cell顺序
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
//    [self.tableView addGestureRecognizer:longPress];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addNewSportName {
    
    [self actionAlert];
}

- (IBAction)sortTheOrder {
    
    [self alertForSort];
}


- (void)actionAlert
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"新建"
                                                                   message:@"请在输入名称后确认"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请在此输入运动名称";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"选填补充信息";
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确认"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
    UITextField *sportNameField = alert.textFields[0];
    UITextField *addtionalField = alert.textFields[1];
    NSString *str;
    if (![addtionalField.text isEqualToString:@""]) {
    str = [NSString stringWithFormat:@"%@（%@）", sportNameField.text, addtionalField.text];
    }else{
        str = [NSString stringWithFormat:@"%@", sportNameField.text];
    }
    [self.sportNameTemps addObject:str];
    [self.tableView reloadData];
    [self saveTheDate];
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {
                                                
                                            }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertForSort
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"重新排序"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"按A~Z进行排序"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
        NSArray *result = [self.sportNameTemps sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//            NSLog(@"%@ ~ %@", obj1, obj2);
            return [obj1 compare:obj2];
        }];
        self.sportNameTemps = [[NSMutableArray alloc] initWithArray:result];
        [self.tableView reloadData];
        [self saveTheDate];
                                                }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {
                                                
                                            }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - textfield

- (void)textFieldDidBeginEditing:(nonnull UITextField *)textField
{
//    NSLog(@"contain is %@", textField.text);
    self.index = [self.sportNameTemps indexOfObject:textField.text];
//    NSLog(@"contain index is %lu", self.index);
    
    self.navigationItem.rightBarButtonItems = nil;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(changeTheName)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    textField.textColor = [UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:0.6];
}

- (void)textFieldDidEndEditing:(nonnull UITextField *)textField
{
    self.editedText = textField.text;
    textField.textColor = [UIColor blackColor];
    
//    NSLog(@"After end editing, now text is %@", textField.text);
}

- (BOOL)textFieldShouldReturn:(nonnull UITextField *)textField
{
    [self.sportNameTemps replaceObjectAtIndex:self.index withObject:textField.text];
    
    [textField resignFirstResponder];
    self.navigationItem.rightBarButtonItems = self.buttonArray;
    
    [self saveTheDate];
    return YES;
}

- (void)changeTheName
{
//    NSLog(@"click done, text is %@", self.editedText);
    
    [self.view endEditing:YES];
    self.navigationItem.rightBarButtonItems = self.buttonArray;
    [self.sportNameTemps replaceObjectAtIndex:self.index withObject:self.editedText];
    
    [self saveTheDate];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sportNameTemps.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    self.cell = [tableView dequeueReusableCellWithIdentifier:typeManageCellReuseId forIndexPath:indexPath];
    
    self.cell.sportNameTextField.text = self.sportNameTemps[indexPath.row];
    [self.cell.sportNameTextField sizeToFit];
    
    return self.cell;
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSLog(@"did select Row %@", indexPath);
}

#pragma mark - TableView的操作

//tableView可将其置于编辑模式
-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

//当点击”Delete”按钮或者”加号”按钮时，发送实际执行的代码
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //删除的方法
    UITableViewRowAction *deleteAction = [UITableViewRowAction
                                          rowActionWithStyle:UITableViewRowActionStyleDestructive
                                          title:@"删除"
                                          handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
          [self.sportNameTemps removeObjectAtIndex:indexPath.row];
          
          //删除表格中的相应行
          [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
          
          [self saveTheDate];
                                          }];

    return @[deleteAction]; //与实际显示的顺序相反
}

//移动行方法
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [self moveItemAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}

- (void)moveItemAtIndex:(NSUInteger)fromIndex
               toIndex :(NSUInteger)toIndex
{
    if (fromIndex == toIndex) {
        return;
    }
    NSString *sportName = self.sportNameTemps[fromIndex];

    [self.sportNameTemps removeObjectAtIndex:fromIndex];
    [self.sportNameTemps insertObject:sportName atIndex:toIndex];
    
    [self saveTheDate];
}

#pragma mark - 长按移动cell顺序

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
                [self moveItemAtIndex:sourceIndexPath.row toIndex:indexPath.row];
                
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
                
            }];
            
            break;
        }
    }
}

#pragma mark - Helper methods

/** @brief Returns a customized snapshot of a given view. */
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

#pragma mark - saveTheData

- (void)saveTheDate
{
    NSFileManager * defaultManager = [NSFileManager defaultManager];
    NSURL * documentPath = [[defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]firstObject];
    NSString * fileContainFloder = [documentPath.path stringByAppendingPathComponent:@"sportEventData"];
    NSString * fileSavePath = [fileContainFloder stringByAppendingPathComponent:@"sportTypeArray.plist"];
    NSArray * array = [NSArray arrayWithContentsOfFile:fileSavePath];
    
    NSMutableArray *MuSportTypes = [[NSMutableArray alloc] initWithArray:array];
    
    [[[MuSportTypes objectAtIndex:self.indexRow] objectForKey:@"sportName"] removeAllObjects];
    [[[MuSportTypes objectAtIndex:self.indexRow] objectForKey:@"sportName"] addObjectsFromArray:self.sportNameTemps];
    
    BOOL successWrited = [MuSportTypes writeToFile:fileSavePath atomically:YES];
    
    if (successWrited) {
        NSLog(@"已更新运动项目plist数据！");
    }else{
        NSLog(@"更新失败！");
    }
}
@end
