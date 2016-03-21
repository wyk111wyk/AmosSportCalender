//
//  iCloudStorageTV.m
//  AmosSportDiary
//
//  Created by Amos Wu on 15/8/29.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "iCloudStorageTV.h"
#import "ConflictTV.h"
#import "JKDBHelper.h"
#import "CommonMarco.h"

static NSString* const iCloudCellReuseId = @"icloudCell";

@interface iCloudStorageTV ()<UITableViewDataSource, UITableViewDelegate>
{
    UIRefreshControl *refreshControl;
}

//@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *fileLists; ///<所有的文件
@property (nonatomic, strong)NSMutableArray *fileNameLists; ///<所有的文件名

@end

@implementation iCloudStorageTV

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //保存数据到iCloud
    [[iCloud sharedCloud] setDelegate:self]; // Set this if you plan to use the delegate
    [[iCloud sharedCloud] setVerboseLogging:NO];
    //注册iCloud
    [[iCloud sharedCloud] setupiCloudDocumentSyncWithUbiquityContainer:nil];
    
    BOOL cloudIsAvailable = [[iCloud sharedCloud] checkCloudAvailability];
    if (cloudIsAvailable) {
        NSLog(@"iCloud好用的");
    }else{
        [self alertForNotHaveiCloud];
    }
    
    //初始化各种数据
    if (!_fileLists) {
        _fileLists = [NSMutableArray array];
    }
    if (!_fileNameLists) {
        _fileNameLists = [NSMutableArray array];
    }
    
    //初始化下拉刷新
    [self initTheRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//储存文件到iCloud
- (IBAction)addNewDataToiCloud:(UIBarButtonItem *)sender {
    NSString *userDataName = [[SettingStore sharedSetting] userDataName];
    NSString *path = [JKDBHelper dbPathWithDirectoryName:userDataName];
    NSData *uploadFile = [NSData dataWithContentsOfFile:path];
    
    NSString *userName = [[SettingStore sharedSetting] userName];
    NSString *tempFileName1 = [NSString stringWithFormat:Local(@"Default sport record")];
    if (userName.length > 0) {
        tempFileName1 = [NSString stringWithFormat:Local(@"%@’s sport record"), userName];
    }
    NSString *dateStr = [[ASBaseManage dateFormatterForDMY] stringFromDate:[NSDate date]];
        
    NSString *uploadFileName = [NSString stringWithFormat:@"%@_%@", tempFileName1, dateStr];
    
    [KVNProgress showWithStatus:Local(@"Bucking up data...")];
    //储存文件到iCloud
    [[iCloud sharedCloud] saveAndCloseDocumentWithName:uploadFileName withContent:uploadFile completion:^(UIDocument *cloudDocument, NSData *documentData, NSError *error) {
        if (!error) {
            NSLog(@"iCloud Document: %@ 储存成功", cloudDocument.fileURL.lastPathComponent);
            [KVNProgress showSuccessWithStatus:Local(@"Back up success！")];
        } else {
            NSLog(@"新建iCloud备份失败: %@", error);
            [KVNProgress showErrorWithStatus:Local(@"Back up fail！")];
        }
    }];
}

#pragma mark - Pull to refresh

- (void)initTheRefresh
{
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor lightGrayColor];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:Local(@"Pull to refresh")];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

-(void)refreshView:(UIRefreshControl *)refresh
{
    if (refreshControl.refreshing) {
        refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:Local(@"Refreshing...")];
        [self performSelector:@selector(handleData) withObject:nil afterDelay:2];
    }
}

