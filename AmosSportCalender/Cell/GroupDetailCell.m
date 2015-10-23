//
//  GroupDetailCell.m
//  AmosSportDiary
//
//  Created by Amos Wu on 15/10/4.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "GroupDetailCell.h"
#import "SettingStore.h"

@implementation GroupDetailCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.sportName.text = self.event.sportName;
    [self.sportName sizeToFit];
    
    if (self.event.weight == 0 && self.event.times > 0) {
        self.sportPro.text = [NSString stringWithFormat:@"%d组 x %d次", self.event.rap, self.event.times];
    }else if (self.event.weight == 300 && self.event.times > 0){
        self.sportPro.text = [NSString stringWithFormat:@"%d组 x %d次  自身重量", self.event.rap, self.event.times];
    }else if (self.event.times == 0 && self.event.rap == 0){
        self.sportPro.text = @"Go！Go！Go！";
    }else{
        self.sportPro.text = [NSString stringWithFormat:@"%d组 x %d次   %.1fkg", self.event.rap, self.event.times, self.event.weight];
    }
    
    self.timelastLabel.text = [NSString stringWithFormat:@"%d", self.event.timelast];
    
    self.backgroundColor = [UIColor whiteColor];

    self.sportName.textColor = [UIColor blackColor];
    self.sportPro.textColor = [UIColor lightGrayColor];
    
    self.sportType.text = self.event.sportType;
    
    SettingStore *setting = [SettingStore sharedSetting];
    NSArray *oneColor = [setting.typeColorArray objectAtIndex:[self colorForsportType:self.event.sportType]];
    UIColor *pickedColor = [UIColor colorWithRed:[oneColor[0] floatValue] green:[oneColor[1] floatValue] blue:[oneColor[2] floatValue] alpha:1];
    
    self.sportType.textColor = pickedColor;
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
    }else if ([sportType isEqualToString:@"综合"]){
        return 7;
    }
    
    return 0;
}

@end
