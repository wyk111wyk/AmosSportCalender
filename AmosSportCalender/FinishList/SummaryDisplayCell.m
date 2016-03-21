//
//  SummaryDisplayCell.m
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/11.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import "SummaryDisplayCell.h"
#import "CommonMarco.h"

@implementation SummaryDisplayCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.sportTypeLabel.text = [_recordStore.sportPart substringToIndex:1];
    UIColor *partColor = [[ASBaseManage sharedManage] colorForsportType:_recordStore.sportPart];
    self.sportTypeLabel.textColor = partColor;
    [self.sportTypeLabel sizeToFit];
    
    self.sportNameLabel.text = _recordStore.sportName;
    self.timelastLabel.text =[NSString stringWithFormat:Local(@"%d min"), _recordStore.timeLast];
    self.sportAttributeLabel.text = [self setSportAttributeText];
    [self.sportAttributeLabel sizeToFit];
    
    if (!_recordStore.isDone) {
        self.doneImageView.hidden = YES;
        self.backgroundColor = [UIColor whiteColor];
    }else {
        self.doneImageView.hidden = NO;
        self.backgroundColor = [UIColor colorWithWhite:0.97 alpha:0.8];
    }
}

- (NSString *)setSportAttributeText
{
    if (_recordStore.sportType == 1) {
        //抗阻运动
        NSString *unitText = @"";
        SettingStore *setting = [SettingStore sharedSetting];
        if (setting.weightUnit == 0) {
            unitText = @"Kg";
        }else if (setting.weightUnit == 1) {
            unitText = Local(@"lb");
        }
        
        NSString *setLabel = [NSString stringWithFormat:Local(@"%d sets x %d reps  %d%@"), _recordStore.repeatSets, _recordStore.RM, _recordStore.weight, unitText];
        if (_recordStore.weight == 999) {
            setLabel = [NSString stringWithFormat:Local(@"%d sets x %d reps  Self-weight"), _recordStore.repeatSets, _recordStore.RM];
        }
        
        return setLabel;
    }else {
        //有氧或拉伸
        return Local(@"No additional info");
    }
}


@end
