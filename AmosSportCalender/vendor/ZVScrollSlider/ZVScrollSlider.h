//
//  ZVScrollSider.h
//  scrllSlider
//
//  Created by 子为 on 15/12/25.
//  Copyright © 2015年 wealthBank. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZVScrollSlider;

@protocol ZVScrollSliderDelegate <NSObject>

-(void)ZVScrollSlider:(ZVScrollSlider *)slider ValueChange:(int )value;

@optional
-(void)ZVScrollSliderDidDelete:(ZVScrollSlider *)slider;
-(void)ZVScrollSliderDidTouch:(ZVScrollSlider *)slider;

@end

@interface ZVScrollSlider : UIView
@property (nonatomic, copy ) NSString *title;
@property (nonatomic) BOOL isAllowInput; ///<是否允许键盘输入
@property (nonatomic, copy ,  readonly) NSString *unit;
@property (nonatomic, assign ,readonly) int minValue; ///<设置这个时max-min必须可以整除10
@property (nonatomic, assign ,readonly) int maxValue;
@property (nonatomic, assign ,readonly) int step;
@property (nonatomic, weak) id<ZVScrollSliderDelegate> delegate;

@property (nonatomic, assign) float realValue;
-(void)setRealValue:(float)realValue Animated:(BOOL)animated;

-(instancetype)initWithFrame:(CGRect)frame Title:(NSString *)title MinValue:(int)minValue MaxValue:(int)maxValue Step:(int)step Unit:(NSString *)unit HasDeleteBtn:(BOOL)hasDeleteBtn;
+(CGFloat)heightWithBoundingWidth:(CGFloat )width Title:(NSString *)title;


@end

