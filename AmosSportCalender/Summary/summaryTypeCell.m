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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    UIColor *pickedColor = [[ASBaseManage sharedManage] colorForsportType:self.typeLabel.text];
    
    self.backgroundColor = pickedColor;
}

- (IBAction)changeShowType:(UIButton *)sender {
//    NSLog(@"click the Button");
    if (self.changeShowBlock){
        self.changeShowBlock();
    }
}

@end
