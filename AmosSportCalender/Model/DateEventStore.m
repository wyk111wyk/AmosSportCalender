//
//  DateEventStore.m
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/12.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import "DateEventStore.h"

@implementation DateEventStore

- (instancetype)init {
    self = [super init];
    if (self) {
        _doneCount = 0;
        _doneMins = 0;
    }
    
    return self;
}

@end
