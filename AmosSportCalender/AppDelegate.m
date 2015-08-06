//
//  AppDelegate.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/7/3.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "AppDelegate.h"
#import "MMDrawerController.h"
#import "ViewController.h"
#import "EventStore.h"

@interface AppDelegate ()
@end

NSArray *sportTypes;

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self createAllSportTypeArray];
    
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    MMDrawerController *drawer = [[MMDrawerController alloc] initWithCenterViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"nav"] leftDrawerViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"menunav"]];
    
    [drawer setShowsShadow:YES];
    [drawer setMaximumLeftDrawerWidth:130.0];
    [drawer setOpenDrawerGestureModeMask:MMOpenDrawerGestureModePanningNavigationBar];
    [drawer setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    self.window.rootViewController = drawer;
    [self.window makeKeyAndVisible];
    
    return YES;
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

        //设置创建的文件的目录和名字
        NSString * fileSavePath = [fileContainFloder stringByAppendingPathComponent:@"sportTypeArray.plist"];
        
        NSArray *sportTypes = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sportTypes" ofType:@"plist"]];
        
        NSMutableArray *MuSportTypes = [NSMutableArray array];
        
        NSArray *chestArray = @[@"平板卧推", @"上斜卧推", @"哑铃飞鸟", @"哑铃卧推", @"俯卧撑"];
        NSArray *backArray = @[@"引体向上", @"俯身划船", @"坐姿下拉", @"杠铃划船", @"器械划船"];
        NSArray *shoulderArray = @[@"哑铃前平举", @"杠铃直立划船", @"哑铃侧弯举", @"杠铃上推", @"俯身哑铃弯举"];
        NSArray *legArray = @[@"杠铃深蹲", @"杠铃箭步蹲", @"哑铃箭步蹲", @"罗汉蹲", @"坐姿提踵"];
        NSArray *staminaArray = @[@"跑步", @"椭圆机", @"游泳", @"登山机", @"HIIT"];
        NSArray *coreArray = @[@"卷腹", @"山羊挺身", @"杠铃硬拉", @"单腿硬拉", @"杠铃高翻+深蹲", @"平板支撑"];
        NSArray *otherArray = @[@"TRX", @"爬楼梯", @"其他运动"];
        
        NSArray *sportNames0 = [NSArray array];
        //生成一个可变数组，用于编辑该项运动的包含运动名称
        NSMutableArray *chestMuArray = [[NSMutableArray alloc] initWithArray:chestArray];
        sportNames0 = [chestMuArray copy];
        NSMutableDictionary *dic0 = [NSMutableDictionary dictionary];
        [dic0 setObject:[sportTypes[0] objectForKey:@"sportType"] forKey:@"sportType"];
        [dic0 setObject:sportNames0 forKey:@"sportName"];
        [MuSportTypes addObject:dic0];
        
        NSArray *sportNames1 = [NSArray array];
        NSMutableArray *backMuArray = [[NSMutableArray alloc] initWithArray:backArray];
        sportNames1 = [backMuArray copy];
        NSMutableDictionary *dic1 = [NSMutableDictionary dictionary];
        [dic1 setObject:[sportTypes[1] objectForKey:@"sportType"] forKey:@"sportType"];
        [dic1 setObject:sportNames1 forKey:@"sportName"];
        [MuSportTypes addObject:dic1];
        
        NSArray *sportNames2 = [NSArray array];
        NSMutableArray *shoulderMuArray = [[NSMutableArray alloc] initWithArray:shoulderArray];
        sportNames2 = [shoulderMuArray copy];
        NSMutableDictionary *dic2 = [NSMutableDictionary dictionary];
        [dic2 setObject:[sportTypes[2] objectForKey:@"sportType"] forKey:@"sportType"];
        [dic2 setObject:sportNames2 forKey:@"sportName"];
        [MuSportTypes addObject:dic2];
        
        NSArray *sportNames3 = [NSArray array];
        NSMutableArray *legMuArray = [[NSMutableArray alloc] initWithArray:legArray];
        sportNames3 = [legMuArray copy];
        NSMutableDictionary *dic3 = [NSMutableDictionary dictionary];
        [dic3 setObject:[sportTypes[3] objectForKey:@"sportType"] forKey:@"sportType"];
        [dic3 setObject:sportNames3 forKey:@"sportName"];
        [MuSportTypes addObject:dic3];
        
        NSArray *sportNames4 = [NSArray array];
        NSMutableArray *staminaMuArray = [[NSMutableArray alloc] initWithArray:staminaArray];
        sportNames4 = [staminaMuArray copy];
        NSMutableDictionary *dic4 = [NSMutableDictionary dictionary];
        [dic4 setObject:[sportTypes[4] objectForKey:@"sportType"] forKey:@"sportType"];
        [dic4 setObject:sportNames4 forKey:@"sportName"];
        [MuSportTypes addObject:dic4];
        
        NSArray *sportNames5 = [NSArray array];
        NSMutableArray *coreMuArray = [[NSMutableArray alloc] initWithArray:coreArray];
        sportNames5 = [coreMuArray copy];
        NSMutableDictionary *dic5 = [NSMutableDictionary dictionary];
        [dic5 setObject:[sportTypes[5] objectForKey:@"sportType"] forKey:@"sportType"];
        [dic5 setObject:sportNames5 forKey:@"sportName"];
        [MuSportTypes addObject:dic5];
        
        NSArray *sportNames6 = [NSArray array];
        NSMutableArray *otherMuArray = [[NSMutableArray alloc] initWithArray:otherArray];
        sportNames6 = [otherMuArray copy];
        NSMutableDictionary *dic6 = [NSMutableDictionary dictionary];
        [dic6 setObject:[sportTypes[6] objectForKey:@"sportType"] forKey:@"sportType"];
        [dic6 setObject:sportNames6 forKey:@"sportName"];
        [MuSportTypes addObject:dic6];
        
        BOOL successWrited = [MuSportTypes writeToFile:fileSavePath atomically:YES];
        
        if (successWrited) {
            NSLog(@"已写入plist数据！");
        }else{
            NSLog(@"写入失败！");
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
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
    [self saveContext];
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
