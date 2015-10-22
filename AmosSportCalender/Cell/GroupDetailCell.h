//
//  GroupDetailCell.h
//  AmosSportDiary
//
//  Created by Amos Wu on 15/10/4.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface GroupDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *sportName; ///<项目名称
@property (weak, nonatomic) IBOutlet UILabel *sportType; ///<类别
@property (weak, nonatomic) IBOutlet UILabel *sportPro; ///<运动项目属性
@property (weak, nonatomic) IBOutlet UILabel *timelastLabel;

@property (nonatomic, strong) Event *event;

@end
