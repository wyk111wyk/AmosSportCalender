//
//  iCloudStorageTV.m
//  AmosSportDiary
//
//  Created by Amos Wu on 15/8/29.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "iCloudStorageTV.h"
#import "PersonInfoStore.h"
#import "ConflictTV.h"
#import "EventStore.h"

static NSString* const iCloudCellReuseId = @"icloudCell";

@interface iCloudStorageTV ()<UITableViewDataSource, UITableViewDelegate>
{
    UIRefreshControl *refreshControl;
}

//@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *fileLists;
@property (nonatomic, strong)NSMutableArray *fileNameLists;

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

- (IBAction)addNewDataToiCloud:(UIBarButtonItem *)sender {
    NSString *path = [self itemArchivePath];
    NSData *uploadFile = [NSData dataWithContentsOfFile:path];
    
    PersonInfoStore *personal = [PersonInfoStore sharedSetting];
    
    NSString *tempFileName1 = [NSString stringWithFormat:@"你的运动记录"];
    if (personal.name.length > 0) {
        tempFileName1 = [NSString stringWithFormat:@"%@的运动记录", personal.name];
    }
    
    NSString *tempFileName = @"";
    
    for (int i = 0; i <= _fileNameLists.count; i++) {

        tempFileName = [NSString stringWithFormat:@"%@-%i", tempFileName1, i+1];
        
        //检查名字是否重复
        BOOL fileExists = [_fileNameLists containsObject:tempFileName];
        if (fileExists == NO) {
            break;
        }
        
    }
        
    NSString *uploadFileName = tempFileName;
    
    //储存文件到iCloud
    [[iCloud sharedCloud] saveAndCloseDocumentWithName:uploadFileName withContent:uploadFile completion:^(UIDocument *cloudDocument, NSData *documentData, NSError *error) {
        if (!error) {
            NSLog(@"iCloud Document: %@ 储存成功", cloudDocument.fileURL.lastPathComponent);
        } else {
            NSLog(@"新建iCloud备份失败: %@", error);
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
    // Get the query results
//    NSLog(@"Files: %@", fileNames);
    
    _fileNameLists = fileNames; // A list of the file names
    _fileLists = files;
    
    [refreshControl endRefreshing];
    [self.tableView reloadData];
}

//- (void)refreshCloudList {
//    [[iCloud sharedCloud] updateFiles];
//}

#pragma mark - Common

- (void)AlertForRecover:(NSIndexPath *)indexPath
{
    NSString *title = [NSString stringWithFormat:@"确定要恢复所有数据为\n(%@)？", _fileNameLists[indexPath.row]];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:@"这将导致现有的用户数据被清空！"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
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
                
                NSString *path = [self itemArchivePath];
                NSMutableDictionary *privateEvents = [NSKeyedUnarchiver unarchiveObjectWithData:documentData];
                
                BOOL success = [NSKeyedArchiver archiveRootObject:privateEvents toFile:path];
                if (success) {
                    NSLog(@"成功从iCloud取回了数据，且覆盖成功");
                }else{
                    NSLog(@"从iCloud取回数据，但本地化失败！");
                }
                
                [[EventStore sharedStore] updateAllData];
                
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

- (NSString *)itemArchivePath
{
    //通过该方法获取Doc目录的全路径，三个实参：（指定目录）
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories firstObject];
    
    //最终获取了储存的指定目录
    return [documentDirectory stringByAppendingPathComponent:@"event.archive"];
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
