//
//  ASBaseManage.m
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/9.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

#import "ASBaseManage.h"
#import "CommonMarco.h"
#import "MGSwipeButton.h"
#import "TouchIDViewController.h"
#import "DMPasscode.h"

@interface ASBaseManage()<EKEventEditViewDelegate>

// EKEventStore instance associated with the current Calendar application
@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) EKEvent *ekevent;
@property (nonatomic, strong) NSString *idf;

@end

@implementation ASBaseManage

+ (instancetype)sharedManage {
    static ASBaseManage *sharedManage = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManage = [[self alloc] init];
    });
    
    return sharedManage;
}

#pragma mark - 日期相关

+ (NSDateFormatter *)dateFormatterForDMY
{
    static NSDateFormatter *dateFormatter= nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
    });
    dateFormatter.dateFormat = @"dd-MM-yyyy";
    return dateFormatter;
}

+ (NSDateFormatter *)dateFormatterForDMYE
{
    static NSDateFormatter *dateFormatter= nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
    });
    dateFormatter.dateFormat = @"yyyy-MM-dd EEEE";
    return dateFormatter;
}

+ (NSDateFormatter *)dateFormatterForMY
{
    static NSDateFormatter *dateFormatter= nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
    });
    dateFormatter.dateFormat = @"MM-yyyy";
    return dateFormatter;
}

//某个月1号是星期几, 1 = 星期一, 7 = 星期天
- (NSInteger)weekOfFirstDay: (NSDate *)today
{
    NSDate *now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal
                               components:NSCalendarUnitYear | NSCalendarUnitMonth
                               fromDate:now];
    comps.day = 1;
    NSDate *firstDay = [cal dateFromComponents:comps];
    NSInteger timpStamp = [firstDay timeIntervalSince1970];
    NSInteger weekNum = [self weekDayFromTimeStamp:timpStamp];
    //找到星期
    return weekNum;
}

//根据时间戳计算星期几, 1 = 星期一, 7 = 星期天
- (NSInteger)weekDayFromTimeStamp: (NSInteger)timeStamp {
    NSInteger daySeconds = 24*60*60;
    
    NSInteger flagTimeStamp = [[NSDate date] timeIntervalSince1970];
    if (timeStamp) {
        flagTimeStamp = timeStamp;
    }
    
    NSInteger weekDay = (flagTimeStamp/daySeconds % 7) + 4;
    if (weekDay > 7) {
        weekDay = weekDay - 7;
    }
    
    return weekDay;
}

- (NSString *)lastMonthFrom: (NSString *)dateStr
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *compoents = [cal components:(NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:[[ASBaseManage dateFormatterForMY] dateFromString:dateStr]];
    
    NSInteger thisMonth = compoents.month;
    NSInteger thisYear = compoents.year;
    if (thisMonth == 1) {
        thisMonth = 13;
        thisYear -= 1;
    }
    
    NSString *monthAndYear = [NSString stringWithFormat:@"%li-%li",(long)thisMonth - 1,(long)thisYear];
    
    if (thisMonth < 11) {
        monthAndYear = [NSString stringWithFormat:@"0%li-%li",(long)thisMonth - 1,(long)thisYear];
    }
    return monthAndYear;
}

- (NSString *)nextMonthFrom: (NSString *)dateStr
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *compoents = [cal components:(NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:[[ASBaseManage dateFormatterForMY] dateFromString:dateStr]];
    
    NSInteger thisMonth = compoents.month;
    NSInteger thisYear = compoents.year;
    if (thisMonth == 12) {
        thisMonth = 0;
        thisYear += 1;
    }
    
    NSString *monthAndYear = [NSString stringWithFormat:@"%li-%li",(long)thisMonth + 1,(long)thisYear];
    
    if (thisMonth < 9) {
        monthAndYear = [NSString stringWithFormat:@"0%li-%li",(long)thisMonth + 1,(long)thisYear];
    }
    return monthAndYear;
}

