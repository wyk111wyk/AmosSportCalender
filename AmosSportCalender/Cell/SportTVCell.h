//
//  SportTVCell.h
//  AmosSportCalender
//
//  Created by Amos Wu on 15/7/28.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@class SportRecordStore;

@interface SportTVCell : MGSwipeTableCell

@property (weak, nonatomic) IBOutlet UIView *iconRootView;
@property (weak, nonatomic) IBOutlet UILabel *timelastLabel;
@property (weak, nonatomic) IBOutlet UILabel *markLabel;

@property (weak, nonatomic) IBOutlet UILabel *sportName; ///<项目名称
@property (weak, nonatomic) IBOutlet UILabel *sportType; ///<部位
@property (weak, nonatomic) IBOutlet UILabel *sportPro; ///<运动项目属性

@property (weak, nonatomic) IBOutlet UIImageView *donePic;

@property (nonatomic, strong) SportRecordStore *recordStore;

@end
