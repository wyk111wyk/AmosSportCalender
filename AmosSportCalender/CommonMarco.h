//
//  CommonMarco.h
//  AmosSportDiary
//
//  Created by Amos Wu on 15/8/27.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#ifndef CommonMarco_h
#define CommonMarco_h

//社交分享
#define WeiXin_AppKey             @"wx7804e9687ad3c0bd"

#define APP_KEY_QQ                @"5y5BSz5bqUeP26k3"
#define APP_ID_QQ                 @"1104756843"

#define APP_KEY_WEIBO             @"4124563743"
#define APP_Secret_WEIBO          @"7340848d619c9388c3af1c6ae4921d46"
#define APP_KEY_WEIBO_RedirectURL @"http://www.sina.com"

//友盟
#define YouMen_AppKey             @"55dd6364e0f55ab05b000502"
#define PGY_APP_ID                @"1694170a8f87c44a10201ef6c8831931"

//屏幕
#define screenWidth ([UIScreen mainScreen].bounds.size.width)
#define screenHeight ([UIScreen mainScreen].bounds.size.height)
#define screenScale ([UIScreen mainScreen].scale)
#define screenSize ([UIScreen mainScreen].bounds.size)

#define IS_IOS8 ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0)

//国际化
#define kFEEDBACK_LOCALIZABLE_TABLE @"AmosSportDiaryLocalizable"
#define Local(key) NSLocalizedStringFromTable(key, kFEEDBACK_LOCALIZABLE_TABLE, nil)


#endif /* CommonMarco_h */
