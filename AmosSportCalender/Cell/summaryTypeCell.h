//
//  summaryTypeCell.h
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/7.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface summaryTypeCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *daysOrPerLabel;

@property (weak, nonatomic) IBOutlet UIButton *changeShowTypeButton;

@property (copy, nonatomic) void(^changeShowBlock)();

@end
