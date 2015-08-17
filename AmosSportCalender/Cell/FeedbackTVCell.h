//
//  FeedbackTVCell.h
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/15.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedbackTVCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (copy, nonatomic) void (^clickToVoteBlock)();

@end
