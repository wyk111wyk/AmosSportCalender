//
//  SportTVCell.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/7/28.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "SportTVCell.h"
#import "CommonMarco.h"
#import "SettingStore.h"

@implementation SportTVCell

- (void)awakeFromNib {
    _iconRootView.layer.borderWidth = 0.7;
    _iconRootView.layer.borderColor = MYBlueColor.CGColor;
    _couldBeDone = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (_recordStore) {
        UIColor *partColor = [[ASBaseManage sharedManage] colorForsportType:_recordStore.sportPart];
        _iconRootView.layer.borderColor = partColor.CGColor;
        _sportType.text = _recordStore.sportPart;
        _sportName.text = _recordStore.sportName;
        
        if (_recordStore.sportType == 1) {
            //抗阻运动
            _markLabel.text = @"Done";
            _timelastLabel.text = [NSString stringWithFormat:@"%d", _recordStore.doneSets];
            
            NSString *unitText = @"";
            SettingStore *setting = [SettingStore sharedSetting];
            if (_recordStore.weight == 999){
                //不变
            }else if (setting.weightUnit == 0) {
                unitText = @"Kg";
            }else if (setting.weightUnit == 1) {
                unitText = Local(@"lb");
            }
            self.sportPro.text = [NSString stringWithFormat:Local(@"%d sets x %d reps  %d%@"), _recordStore.repeatSets, _recordStore.RM, _recordStore.weight, unitText];
            if (_recordStore.weight == 999) {
                self.sportPro.text = [NSString stringWithFormat:Local(@"%d sets x %d reps  Self-weight"), _recordStore.repeatSets, _recordStore.RM];
            }
        }else {
            //有氧或拉伸
            self.sportPro.text = @"Go！Go！Go！";
            _markLabel.text = @"Min";
            _timelastLabel.text = [NSString stringWithFormat:@"%d", _recordStore.timeLast];
        }
        
        if (_recordStore.isDone) {
            self.backgroundColor = [UIColor colorWithRed:0.8980 green:0.8980 blue:0.8980 alpha:0.9];
            self.donePic.hidden = NO;
            self.sportType.textColor = [UIColor grayColor];
            self.sportName.textColor = [UIColor grayColor];
            self.sportPro.textColor = [UIColor grayColor];
        }else {
            self.backgroundColor = [UIColor whiteColor];
            self.donePic.hidden = YES;
            self.sportName.textColor = [UIColor blackColor];
            self.sportPro.textColor = [UIColor lightGrayColor];
            self.sportType.textColor = partColor;
        }
    }
}

@end
