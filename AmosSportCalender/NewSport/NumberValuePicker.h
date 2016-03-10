//
//  NumberValuePicker.h
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/10.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NumberValuePicker : UIView

+ (instancetype)viewFromNib;
- (void)configUITitle:(NSString*)titleText unit:(NSString*)unitText min:(int)min max:(int)max step:(int)step initNum:(int)initNum;
@property (nonatomic, strong) void(^valueChangeBlock)(int);
@property (nonatomic, strong) void(^clearBlock)();
@property (nonatomic, strong) void(^selfWeghtBlock)();

@end
