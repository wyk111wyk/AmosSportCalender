//
//  EventDisplayCell.h
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/10.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventDisplayCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *starImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starWeigh;
@property (weak, nonatomic) IBOutlet UIImageView *sportImageView;
@property (weak, nonatomic) IBOutlet UILabel *equipLabel;
@property (weak, nonatomic) IBOutlet UILabel *sportNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *muscleLabel;
@property (weak, nonatomic) IBOutlet UILabel *partLabel;

@property (nonatomic, strong) UIColor *themeColor;

@end
