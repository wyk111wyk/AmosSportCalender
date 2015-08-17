//
//  FeedbackTVCell.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/15.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "FeedbackTVCell.h"

@implementation FeedbackTVCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)clickToZan:(UIButton *)sender {
    
    if (self.clickToVoteBlock) {
    self.clickToVoteBlock();
    }
}

@end
