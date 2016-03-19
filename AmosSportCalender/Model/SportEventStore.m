//
//  SportEventStore.m
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/9.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import "SportEventStore.h"

@implementation SportEventStore

- (instancetype)init {
    self = [super init];
    if (self) {
        _sportName = @"";
        _sportEquipment = @"";
        _sportPart = @"";
        _muscles = @"";
        _sportSerialNum = @"";
        _sportTips = @"";
        NSUUID *uuid = [NSUUID new];
        NSString *key = [uuid UUIDString];
        _imageKey = key;
        _isSystemMade = NO;
        _isStar = NO;
        _rootPKGroup = -1;
    }
    
    return self;
}

@end
