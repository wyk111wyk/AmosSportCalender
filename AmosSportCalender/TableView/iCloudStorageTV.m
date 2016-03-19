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
    NSString *tempFileName1 = [NSString stringWithFormat:@"默认运动记录"];
    if (userName.length > 0) {
        tempFileName1 = [NSString stringWithFormat:@"%@的运动记录", userName];
    }
    NSString *dateStr = [[ASBaseManage dateFormatterForDMY] stringFromDate:[NSDate date]];
        
    NSString *uploadFileName = [NSString stringWithFormat:@"%@_%@", tempFileName1, dateStr];
    
    [KVNProgress showWithStatus:@"正在备份数据..."];
    //储存文件到iCloud
    [[iCloud sharedCloud] saveAndCloseDocumentWithName:uploadFileName withContent:uploadFile completion:^(UIDocument *cloudDocument, NSData *documentData, NSError *error) {
        if (!error) {
            NSLog(@"iCloud Document: %@ 储存成功", cloudDocument.fileURL.lastPathComponent);
            [KVNProgress showSuccessWithStatus:@"数据备份成功！"];
        } else {
            NSLog(@"新建iCloud备份失败: %@", error);
            [KVNProgress showErrorWithStatus:@"数据备份失败！"];
        }
    }];
}

#pragma mark - Pull to refresh

- (void)initTheRefresh
{
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor lightGrayColor];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉进行刷新"];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

-(void)refreshView:(UIRefreshControl *)refresh
{
    if (refreshControl.refreshing) {
        refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"正在进行刷新..."];
        [self performSelector:@selector(handleData) withObject:nil afterDelay:2];
    }
}

//下拉刷新的结果
-(void)handleData
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm:ss a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"上次刷新时间: %@", [formatter stringFromDate:[NSDate date]]];
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
    NSString *title = [NSString stringWithFormat:@"恢复所有数据为\n(%@)？", _fileNameLists[indexPath.row]];
    NSString *subTitle = [NSString stringWithFormat:@"这将覆盖现有用户(%@)的所有数据！", [[SettingStore sharedSetting] userName]];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:subTitle
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [KVNProgress showWithStatus:@"开始还原数据..."];
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
                [KVNProgress showSuccessWithStatus:@"数据还原成功..."];
            } else {
                NSLog(@"从iCloud取回数据发生错误: %@", error);
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertForNotHaveiCloud
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"出了个小问题"
                                                                   message:@"您并没有设置iCloud，所以无法使用iCloud进行数据备份"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    [alert addAction:[UIAlertAction actionWithTitle:@"跳转到设置"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
            //打开设置
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root"]];
                                               
                                            }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSDateFormatter *)dateFormatterDisplay
{
    static NSDateFormatter *dateFormatterDisplay;
    if(!dateFormatterDisplay){
        dateFormatterDisplay = [NSDateFormatter new];
        dateFormatterDisplay.dateFormat = @"yyyy年MM月dd日 EEEE H:mm";
        [dateFormatterDisplay setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    }
    
    return dateFormatterDisplay;
}
@end
