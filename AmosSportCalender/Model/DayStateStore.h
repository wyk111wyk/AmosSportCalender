//
//  DayStateStore.h
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/9.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKDBModel.h"

@interface DayStateStore : JKDBModel

@property (nonatomic) BOOL hasAllDone;
@property (nonatomic) BOOL hasEvents;
@property (nonatomic, strong) NSString *dayPart;
@property (nonatomic) NSInteger dayPartIndex;
@property (nonatomic, strong) NSString *dayKey;

@end
