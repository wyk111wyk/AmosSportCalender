//
//  SummaryTVCell.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/5.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "SummaryTVCell.h"

@interface SummaryTVCell()

//Label
@property (weak, nonatomic) IBOutlet UILabel *dateNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *sportTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sportNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timelastLabel;

//view
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UIView *bottomLineView;

@end

@implementation SummaryTVCell

- (void)awakeFromNib {
    // Initialization code
    self.bottomLineView.backgroundColor = [UIColor colorWithRed:0.7843 green:0.7804 blue:0.8000 alpha:1];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
