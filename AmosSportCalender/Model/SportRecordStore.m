//
//  SportRecordStore.m
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/9.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import "SportRecordStore.h"
#import "ASBaseManage.h"

@implementation SportRecordStore

- (instancetype)init {
    self = [super init];
    if (self) {
        _eventTimeStamp = [[NSDate date] timeIntervalSince1970];
        _dateKey = [[ASBaseManage dateFormatterForDMY] stringFromDate:[NSDate date]];
        _isDone = NO;
        _isSystemMade = NO;
        _datePart = @"";
        _isGroupSet = NO;
        _groupSetPK = -1;
        _doneSets = 0;
    }
    
    return self;
}

@end
