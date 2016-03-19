//
//  CommonMarco.h
//  AmosSportDiary
//
//  Created by Amos Wu on 15/8/27.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//



#ifndef CommonMarco_h
#define CommonMarco_h

#import "SettingStore.h"
#import "ASBaseManage.h"
#import "ASDataManage.h"
#import "KVNProgress.h"
#import "YYKit.h"
#import "TMCache.h"

#import "SportRecordStore.h"
#import "SportEventStore.h"
#import "DateEventStore.h"
#import "GroupSetStore.h"
#import "SportImageStore.h"

/** Debug */
#define DeBugMode 0

//社交分享
#define WeiXin_AppKey             @"wx7804e9687ad3c0bd"

#define APP_KEY_QQ                @"5y5BSz5bqUeP26k3"
#define APP_ID_QQ                 @"1104756843"

#define APP_KEY_WEIBO             @"4124563743"
#define APP_Secret_WEIBO          @"7340848d619c9388c3af1c6ae4921d46"
#define APP_KEY_WEIBO_RedirectURL @"http://www.sina.com"

//友盟
#define YouMen_AppKey             @"55dd6364e0f55ab05b000502"
#define Bugtags_AppKey            @"4c25682af3b62c39f33403579ed9fbf1"

//标准化
#define UserFolderName @"userData"
#define UserFileName @"UsersChangeLists.plist"

//屏幕
#define screenWidth ([UIScreen mainScreen].bounds.size.width)
#define screenHeight ([UIScreen mainScreen].bounds.size.height)
#define screenOfScale ([UIScreen mainScreen].scale)
#define screenSize ([UIScreen mainScreen].bounds.size)

#define WidthiPhone5 320
#define WidthiPhone6 375
#define WidthiPhone6p 414

#define IS_IOS8 ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0)
#define ATCacheKey(qid)   [NSString stringWithFormat:@"amosSport_cache_%@", qid]

//国际化
#define kFEEDBACK_LOCALIZABLE_TABLE @"AmosSportDiaryLocalizable"
#define Local(key) NSLocalizedStringFromTable(key, kFEEDBACK_LOCALIZABLE_TABLE, nil)

//颜色
#define MyGreenColor [UIColor colorWithRed:0.0000 green:0.5608 blue:0.5176 alpha:1]
#define MyWhite [UIColor whiteColor]
#define MyLightGray [UIColor lightGrayColor]
#define MyDarkGray [UIColor darkGrayColor]
#define MYBlueColor [UIColor colorWithRed:0.2039 green:0.6980 blue:0.9647 alpha:1]

#define ColorForLevel3 [UIColor colorWithRed:0.9843 green:0.2980 blue:0.3098 alpha:1]
#define ColorForLevel2 [UIColor colorWithRed:0.1922 green:0.7686 blue:0.9882 alpha:1]
#define ColorForLevel1 [UIColor colorWithRed:0.5020 green:0.8118 blue:0.2118 alpha:1]

//#define chestColor [UIColor colorWithRed:0.4000 green:0.7059 blue:0.8980 alpha:1];
#define BackgroundColor [UIColor colorWithWhite:0.96 alpha:1]
#define CellBackgoundColor [UIColor colorWithRed:0.3804 green:0.8745 blue:0.8392 alpha:0.2]
#define backColor [UIColor colorWithRed:0.1647 green:0.7451 blue:0.6863 alpha:1];
#define shouldColor [UIColor colorWithRed:0.0039 green:0.8667 blue:0.8118 alpha:1];
#define legColor [UIColor colorWithRed:0.8745 green:0.7765 blue:0.1412 alpha:1];
#define staminaColor [UIColor colorWithRed:0.5882 green:0.8667 blue:0.0980 alpha:1];
#define coreColor [UIColor colorWithRed:0.4353 green:0.5098 blue:0.8745 alpha:1];
#define armColor [UIColor colorWithRed:0.8824 green:0.4314 blue:0.4824 alpha:1];
#define otherColor [UIColor colorWithRed:0.8667 green:0.5451 blue:0.8980 alpha:1];

#define RefreshSportEventsNotifcation @"RefreshSportEventsNotifcation"
#define RefreshRootPageEventsNotifcation @"RefreshRootPageEventsNotifcation"

#endif /* CommonMarco_h */
