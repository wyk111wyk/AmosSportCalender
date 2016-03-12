//
//  ASBaseManage.h
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/9.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class UIViewController;

@interface ASBaseManage : NSObject

+ (instancetype)sharedManage;
+ (NSDateFormatter *)dateFormatterForDMY;
+ (NSDateFormatter *)dateFormatterForDMYE;
+ (NSDateFormatter *)dateFormatterForMY;
//某个月1号是星期几
- (NSInteger)weekOfFirstDay: (NSDate *)today;
- (NSInteger)weekDayFromTimeStamp: (NSInteger)timeStamp;
- (NSString *)lastMonthFrom: (NSString *)dateStr;
- (NSString *)nextMonthFrom: (NSString *)dateStr;
- (NSDate *)thisMonthLastDay: (NSDate *)date;

- (void)getTheAuthorityOfNofication;
- (void)UseTouchIDForSecurity;
- (UIViewController *)getCurrentVC;
//根据Day所有完成的运动项目中，寻找数量最多的那一项
- (NSString *)findTheMaxOfTypes:(NSArray *)allDayEvents;
//求数组中最大值的方法
- (int)findMaxInArray:(NSArray *)array;
- (UIColor *)colorForsportType:(NSString *)sportType;

-(NSArray *) createDoneAndUndoButtons;
-(NSArray *) createDeleteAndEditButtons;

//对某View进行截图
- (UIImage *)captureView: (UIView *)theView Rectsize:(CGSize)size;
//合并两张图片
- (UIImage *)addImageview:(UIImage *)imageBottom toImage:(UIImage *)imageTop;
//改变图片大小
- (UIImage *)scaleTheImage:(UIImage *)img;
- (UIView *)customSnapshoFromView:(UIView *)inputView;

//日历创建
-(void)checkEventStoreAccessForCalendarWithdayEvents:(NSMutableArray *)allDayEvents seDate: (NSDate *)seDate dayPart: (NSString *)dayPart view:(UIViewController *)rootVC;

@end