- (NSDate *)thisMonthLastDay: (NSDate *)date
{
    NSString *thisMonth = [[ASBaseManage dateFormatterForMY] stringFromDate:date];
    NSString *nextMonthAndYear = [self nextMonthFrom:thisMonth];
    
    NSDate *nextMonthFirstDay = [[ASBaseManage dateFormatterForDMY] dateFromString:[NSString stringWithFormat:@"01-%@", nextMonthAndYear]];
    //调个时差
    NSTimeZone *localZone = [NSTimeZone localTimeZone];
    NSInteger interval = [localZone secondsFromGMTForDate:nextMonthFirstDay];
    NSDate *nextMonthFirstDayNew = [nextMonthFirstDay dateByAddingTimeInterval:interval];
    //减去一天
    NSInteger intervalToLastDay = - 24*60*60;
    NSDate *lastMonthLastDay = [nextMonthFirstDayNew dateByAddingTimeInterval:intervalToLastDay];
    
    return lastMonthLastDay;
}

#pragma mark - TouchID

- (void)getTheAuthorityOfNofication {
    if (IS_IOS8) {
        UIUserNotificationSettings *setting=[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    }
}

- (void)UseTouchIDForSecurity {
    SettingStore *settingStore = [SettingStore sharedSetting];
    if ([DMPasscode isPasscodeSet] && settingStore.isTouchIDOn) {
        
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        TouchIDViewController *touchIDVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"touchid"];
        UIViewController *currentVC = [self getCurrentVC];
        [currentVC presentViewController:touchIDVC animated:NO completion:nil];
        touchIDVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

//根据Day所有完成的运动项目中，寻找数量最多的那一项
- (NSString *)findTheMaxOfTypes:(NSArray *)allDayEvents
{
    NSMutableArray *allDayParts = [NSMutableArray array];
    for (SportRecordStore *recordStore in allDayEvents){
        [allDayParts addObject:recordStore.sportPart];
    }
    
    NSCountedSet *countedSet = [[NSCountedSet alloc] initWithArray:allDayParts];
    NSSet *tempSet = [[NSSet alloc] initWithArray:allDayParts];
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    for (NSString *partText in tempSet){
        NSInteger countNum = [countedSet countForObject:partText];
        [tempDic setObject:@(countNum) forKey:partText];
    }
    
    NSArray *allDicPart = [tempDic allKeys];
    NSArray *allDicCount = [tempDic allValues];
    int maxIndex = [self findMaxIndexInArray:allDicCount];
    NSString *maxPart = allDicPart[maxIndex];
    return maxPart;
}

//求数组中最大值的方法
- (int)findMaxInArray:(NSArray *)array
{
    int max = 0;
    max = [array[0] intValue];
    for (int i = 1; i < array.count; i++) {
        if ([array[i] intValue] > max) {
            max = [array[i] intValue];
        }
    }
    return max;
}

- (int)findMaxIndexInArray:(NSArray *)array
{
    int max = [array[0] intValue];
    int maxIndex = 0;
    for (int i = 1; i < array.count; i++) {
        if ([array[i] intValue] > max) {
            max = [array[i] intValue];
            maxIndex = i;
        }
    }
    return maxIndex;
}

- (UIColor *)colorForsportType:(NSString *)sportType
{
    NSArray *sportParts = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SportParts" ofType:@"plist"]];
    NSInteger colorIndex = [sportParts indexOfObject:sportType];
    
    SettingStore *setting = [SettingStore sharedSetting];
    NSArray *oneColor = [setting.typeColorArray objectAtIndex:colorIndex];
    UIColor *pickedColor = [UIColor colorWithRed:[oneColor[0] floatValue] green:[oneColor[1] floatValue] blue:[oneColor[2] floatValue] alpha:1];
    
    return pickedColor;
}

-(NSArray *) createDoneAndUndoButtons
{
    NSMutableArray * result = [NSMutableArray array];
    NSArray * colors = @[MYBlueColor, MyLightGray];
    NSArray * icons = @[[UIImage imageNamed:@"doneMark"], [UIImage imageNamed:@"undo_Slide"]];
    
    for (int i = 0; i < colors.count; ++i)
    {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:@"" icon:icons[i] backgroundColor:colors[i] padding:15 callback:^BOOL(MGSwipeTableCell * sender){
            //            if (DeBugMode) {NSLog(@"Cell滑动(Left)的简易回调");}
            return YES;
        }];
        
        [result addObject:button];
    }
    return result;
}

-(NSArray *) createDeleteAndEditButtons
{
    NSMutableArray * result = [NSMutableArray array];
    NSArray * colors = @[[UIColor redColor], [UIColor orangeColor]];
    NSArray * icons = @[[UIImage imageNamed:@"delete_filled"], [UIImage imageNamed:@"edit_slide"]];
    
    for (int i = 0; i < colors.count; ++i)
    {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:@"" icon:icons[i] backgroundColor:colors[i] padding:15 callback:^BOOL(MGSwipeTableCell * sender){
            //            if (DeBugMode) {NSLog(@"Cell滑动(Left)的简易回调");}
            return YES;
        }];
        
        [result addObject:button];
    }
    return result;
}

