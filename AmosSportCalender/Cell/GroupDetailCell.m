//
//  GroupDetailCell.m
//  AmosSportDiary
//
//  Created by Amos Wu on 15/10/4.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "GroupDetailCell.h"
#import "CommonMarco.h"

@implementation GroupDetailCell

- (void)awakeFromNib {
    // Initialization code
    _levelBGView.layer.borderWidth = 0.7;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    _iconImageView.image = [_iconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _iconImageView.tintColor = [UIColor darkGrayColor];
}

@end
