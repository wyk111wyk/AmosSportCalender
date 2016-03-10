//
//  TypeDisplayCell.m
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/10.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import "TypeDisplayCell.h"

@implementation TypeDisplayCell

- (void)awakeFromNib {
    // Initialization code
    _themeColor = [UIColor lightGrayColor];
    _iconImageView.image = [UIImage imageNamed:@"arm_muscles"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    _iconImageView.image = [_iconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _iconImageView.tintColor = _themeColor;
    _iconLabel.textColor = _themeColor;
}

@end
