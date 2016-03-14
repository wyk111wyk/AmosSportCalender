//
//  summaryTypeCell.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/7.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "summaryTypeCell.h"
#import "SettingStore.h"
#import "CommonMarco.h"

@implementation summaryTypeCell

- (void)awakeFromNib {
    // Initialization code
    _themeColor = [UIColor whiteColor];
    _iconImageView.image = [UIImage imageNamed:@"arm_muscles"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    UIColor *pickedColor = [[ASBaseManage sharedManage] colorForsportType:self.typeLabel.text];
    self.backgroundColor = pickedColor;
    
    _iconImageView.image = [_iconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _iconImageView.tintColor = _themeColor;
}

- (IBAction)changeShowType:(UIButton *)sender {
//    NSLog(@"click the Button");
    if (self.changeShowBlock){
        self.changeShowBlock();
    }
}

@end
