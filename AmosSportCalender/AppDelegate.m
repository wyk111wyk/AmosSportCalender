//
//  AppDelegate.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/7/3.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//
#import <Bugtags/Bugtags.h>
#import "CommonMarco.h"

#import "AppDelegate.h"
#import "ViewController.h"
#import "SettingStore.h"
#import "DMPasscode.h"
#import "LeftMenuViewController.h"
#import "RESideMenu.h"

#import "WXApi.h"
#import "MobClick.h"

@interface AppDelegate ()<RESideMenuDelegate, WXApiDelegate>
@end

NSArray *sportTypes;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self registerTherdSDK];
    //导入初始数据
    [[ASDataManage sharedManage] inputFirstData];
    
    //初始化侧边栏
    [self initNavAndDrawer];
    
    //Touch ID
    [[ASBaseManage sharedManage] UseTouchIDForSecurity];
    
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
    
    if (setting.alertForSport) {
        
        if ([[UIApplication sharedApplication] scheduledLocalNotifications].count < 1) {
        
            UILocalNotification *localNotification = UILocalNotification.new;
            
            NSInteger ii = setting.alertForDays;
            
            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:ii*24*60*60];
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            
            float i = arc4random() % 100;
                i = (i+100)/100 * (int)ii/5;
            NSString *str = [NSString stringWithFormat:Local(@"It’s been %@ days，sorry to say that you grow %.2f more fat~ Come on and make a plan！"), @(ii), i];
            if (setting.userName.length > 0) {
                str = [NSString stringWithFormat:Local(@"%@，It’s been %@ days，sorry to say that you grow %.2f more fat~ Come on and make a plan！" ), setting.userName, @(ii), i];
                }
            localNotification.alertBody = str;
            localNotification.alertAction = Local(@"Start Now!");
            localNotification.soundName= UILocalNotificationDefaultSoundName;
            
            // 设定通知的userInfo，用来标识该通知:不会
            [application scheduleLocalNotification:localNotification];
        }
        
    }
    
    if (!setting.iconBadgeNumber) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
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
    [MobClick setCrashReportEnabled:NO]; //是否报告崩溃记录

    //BugTags
    BugtagsOptions *options = [[BugtagsOptions alloc] init];
    options.trackingCrashes = YES;        // 是否收集闪退，联机 Debug 状态下默认 NO，其它情况默认 YES
    options.trackingUserSteps = YES;      // 是否跟踪用户操作步骤，默认 YES
    options.trackingConsoleLog = YES;     // 是否收集控制台日志，默认 YES
    options.trackingUserLocation = YES;   // 是否获取位置，默认 YES
    options.crashWithScreenshot = YES;    // 收集闪退是否附带截图，默认 YES
    [Bugtags startWithAppKey:Bugtags_AppKey invocationEvent:BTGInvocationEventShake options:options];
    
    //向微信注册
    [WXApi registerApp:WeiXin_AppKey withDescription:@"Amos运动日记"];

    //注册微博
//    [WeiboSDK enableDebugMode:YES];
//    BOOL weiBoSuccess = [WeiboSDK registerApp:APP_KEY_WEIBO];
//    NSLog(@"%@", weiBoSuccess ? @"sina-微博注册成功" : @"微博Fail");
}

@end
