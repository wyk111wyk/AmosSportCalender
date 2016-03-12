//
//  SummaryDisplayCell.h
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/11.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SportRecordStore;

@interface SummaryDisplayCell : UITableViewCell
//Label
@property (weak, nonatomic) IBOutlet UILabel *sportAttributeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sportTypeLabel; ///<取运动项目的第一个字
@property (weak, nonatomic) IBOutlet UILabel *sportNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timelastLabel;

//view
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UIView *bottomLineView;
@property (weak, nonatomic) IBOutlet UIImageView *doneImageView;

@property (nonatomic, strong) SportRecordStore *recordStore;

@end
