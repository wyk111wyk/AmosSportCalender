//
//  SportTVCell.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/7/28.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "SportTVCell.h"
#import "Event.h"
#import "SettingStore.h"

@implementation SportTVCell

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

//    NSLog(@"载入cell数据");
    
    self.sportName.text = self.event.sportName;
    [self.sportName sizeToFit];
    
    if (self.event.weight == 0 && self.event.times > 0) {
        self.sportPro.text = [NSString stringWithFormat:@"%d组 x %d次", self.event.rap, self.event.times];
    }else if (self.event.weight == 220 && self.event.times > 0){
        self.sportPro.text = [NSString stringWithFormat:@"%d组 x %d次  自身重量", self.event.rap, self.event.times];
    }else if (self.event.times == 0 && self.event.rap == 0){
        self.sportPro.text = @"Go！Go！Go！";
    }else{
    self.sportPro.text = [NSString stringWithFormat:@"%d组 x %d次   %.1fkg", self.event.rap, self.event.times, self.event.weight];
    }
    
    self.timelastLabel.text = [NSString stringWithFormat:@"%d", self.event.timelast];
    
    if (self.event.done == NO) {
        
        self.backgroundColor = [UIColor whiteColor];
//        NSLog(@"In cell Not Done");
        self.donePic.hidden = YES;
        self.sportName.textColor = [UIColor blackColor];
        self.sportPro.textColor = [UIColor darkGrayColor];
        
        self.sportType.text = self.event.sportType;
        
        SettingStore *setting = [SettingStore sharedSetting];
        NSArray *oneColor = [setting.typeColorArray objectAtIndex:[self colorForsportType:self.event.sportType]];
        UIColor *pickedColor = [UIColor colorWithRed:[oneColor[0] floatValue] green:[oneColor[1] floatValue] blue:[oneColor[2] floatValue] alpha:1];
        
        self.sportType.textColor = pickedColor;

    }else{
//        NSLog(@"In cell Done");
        self.backgroundColor = [UIColor colorWithRed:0.8980 green:0.8980 blue:0.8980 alpha:0.9];
        self.donePic.hidden = NO;
        self.sportType.text = self.event.sportType;
        self.sportType.textColor = [UIColor grayColor];
        self.sportName.textColor = [UIColor grayColor];
        self.sportPro.textColor = [UIColor grayColor];
    }
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

@end
