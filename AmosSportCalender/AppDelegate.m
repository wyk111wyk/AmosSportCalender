//
//  AppDelegate.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/7/3.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//
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
#import "MobClick.h"
#import "UMFeedback.h"
#import "UMOpus.h"

@interface AppDelegate ()<RESideMenuDelegate, WXApiDelegate>
@end

NSArray *sportTypes;

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (DeBugMode) {
    NSLog(@"application didFinishLaunchingWithOptions");
    }
    
    [self registerTherdSDK];
    
    //重绘状态栏
    [application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

    SettingStore *setting = [SettingStore sharedSetting];
    setting.passWordOfFingerprint = NO;
    
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
        
        if (DeBugMode) {
        if (successWrited) {
            NSLog(@"已写入plist数据！");
        }else{
            NSLog(@"写入失败！");
        }}
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return  [WXApi handleOpenURL:url delegate:self];
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    SettingStore *setting = [SettingStore sharedSetting];
    PersonInfoStore *personal = [PersonInfoStore sharedSetting];
    
    if (setting.alertForSport) {

    //注册五天不使用的本地通知
        if (DeBugMode) {
        NSLog(@"有%@个待提醒", @([[UIApplication sharedApplication] scheduledLocalNotifications].count));
        }
        
        if ([[UIApplication sharedApplication] scheduledLocalNotifications].count < 1) {
        
            UILocalNotification *localNotification = UILocalNotification.new;
            
            NSInteger ii = setting.alertForDays;
            
            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:ii*24*60*60];
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            
            float i = arc4random() % 100;
                i = (i+100)/100 * (int)ii/5;
            NSString *str = [NSString stringWithFormat:@"%@天没有运动了，恭喜您又长了%.2f斤肉~赶快来做一个运动计划吧！", @(ii), i];
            if (personal.name.length > 0) {
                str = [NSString stringWithFormat:@"%@，%@天没有运动了，恭喜您又长了%.2f斤肉~赶快来做一个运动计划吧！", personal.name, @(ii), i];
                }
            localNotification.alertBody = str;
            localNotification.alertAction = NSLocalizedString(@"立即开始计划运动吧！", nil);
            localNotification.soundName= UILocalNotificationDefaultSoundName;
            
            // 设定通知的userInfo，用来标识该通知:不会
            [application scheduleLocalNotification:localNotification];
        }
        
    }
    
    if (!setting.iconBadgeNumber) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    
    //储存所有用户数据
    BOOL success = [[EventStore sharedStore] saveChanges];
    
    if (DeBugMode) {
    if (success) {
        NSLog(@"退出程序后,进行了数据本地储存");
    }else{
        NSLog(@"退出程序后的储存失败！");
    }}
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
    
    if (DeBugMode) {
    NSLog(@"TouchID 已打开");
    }
}

- (void)registerTherdSDK
{
    //注册友盟的API
    [MobClick startWithAppkey:YouMen_AppKey reportPolicy:BATCH  channelId:@""];
    
    NSDictionary *infoDictionary =[[NSBundle mainBundle]infoDictionary];
    NSString *infoStr = [NSString stringWithFormat:@"%@.%@", [infoDictionary objectForKey:@"CFBundleShortVersionString"], [infoDictionary objectForKey:@"CFBundleVersion"]];
    [MobClick setAppVersion:infoStr]; //app版本设置
    [MobClick setEncryptEnabled:YES]; //日志传输加密
    [MobClick setLogEnabled:NO]; //是否开启调试日志
    [MobClick setCrashReportEnabled:YES]; //是否报告崩溃记录
    
    //友盟的用户反馈功能
    [UMFeedback setAppkey:YouMen_AppKey];
    [UMOpus setAudioEnable:YES]; //开启反馈时的语音功能
    
    //向微信注册
    BOOL weChatSuccess = [WXApi registerApp:WeiXin_AppKey withDescription:@"Amos运动日记"];
    
    if (DeBugMode) {
        NSLog(@"%@", weChatSuccess ? @"weChat-微信注册成功" : @"weChat-微信注册Fail");}
    
    //注册微博
//    [WeiboSDK enableDebugMode:YES];
//    BOOL weiBoSuccess = [WeiboSDK registerApp:APP_KEY_WEIBO];
//    NSLog(@"%@", weiBoSuccess ? @"sina-微博注册成功" : @"微博Fail");
}

@end
