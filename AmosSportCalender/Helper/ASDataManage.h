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

//第一次生成用户数据的时候导入必要的信息
- (void)inputFirstData;

//获取文件路径
- (NSString *)getFilePathInLibWithFolder: (NSString *)folderName fileName:(NSString *)fileName;
- (void)refreshSportEventsForDate: (NSDate *)selectedDate;

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

//重量
- (int)weightValueWithPart: (NSString *)sportPart data:(NSDictionary *)tempDic;
//次数
- (int)timesValuedata:(NSDictionary *)tempDic;
//组数RM
- (int)rapsValuedata:(NSDictionary *)tempDic;

@end
