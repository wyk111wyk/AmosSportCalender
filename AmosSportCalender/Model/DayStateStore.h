//
//  DayStateStore.h
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/9.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DayStateStore : NSObject

@property (nonatomic) BOOL hasAllDone;
@property (nonatomic) NSInteger allEventNum;
@property (nonatomic) NSInteger allDoneNum;
@property (nonatomic, strong) NSString *dayType;
@property (nonatomic, strong) NSString *dayKey;

@end
