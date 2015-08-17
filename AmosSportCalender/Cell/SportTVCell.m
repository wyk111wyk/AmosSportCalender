//
//  SportTVCell.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/7/28.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "SportTVCell.h"
#import "Event.h"

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
        
//        NSLog(@"In cell Not Done");
        self.donePic.hidden = YES;
        self.sportName.textColor = [UIColor blackColor];
        self.sportPro.textColor = [UIColor darkGrayColor];
        
    self.sportType.text = self.event.sportType;
        
    if ([self.event.sportType isEqualToString:@"胸部"]) {
        self.sportType.textColor = [UIColor colorWithRed:0.5725 green:0.3216 blue:0.0667 alpha:1];
    }else if ([self.event.sportType isEqualToString:@"背部"]){
        self.sportType.textColor = [UIColor colorWithRed:0.5725 green:0.5608 blue:0.1059 alpha:1];
    }else if ([self.event.sportType isEqualToString:@"肩部"]){
        self.sportType.textColor = [UIColor colorWithRed:0.3176 green:0.5569 blue:0.0902 alpha:1];
    }else if ([self.event.sportType isEqualToString:@"腿部"]){
        self.sportType.textColor = [UIColor colorWithRed:0.0824 green:0.5686 blue:0.5725 alpha:1];
    }else if ([self.event.sportType isEqualToString:@"体力"]){
        self.sportType.textColor = [UIColor colorWithRed:0.9922 green:0.5765 blue:0.1490 alpha:1];
    }else if ([self.event.sportType isEqualToString:@"核心"]){
        self.sportType.textColor = [UIColor colorWithRed:0.9922 green:0.2980 blue:0.9882 alpha:1];
    }else if ([self.event.sportType isEqualToString:@"手臂"]){
        self.sportType.textColor = [UIColor colorWithRed:0.3647 green:0.4314 blue:0.9373 alpha:1];
    }else if ([self.event.sportType isEqualToString:@"其他"]){
        self.sportType.textColor = [UIColor colorWithRed:0.6078 green:0.9255 blue:0.2980 alpha:1];
    }
    }else{
//        NSLog(@"In cell Done");
        
        self.donePic.hidden = NO;
        self.sportType.text = self.event.sportType;
        self.sportType.textColor = [UIColor grayColor];
        self.sportName.textColor = [UIColor grayColor];
        self.sportPro.textColor = [UIColor grayColor];
    }
}

@end
