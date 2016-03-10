//
//  ASBaseManage.m
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/9.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import "ASBaseManage.h"
#import "CommonMarco.h"

#import "TouchIDViewController.h"
#import "DMPasscode.h"

@implementation ASBaseManage

+ (instancetype)sharedManage {
    static ASBaseManage *sharedManage = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManage = [[self alloc] init];
    });
    
    return sharedManage;
}

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

@end
