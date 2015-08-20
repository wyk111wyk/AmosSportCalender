//
//  LeftMenuView.h
//  AmosSportDiary
//
//  Created by Amos Wu on 15/8/20.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftMenuView : UIControl

@property (nonatomic, strong)UIImageView *imageView; ///<menu图标
@property (nonatomic, strong)UILabel *titleLabel; ///<menu文字
@property (nonatomic, strong)UIView *pieView;
@property (nonatomic)BOOL isSelected;

@end
