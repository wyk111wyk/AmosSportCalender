//
//  GroupSetStore.m
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/15.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import "GroupSetStore.h"

@implementation GroupSetStore

- (instancetype)init {
    self = [super init];
    if (self) {
        _groupLevel = 1;
        _groupName = @"";
        _groupPart = @"";
    }
    
    return self;
}

@end
