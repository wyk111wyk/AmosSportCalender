//
//  EventDisplayCell.m
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/10.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import "EventDisplayCell.h"

@implementation EventDisplayCell

- (void)awakeFromNib {
    // Initialization code
    _themeColor = [UIColor lightGrayColor];
    _partLabel.layer.cornerRadius = 5;
    _partLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _partLabel.layer.borderWidth = 0.7;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    _partLabel.textColor = _themeColor;
    _partLabel.layer.borderColor = _themeColor.CGColor;
}

@end
