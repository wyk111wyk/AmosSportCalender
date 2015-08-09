//
//  summaryTypeCell.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/7.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "summaryTypeCell.h"

@implementation summaryTypeCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if ([self.typeLabel.text isEqualToString:@"胸部"]) {
        self.backgroundColor = [UIColor colorWithRed:0.5725 green:0.3216 blue:0.0667 alpha:0.7];
    }else if ([self.typeLabel.text isEqualToString:@"背部"]){
        self.backgroundColor = [UIColor colorWithRed:0.5725 green:0.5608 blue:0.1059 alpha:0.7];
    }else if ([self.typeLabel.text isEqualToString:@"肩部"]){
        self.backgroundColor = [UIColor colorWithRed:0.3176 green:0.5569 blue:0.0902 alpha:0.7];
    }else if ([self.typeLabel.text isEqualToString:@"腿部"]){
        self.backgroundColor = [UIColor colorWithRed:0.0824 green:0.5686 blue:0.5725 alpha:0.7];
    }else if ([self.typeLabel.text isEqualToString:@"体力"]){
        self.backgroundColor = [UIColor colorWithRed:0.9922 green:0.5765 blue:0.1490 alpha:0.7];
    }else if ([self.typeLabel.text isEqualToString:@"核心"]){
        self.backgroundColor = [UIColor colorWithRed:0.9922 green:0.2980 blue:0.9882 alpha:0.7];
    }else if ([self.typeLabel.text isEqualToString:@"其他"]){
        self.backgroundColor = [UIColor colorWithRed:0.6078 green:0.9255 blue:0.2980 alpha:0.7];
    }
    
    
    // Configure the view for the selected state
}

- (IBAction)changeShowType:(UIButton *)sender {
//    NSLog(@"click the Button");
    if (self.changeShowBlock){
        self.changeShowBlock();
    }
}

@end
