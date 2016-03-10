//
//  SportRecordStore.m
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/9.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import "SportRecordStore.h"

@implementation SportRecordStore

- (instancetype)init {
    self = [super init];
    if (self) {
        _eventTimeStamp = [[NSDate date] timeIntervalSince1970];
        _isDone = NO;
        _isSystemMade = NO;
    }
    
    return self;
}

@end
