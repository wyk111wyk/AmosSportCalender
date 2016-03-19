//
//  PersonalInfoCell.h
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/18.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonalInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createDateLabel;
@property (nonatomic) BOOL isMain;
@property (nonatomic, strong) NSString *userDataName;

@end
