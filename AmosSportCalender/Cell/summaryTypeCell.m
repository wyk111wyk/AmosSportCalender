//
//  summaryTypeCell.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/7.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "summaryTypeCell.h"
#import "SettingStore.h"

@implementation summaryTypeCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    SettingStore *setting = [SettingStore sharedSetting];
    NSArray *oneColor = [setting.typeColorArray objectAtIndex:[self colorForsportType:self.typeLabel.text]];
    UIColor *pickedColor = [UIColor colorWithRed:[oneColor[0] floatValue] green:[oneColor[1] floatValue] blue:[oneColor[2] floatValue] alpha:1];
    
    self.backgroundColor = pickedColor;
}

- (int)colorForsportType:(NSString *)sportType
{
    if ([sportType isEqualToString:@"胸部"]) {
        return 0;
    }else if ([sportType isEqualToString:@"背部"]){
        return 1;
    }else if ([sportType isEqualToString:@"肩部"]){
        return 2;
    }else if ([sportType isEqualToString:@"腿部"]){
        return 3;
    }else if ([sportType isEqualToString:@"体力"]){
        return 4;
    }else if ([sportType isEqualToString:@"核心"]){
        return 5;
    }else if ([sportType isEqualToString:@"手臂"]){
        return 6;
    }else if ([sportType isEqualToString:@"其他"]){
        return 7;
    }
    
    return 0;
}

- (IBAction)changeShowType:(UIButton *)sender {
//    NSLog(@"click the Button");
    if (self.changeShowBlock){
        self.changeShowBlock();
    }
}

@end
