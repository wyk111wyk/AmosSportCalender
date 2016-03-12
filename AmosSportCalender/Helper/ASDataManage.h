//
//  ASDataManage.h
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/12.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SportRecordStore;

@interface ASDataManage : NSObject

+ (instancetype)sharedManage;

//获取所有已完成的运动数组
- (NSMutableDictionary *)getAllDoneSportEventDataWithLimit: (int)limit;
- (NSArray *)getAllSortedKey: (NSMutableDictionary *)AllDoneDic;
//将xx-xx-xxxx格式的时间进行排序
- (NSArray *)sortDateString: (NSArray *)inputArray;

//新建或者某日的运动完成情况
- (void)addNewDateEventRecord: (SportRecordStore *)recordStore;
//去掉一个
- (void)editDateEventRecord: (SportRecordStore *)recordStore;

//根据一个记录算出当天的运动部位, 并将记录都改掉
- (NSString *)getTheSportPartForRecord: (SportRecordStore *)recordStore isNew:(BOOL)isNew;

@end
