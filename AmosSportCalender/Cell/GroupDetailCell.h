//
//  GroupDetailCell.h
//  AmosSportDiary
//
//  Created by Amos Wu on 15/10/4.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *groupSetName;
@property (weak, nonatomic) IBOutlet UILabel *numOfEvent;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIView *levelBGView;


@end
