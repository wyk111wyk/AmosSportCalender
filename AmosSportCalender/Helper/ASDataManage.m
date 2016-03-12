//
//  ASDataManage.m
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/12.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import "ASDataManage.h"
#import "CommonMarco.h"

@implementation ASDataManage

+ (instancetype)sharedManage {
    static ASDataManage *sharedManage = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManage = [[self alloc] init];
    });
    
    return sharedManage;
}

- (void)addNewDateEventRecord: (SportRecordStore *)recordStore {
    DateEventStore *dateStore = [DateEventStore findFirstWithFormat:@" WHERE dateKey = '%@' ", recordStore.dateKey];
    if (dateStore) {
        dateStore.doneCount ++;
        dateStore.doneMins += recordStore.timeLast;
        dateStore.sportPart = recordStore.datePart;
        [dateStore update];
    }else {
        dateStore = [DateEventStore new];
        dateStore.dateKey = recordStore.dateKey;
        dateStore.doneCount = 1;
        dateStore.doneMins = recordStore.timeLast;
        dateStore.sportPart = recordStore.datePart;
        [dateStore save];
    }
}

//去掉一个
- (void)editDateEventRecord: (SportRecordStore *)recordStore {
    DateEventStore *dateStore = [DateEventStore findFirstWithFormat:@" WHERE dateKey = '%@' ", recordStore.dateKey];
    if (dateStore) {
        dateStore.doneCount --;
        dateStore.doneMins -= recordStore.timeLast;
        if (dateStore.doneCount == 0) {
            [dateStore deleteObject];
        }else if (dateStore.doneCount > 0) {
            [dateStore update];
        }
    }
}

//根据一个记录算出当天的运动部位, 并将记录都改掉
- (NSString *)getTheSportPartForRecord: (SportRecordStore *)recordStore isNew:(BOOL)isNew {
    NSMutableArray *dateEvents = [[NSMutableArray alloc] initWithArray:[SportRecordStore findWithFormat:@" WHERE dateKey = '%@' ", recordStore.dateKey]];
    NSString *datePart = recordStore.sportPart;
    if (dateEvents.count > 0) {
        if (isNew) {
            [dateEvents addObject:recordStore];
        }
        datePart = [[ASBaseManage sharedManage] findTheMaxOfTypes:dateEvents];
        for (SportRecordStore *tempStore in dateEvents){
            tempStore.datePart = datePart;
            [tempStore update];
        }
    }
    return datePart;
}

//获取所有已完成的运动数组
- (NSMutableDictionary *)getAllDoneSportEventDataWithLimit: (int)limit {
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    NSString *limitStr = @"";
    if (limit > 0) {
        limitStr = [NSString stringWithFormat:@" LIMIT %d ", limit];
    }
    NSString *criStr = [NSString stringWithFormat:@" WHERE isDone = '1' ORDER BY eventTimeStamp %@", limitStr];
    NSArray *allDoneEventData = [SportRecordStore findByCriteria:criStr];
    
    for (SportRecordStore *recordStore in allDoneEventData){
        NSString *dateKey = recordStore.dateKey;
        [self checkDicObject:tempDic key:dateKey];
        NSMutableArray *tempArr = [tempDic objectForKey:dateKey];
        [tempArr addObject:recordStore];
    }
    
    return tempDic;
}

- (BOOL)checkDicObject:(NSMutableDictionary *)tempDic key:(NSString *)keyStr {
    if ([tempDic objectForKey:keyStr]) {
        return YES;
    }else {
        NSMutableArray *tempArr = [NSMutableArray array];
        [tempDic setObject:tempArr forKey:keyStr];
        return NO;
    }
}

- (NSArray *)getAllSortedKey: (NSMutableDictionary *)AllDoneDic {
    NSArray *tempArray = [AllDoneDic allKeys];
    return [self sortDateString:tempArray];
}

//将xx-xx-xxxx格式的时间进行排序
- (NSArray *)sortDateString: (NSArray *)inputArray {
    NSMutableArray *tempEventArray = [NSMutableArray array];
    NSMutableArray *newTempArray = [NSMutableArray array];
    
    for (NSString *str in inputArray){
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        tempDic[@"year"] = [str substringWithRange:NSMakeRange(6, 4)];
        tempDic[@"month"] = [str substringWithRange:NSMakeRange(3, 2)];
        tempDic[@"day"] = [str substringToIndex:2];
        [tempEventArray addObject:tempDic];
    }
    
    //对日期进行排序
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"year" ascending:NO];
    NSSortDescriptor *secondDescriptor = [[NSSortDescriptor alloc] initWithKey:@"month" ascending:NO];
    NSSortDescriptor *thirdDescriptor = [[NSSortDescriptor alloc] initWithKey:@"day" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:firstDescriptor, secondDescriptor, thirdDescriptor,nil];
    NSArray *afterSortedArray = [tempEventArray sortedArrayUsingDescriptors:sortDescriptors];
    
    for (NSMutableDictionary *temDic in afterSortedArray){
        NSString *tempStr = [NSString stringWithFormat:@"%@-%@-%@", temDic[@"day"], temDic[@"month"], temDic[@"year"]];
        [newTempArray addObject:tempStr];
    }
    
    return newTempArray.copy;
}

@end