# pragma mark - 屏幕截图处理方法

//对某View进行截图
- (UIImage*)captureView: (UIView *)theView Rectsize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.f);
    //将view上的子view加进来
    CGContextRef context =UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    
    //    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    //    UIImage *img = [UIImage imageWithCGImage:imageMasked];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

//合并两张图片
- (UIImage *)addImageview:(UIImage *)imageBottom toImage:(UIImage *)imageTop {
    
    CGSize size = CGSizeMake(imageTop.size.width, imageTop.size.height + imageBottom.size.height);
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.f);
    
    // Draw image1
    [imageTop drawInRect:CGRectMake(0, 0, imageTop.size.width, imageTop.size.height)];
    
    // Draw image2
    [imageBottom drawInRect:CGRectMake(0, imageTop.size.height, imageBottom.size.width, imageBottom.size.height)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

//改变图片大小
- (UIImage *)scaleTheImage:(UIImage *)img {
    
    float radio = img.size.height / img.size.width;
    
    float width = screenWidth;
    float height = width * radio;
    
    // 并把它设置成为当前正在使用的context(这里的Size是最终成品图的size)
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), YES, 0.f);
    
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, width, height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}

/** @brief Returns a customized snapshot of a given view. */
- (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

#pragma mark - 创建日历事件的方法

// Check the authorization status of our application for Calendar
-(void)checkEventStoreAccessForCalendarWithdayEvents:(NSMutableArray *)allDayEvents seDate: (NSDate *)seDate dayPart: (NSString *)dayPart view:(UIViewController *)rootVC
{
    self.eventStore = [[EKEventStore alloc] init];
    
    if ([self.eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        // the selector is available, so we must be on iOS 6 or newer
        [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    NSLog(@"请求许可错误");
                }
                else if (!granted)
                {
                    NSLog(@"被用户拒绝");
                }
                else
                {
                    [self accessGrantedForCalendar:self.eventStore dayEvents:allDayEvents seDate:seDate dayPart:dayPart view:rootVC];
                }
            });
        }];
    }
}