//下拉刷新的结果
-(void)handleData
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm:ss a"];
    NSString *lastUpdated = [NSString stringWithFormat:Local(@"Last time refresh: %@"), [formatter stringFromDate:[NSDate date]]];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    
    [refreshControl endRefreshing];
    [[iCloud sharedCloud] updateFiles];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fileNameLists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iCloudCellReuseId forIndexPath:indexPath];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = CellBackgoundColor;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    NSString *fileName = _fileNameLists[indexPath.row];
    //Detail的信息
    NSNumber *filesize = [[iCloud sharedCloud] fileSize:fileName];
    NSDate *fileDate = [[iCloud sharedCloud] fileModifiedDate:fileName];
    NSString *fileDateStr = [[self dateFormatterDisplay] stringFromDate:fileDate];
    
    cell.textLabel.text = fileName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%.1f Kb)",fileDateStr, [filesize floatValue]/1024];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self AlertForRecover:indexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [[iCloud sharedCloud] deleteDocumentWithName:[_fileNameLists objectAtIndex:indexPath.row] completion:^(NSError *error) {
            if (error) {
                NSLog(@"删除iCloud记录失败: %@", error);
            } else {
                [[iCloud sharedCloud] updateFiles];
                
                [_fileNameLists removeObjectAtIndex:indexPath.row];
                [_fileLists removeObjectAtIndex:indexPath.row];
                
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - iCloud

- (void)iCloudFilesDidChange:(NSMutableArray *)files withNewFileNames:(NSMutableArray *)fileNames {
    _fileNameLists = fileNames; // A list of the file names
    _fileLists = files;
    
    [refreshControl endRefreshing];
    [self.tableView reloadData];
}

#pragma mark - Common

- (void)AlertForRecover:(NSIndexPath *)indexPath
{
    NSString *title = [NSString stringWithFormat:Local(@"Restore all data to \n(%@)？"), _fileNameLists[indexPath.row]];
    NSString *subTitle = [NSString stringWithFormat:Local(@"It’s going to clear all (%@)’s data！" ), [[SettingStore sharedSetting] userName]];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:subTitle
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Okay") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [KVNProgress showWithStatus:Local(@"Start to restore...")];
        [[iCloud sharedCloud] retrieveCloudDocumentWithName:[_fileNameLists objectAtIndex:indexPath.row] completion:^(UIDocument *cloudDocument, NSData *documentData, NSError *error) {
            if (!error) {
                
                NSString *fileTitle = cloudDocument.fileURL.lastPathComponent;
                
                [[iCloud sharedCloud] documentStateForFile:fileTitle completion:^(UIDocumentState *documentState, NSString *userReadableDocumentState, NSError *error) {
                    if (!error) {
                        if (*documentState == UIDocumentStateInConflict) {
                            ConflictTV *conTV = [[ConflictTV alloc] init];
                            
                            [self presentViewController:conTV animated:YES completion:nil];
                            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                        }
                    } else {
                        NSLog(@"获取iCloud文件状态时发生错误: %@", error);
                    }
                }];
                
                NSString *userDataName = [[SettingStore sharedSetting] userDataName];
                NSString *path = [JKDBHelper dbPathWithDirectoryName:userDataName];
                
                [documentData writeToFile:path atomically:YES];
                
                [[JKDBHelper shareInstance] changeDBWithDirectoryName:userDataName];
                [[TMCache sharedCache] removeAllObjects];
                [KVNProgress showSuccessWithStatus:Local(@"Restore data success！")];
            } else {
                NSLog(@"从iCloud取回数据发生错误: %@", error);
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertForNotHaveiCloud
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:Local(@"A little problem")
                                                                   message:Local(@"You have not set iCloud，iCloud cannot work")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Okay")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Jump to setting")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
            //打开设置
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=CASTLE"]];
                                               
                                            }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSDateFormatter *)dateFormatterDisplay
{
    static NSDateFormatter *dateFormatterDisplay;
    if(!dateFormatterDisplay){
        dateFormatterDisplay = [NSDateFormatter new];
        dateFormatterDisplay.dateFormat = Local(@"yyyy-MM-dd EEEE H:mm");
    }
    
    return dateFormatterDisplay;
}
@end
