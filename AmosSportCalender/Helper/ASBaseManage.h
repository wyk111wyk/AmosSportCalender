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

- (void)getTheAuthorityOfNofication;
- (void)UseTouchIDForSecurity;
- (UIViewController *)getCurrentVC;
//求数组中最大值的方法
- (int)findMaxInArray:(NSArray *)array;

//对某View进行截图
- (UIImage *)captureView: (UIView *)theView Rectsize:(CGSize)size;
//合并两张图片
- (UIImage *)addImageview:(UIImage *)imageBottom toImage:(UIImage *)imageTop;
//改变图片大小
- (UIImage *)scaleTheImage:(UIImage *)img;
- (UIView *)customSnapshoFromView:(UIView *)inputView;

@end