-(void)accessGrantedForCalendar:(EKEventStore *)eventStore dayEvents:(NSMutableArray *)allDayEvents seDate: (NSDate *)seDate dayPart: (NSString *)dayPart view:(UIViewController *)rootVC
{
    self.ekevent  = [EKEvent eventWithEventStore:self.eventStore];
    
    //设置创建日历的内容
    
    //设置事件标题
    self.ekevent.title = [NSString stringWithFormat:@"进行：%@锻炼", dayPart];  //事件标题
    
    //设置事件内容
    NSString *initStr = [NSString stringWithFormat:@"锻炼内容：\n"];
    NSMutableString *notesStr = [[NSMutableString alloc] initWithString:initStr];
    
    for (SportRecordStore *recordStore in allDayEvents){
        NSString *unitText = @"";
        SettingStore *setting = [SettingStore sharedSetting];
        if (recordStore.weight == 999){
            //不变
        }else if (setting.weightUnit == 0) {
            unitText = @"Kg";
        }else if (setting.weightUnit == 1) {
            unitText = Local(@"lb");
        }
        
        NSString *tempAttribute;
        if (recordStore.sportType == 1) {
            tempAttribute = [NSString stringWithFormat:@"%d组 x %d次  %d%@", recordStore.repeatSets, recordStore.RM, recordStore.weight, unitText];
        }else {
            tempAttribute = [NSString stringWithFormat:Local(@"%d min"), recordStore.timeLast];
        }
        [notesStr appendFormat:@"- %@ （%@）\n", recordStore.sportName, tempAttribute];
        
    }
    self.ekevent.notes = notesStr; //事件内容
    
    //设置事件链接
    self.ekevent.URL = [NSURL URLWithString:@"openurlAmosSportCalendar://"];
    
    //设置时间和日期
    NSDateFormatter* inputFormatter = [NSDateFormatter new];
    [inputFormatter setDateFormat:@"YYYY-MM-dd"];
    [inputFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    NSDateFormatter *outFormatter = [NSDateFormatter new];
    [outFormatter setDateFormat:@"YYYY-MM-dd-H-mm"];
    
    NSString *tempDateStr = [inputFormatter stringFromDate:seDate];
    NSMutableString *tempDateMuStr = [[NSMutableString alloc] initWithString:tempDateStr];
    NSMutableString *tempDateMuStr1 = [[NSMutableString alloc] initWithString:tempDateStr];
    [tempDateMuStr appendString:@"-15-30"];
    NSDate *startDate = [outFormatter dateFromString:tempDateMuStr];
    [tempDateMuStr1 appendString:@"-17-00"];
    NSDate *endDate = [outFormatter dateFromString:tempDateMuStr1];
    
    self.ekevent.startDate = startDate;
    self.ekevent.endDate   = endDate;
    self.ekevent.allDay = NO;
    
    //添加提醒
    [self.ekevent addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -60.0f * 1]];  //1小时前提醒
    //    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -15.0f]];  //15分钟前提醒
    
    EKEventEditViewController *addController = [[EKEventEditViewController alloc] init];
    
    addController.event = self.ekevent;
    addController.eventStore = self.eventStore;
    addController.editViewDelegate = self;
    [rootVC presentViewController:rootVC animated:YES completion:nil];
}

#pragma mark EKEventEditViewDelegate

// 编辑日历事件页面中按钮的事件
- (void)eventEditViewController:(EKEventEditViewController *)controller
          didCompleteWithAction:(EKEventEditViewAction)action
{
    
    // Dismiss the modal view controller
//    [self dismissViewControllerAnimated:YES completion:^
//     {
//         if (action == EKEventEditViewActionCanceled)
//         {
//         }else if (action == EKEventEditViewActionSaved)
//         {
//             NSLog(@"事件创建成功");
//         }else if (action == EKEventEditViewActionDeleted)
//         {
//         }
//     }];
}

//删除一个日历事件
- (void)deleteTheEvent
{
    EKEvent *eventToRemove = [self.eventStore eventWithIdentifier:self.idf];
    
    if ([eventToRemove.eventIdentifier length] > 0) {
        NSError* error = nil;
        [self.eventStore removeEvent:eventToRemove span:EKSpanThisEvent error:&error];
        if (error) {
            NSLog(@"%@",error);
        }else {
            NSLog(@"将一个日历事件删除");
        }
    }
}

@end
