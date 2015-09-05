//
//  AppDelegate.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/7/3.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//
#import <PgySDK/PgyManager.h>
#import "CommonMarco.h"

#import "AppDelegate.h"
#import "ViewController.h"
#import "EventStore.h"
#import "SettingStore.h"
#import "PersonInfoStore.h"
#import "DMPasscode.h"
#import "LeftMenuViewController.h"
#import "RESideMenu.h"

#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "MobClick.h"
#import "UMFeedback.h"
#import "UMOpus.h"

@interface AppDelegate ()<RESideMenuDelegate, WXApiDelegate>
@end

NSArray *sportTypes;

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    NSLog(@"application didFinishLaunchingWithOptions");
    
    [self registerTherdSDK];
    
    //重绘状态栏
    [application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

    SettingStore *setting = [SettingStore sharedSetting];
    setting.passWordOfFingerprint = NO;
    
    //取消所有通知
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    //假如第一次启动软件，则创建运动项目类
    [self createAllSportTypeArray];
    
    //初始化侧边栏
    [self initNavAndDrawer];
    
    //开机画面的显示时间
    [NSThread sleepForTimeInterval:1.f];
    
    return YES;
}

- (void)initNavAndDrawer
{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    LeftMenuViewController *leftMenu = [[LeftMenuViewController alloc]init];
    
    RESideMenu *drawer = [[RESideMenu alloc] initWithContentViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"nav"]
                                                    leftMenuViewController:leftMenu
                                                   rightMenuViewController:nil];
    
    drawer.delegate = self;
    drawer.panGestureEnabled = YES;
    drawer.panFromEdge = YES;
    drawer.parallaxEnabled = YES;
    drawer.menuPreferredStatusBarStyle = UIStatusBarStyleLightContent;
    drawer.bouncesHorizontally = NO;
    
    drawer.fadeMenuView = YES;
    drawer.scaleBackgroundImageView = YES;
    drawer.scaleContentView = YES;
    drawer.scaleMenuView = YES;
    drawer.contentViewShadowEnabled = YES;
    drawer.contentViewShadowColor = [UIColor colorWithWhite:0.95 alpha:1];
    
    drawer.contentViewInPortraitOffsetCenterX = 0;
    
    self.window.rootViewController = drawer;
    [self.window makeKeyAndVisible];
}

- (void)createAllSportTypeArray
{
    //获取Library目录
    /*  1. document是那些暴露给用户的数据文件，用户可见，可读写；
     2. library目录是App替用户管理的数据文件，对用户透明。所以，那些用户显式访问不到的文件要存储到这里，可读写。*/
    NSFileManager * defaultManager = [NSFileManager defaultManager];
    NSURL * documentPath = [[defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]firstObject];
    
    //新建一个目录存放该文件（如目录不存在，则新建一个）
    NSString * fileContainFloder = [documentPath.path stringByAppendingPathComponent:@"sportEventData"];
    
    //用函数判断该文件夹是否存在（不存在就写入会直接崩溃）
    BOOL isDic = YES;
    if (![defaultManager fileExistsAtPath:fileContainFloder isDirectory:&isDic]) // isDir判断是否为文件夹
    {   // 假如该文件夹不存在，直接新建一个
        
        [defaultManager createDirectoryAtPath:fileContainFloder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //设置创建的文件的目录和名字
    NSString * fileSavePath = [fileContainFloder stringByAppendingPathComponent:@"sportTypeArray.plist"];
    
    BOOL isDic1 = NO;
    if (![defaultManager fileExistsAtPath:fileSavePath isDirectory:&isDic1]) {
        
        NSArray *sportTypes = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sportTypes" ofType:@"plist"]];
        
        BOOL successWrited = [sportTypes writeToFile:fileSavePath atomically:YES];
        
        if (successWrited) {
            NSLog(@"已写入plist数据！");
        }else{
            NSLog(@"写入失败！");
        }
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([[url absoluteString] hasPrefix:@"tencent"]) {
        
        return [TencentOAuth HandleOpenURL:url];
        
    }
    
    return  [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[url absoluteString] hasPrefix:@"tencent"]) {
        
        return [TencentOAuth HandleOpenURL:url];
        
    }
    
    return  [WXApi handleOpenURL:url delegate:self];
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    SettingStore *setting = [SettingStore sharedSetting];
    PersonInfoStore *personal = [PersonInfoStore sharedSetting];
    
    //注册五天不使用的本地通知
    UILocalNotification *localNotification = UILocalNotification.new;
    
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5*24*60*60];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    
    int i = arc4random() % 100;
    NSString *str = @"又五天没有运动了，恭喜您又长了1.%i斤肉~";
    if (personal.name.length > 0) {
        str = [NSString stringWithFormat:@"%@，又五天没有运动了，恭喜您又长了1.%i斤肉~", personal.name, i];
    }
    localNotification.alertBody = str;
    localNotification.alertAction = NSLocalizedString(@"立即开始计划运动吧！", nil);
    localNotification.soundName= UILocalNotificationDefaultSoundName;
    
    // 设定通知的userInfo，用来标识该通知:不会
    
    [application scheduleLocalNotification:localNotification];
    
    if (!setting.iconBadgeNumber) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    
    //储存所有用户数据
    BOOL success = [[EventStore sharedStore] saveChanges];
    if (success) {
        NSLog(@"退出程序后,进行了数据本地储存");
    }else{
        NSLog(@"退出程序后的储存失败！");
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    SettingStore *setting = [SettingStore sharedSetting];
    setting.passWordOfFingerprint = NO;
    NSLog(@"TouchID 已打开");
    
    [self saveContext];
}

- (void)registerTherdSDK
{
    //注册友盟的API
    [MobClick startWithAppkey:YouMen_AppKey reportPolicy:BATCH  channelId:@""];
    
    NSDictionary *infoDictionary =[[NSBundle mainBundle]infoDictionary];
    NSString *infoStr = [NSString stringWithFormat:@"V %@.%@", [infoDictionary objectForKey:@"CFBundleShortVersionString"], [infoDictionary objectForKey:@"CFBundleVersion"]];
    [MobClick setAppVersion:infoStr]; //app版本设置
    [MobClick setEncryptEnabled:YES]; //日志传输加密
    [MobClick setLogEnabled:NO]; //是否开启调试日志
    [MobClick setCrashReportEnabled:YES]; //是否报告崩溃记录
    
    //友盟的用户反馈功能
    [UMFeedback setAppkey:YouMen_AppKey];
    [UMOpus setAudioEnable:YES]; //开启反馈时的语音功能
    
    //蒲公英SDK提供的方法
    [[PgyManager sharedPgyManager] startManagerWithAppId:PGY_APP_ID];
    [[PgyManager sharedPgyManager] setEnableFeedback:NO];
    [[PgyManager sharedPgyManager] setEnableDebugLog:NO]; //是否开启调试日志
    
    //向微信注册
    BOOL weChatSuccess = [WXApi registerApp:WeiXin_AppKey withDescription:@"Amos运动日记"];
    NSLog(@"%@", weChatSuccess ? @"weChat-微信注册成功" : @"register Fail");
    
    //注册微博
//    [WeiboSDK enableDebugMode:YES];
//    BOOL weiBoSuccess = [WeiboSDK registerApp:APP_KEY_WEIBO];
//    NSLog(@"%@", weiBoSuccess ? @"sina-微博注册成功" : @"微博Fail");
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.AKSocialLab.AmosSportCalender" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AmosSportCalender" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"AmosSportCalender.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
