//
//  ASDataManage.m
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/12.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import "ASDataManage.h"
#import "CommonMarco.h"
#import "Event.h"

@implementation ASDataManage

+ (instancetype)sharedManage {
    static ASDataManage *sharedManage = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManage = [[self alloc] init];
    });
    
    return sharedManage;
}

- (void)refreshSportEventsForDate: (NSDate *)selectedDate {
    [[NSNotificationCenter defaultCenter] postNotificationName:RefreshRootPageEventsNotifcation
                                                        object:selectedDate];
}

- (NSString *)getFilePathInLibWithFolder: (NSString *)folderName fileName:(NSString *)fileName {
    NSFileManager * defaultManager = [NSFileManager defaultManager];
    NSURL * libraryPath = [[defaultManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask]firstObject];
    NSString * fileContainFloder = [libraryPath.path stringByAppendingPathComponent:folderName];
    NSString * fileSavePath = [fileContainFloder stringByAppendingPathComponent:fileName];
    
    return fileSavePath;
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

//第一次生成用户数据的时候导入必要的信息
- (void)inputFirstData {
    //数据迁移(从原来的文件传到数据库)
    
    //导入User数据
    NSFileManager * defaultManager = [NSFileManager defaultManager];
    NSURL * libraryPath = [[defaultManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask]firstObject];
    NSString * fileContainFloder = [libraryPath.path stringByAppendingPathComponent:@"userData"];
    BOOL isDic = YES;
    if (![defaultManager fileExistsAtPath:fileContainFloder isDirectory:&isDic])
    {   // 假如该文件夹不存在，直接新建一个
        [defaultManager createDirectoryAtPath:fileContainFloder withIntermediateDirectories:YES attributes:nil error:nil];
        //设置创建的文件的目录和名字
        NSString * fileSavePath = [fileContainFloder stringByAppendingPathComponent:@"UsersChangeLists.plist"];
        NSMutableArray *tempArr = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UsersChangeLists.plist" ofType:nil]];
        //生成第一次的时间
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithDictionary:[tempArr firstObject]];
        NSString *timeStamp = [NSString stringWithFormat:@"%@", @([[NSDate date] timeIntervalSince1970])];
        [tempDic setObject:timeStamp forKey:@"addDate"];
        [tempArr replaceObjectAtIndex:0 withObject:tempDic];
        
        [tempArr writeToFile:fileSavePath atomically:YES];
    }
    
    //导入运动项目到数据库
    NSInteger eventCount = [SportEventStore findCounts:nil];
    if (eventCount == 0) {
        NSArray * partArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AllSystemSportEvents" ofType:@"plist"]];
        for (NSDictionary *tempDic in partArray){
            SportEventStore *newEvent = [SportEventStore new];
            newEvent.isSystemMade = YES;
            newEvent.sportName = [tempDic objectForKey:@"sportName"];
            newEvent.sportEquipment = [tempDic objectForKey:@"sportEquipment"];
            newEvent.muscles = [tempDic objectForKey:@"muscles"];
            newEvent.sportPart = [tempDic objectForKey:@"sportPart"];
            newEvent.sportSerialNum = [tempDic objectForKey:@"sportSerialNum"];
            newEvent.sportType = [[tempDic objectForKey:@"sportType"] integerValue];
            newEvent.imageKey = [tempDic objectForKey:@"imageKey"];
            [newEvent save];
        }
    }
    
    //导入预置组合
    eventCount = [GroupSetStore findCounts:nil];
    if (eventCount == 0) {
        [KVNProgress showWithStatus:Local(@"Transferring data，please wait...")];
        NSArray * setArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"inputGroupSets" ofType:@"plist"]];
        
        for (NSDictionary *tempDic in setArray){
            GroupSetStore *newSet = [GroupSetStore new];
            newSet.groupPart = [tempDic objectForKey:@"groupPart"];
            newSet.groupName = [tempDic objectForKey:@"groupName"];
            newSet.groupLevel = [[tempDic objectForKey:@"groupLevel"] integerValue];
            [newSet save];
        }
        
        NSArray * eventArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"inputGroupEvents" ofType:@"plist"]];
        for (NSDictionary *tempDic in eventArray){
            NSString *setName = [tempDic objectForKey:@"groupSetName"];
            NSString *sportName = [tempDic objectForKey:@"sportName"];
            GroupSetStore *setStore = [GroupSetStore findFirstWithFormat:@" WHERE groupName = '%@' ", setName];
            if (setStore) {
                SportEventStore *eventStore = [SportEventStore findFirstWithFormat:@" WHERE sportName = '%@' ", sportName];
                if (eventStore) {
                    SportRecordStore *newRecord = [SportRecordStore new];
                    newRecord.isGroupSet = YES;
                    newRecord.groupSetPK = setStore.pk;
                    
                    newRecord.sportEquipment = eventStore.sportEquipment;
                    newRecord.sportName = sportName;
                    newRecord.sportSerialNum = eventStore.sportSerialNum;
                    newRecord.sportPart = eventStore.sportPart;
                    newRecord.muscles = eventStore.muscles;
                    newRecord.timeLast = [[tempDic objectForKey:@"timeLast"] intValue];
                    newRecord.repeatSets = [[tempDic objectForKey:@"repeats"] intValue];
                    newRecord.RM = [[tempDic objectForKey:@"times"] intValue];
                    newRecord.weight = [[tempDic objectForKey:@"weight"] intValue];
                    newRecord.sportType = eventStore.sportType;
                    newRecord.datePart = setStore.groupPart;
                    newRecord.isSystemMade = eventStore.isSystemMade;
                    newRecord.imageKey = eventStore.imageKey;
                    
                    [newRecord save];
                }
            }
            [KVNProgress showSuccessWithStatus:Local(@"Data transfer success ")];
        }
    }
    
    [self transferEventsData];
}

- (void)transferEventsData {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories firstObject];
    NSString *dataPath = [documentDirectory stringByAppendingPathComponent:@"event.archive"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        NSDictionary *allOldEvents = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
        
        NSArray *allKeys = [allOldEvents allKeys];
        for (NSString *dateKey in allKeys){
            NSArray *tempArray = [allOldEvents objectForKey:dateKey];
            DateEventStore *newDateEvent = [DateEventStore new];
            newDateEvent.dateKey = dateKey;
            
            for (Event *event in tempArray){
                SportRecordStore *newRecord = [SportRecordStore new];
                NSInteger timeStamp = [event.eventDate timeIntervalSince1970];
                newRecord.eventTimeStamp = timeStamp;
                newRecord.dateKey = dateKey;
                newRecord.sportName = event.sportName;
                newRecord.sportPart = event.sportType;
                if ([newRecord.sportPart isEqualToString:@"耐力"]) {
                    newRecord.sportPart = @"耐力";
                }
                newRecord.weight = event.weight;
                newRecord.RM = event.times;
                newRecord.repeatSets = event.rap;
                newRecord.timeLast = event.timelast;
                newRecord.isDone = event.done;
                
                newRecord.datePart = [[ASDataManage sharedManage] getTheSportPartForRecord:newRecord isNew:YES];
                if (event.done) {
                    newDateEvent.doneCount ++;
                }
                newDateEvent.doneMins += event.timelast;
                newDateEvent.sportPart = newRecord.datePart;
                [newRecord save];
            }
            if (newDateEvent.doneCount > 0) {
                [newDateEvent save];
            }
        }
        //传完之后删了
        [[NSFileManager defaultManager] removeItemAtPath:dataPath error:nil];
        
        NSArray *colorArray = @[[UIColor colorWithRed:0.4000 green:0.7059 blue:0.8980 alpha:1],
                                [UIColor colorWithRed:0.1647 green:0.7451 blue:0.6863 alpha:1],
                                [UIColor colorWithRed:0.0039 green:0.8667 blue:0.8118 alpha:1],
                                [UIColor colorWithRed:0.8745 green:0.7765 blue:0.1412 alpha:1],
                                [UIColor colorWithRed:0.5882 green:0.8667 blue:0.0980 alpha:1],
                                [UIColor colorWithRed:0.4353 green:0.5098 blue:0.8745 alpha:1],
                                [UIColor colorWithRed:0.8824 green:0.4314 blue:0.4824 alpha:1],
                                [UIColor colorWithRed:0.8667 green:0.5451 blue:0.8980 alpha:1],
                                [UIColor colorWithRed:0.9922 green:0.5765 blue:0.1490 alpha:1]];
        NSMutableArray *tempArr = [NSMutableArray array];
        for (UIColor *color in colorArray) {
            CGFloat red, green, blue;
            [color getRed:&red
                    green:&green
                     blue:&blue
                    alpha:nil];
            NSArray *oneColor = @[@(red), @(green), @(blue)];
            [tempArr addObject:oneColor];
        }
        [[SettingStore sharedSetting] setTypeColorArray:tempArr];
    }
    
}

#pragma mark - 智能推荐

//重量
- (int)weightValueWithPart: (NSString *)sportPart data:(NSDictionary *)tempDic
{
    float weight = 30;
    
    float wanju = [tempDic[@"wanju"] floatValue];
    float wotui = [tempDic[@"wutui"] floatValue];
    float shendun = [tempDic[@"shendun"] floatValue];
    float yingla = [tempDic[@"yinla"] floatValue];
    NSString *age = tempDic[@"age"];
    NSInteger purpose = [tempDic[@"purpose"] integerValue];
//    NSInteger frequency = [tempDic[@"frequency"] integerValue];
    
    float weightBase = 0.5;
    if (purpose == 0){
        weightBase = .5;
    }else if (purpose == 1){
        weightBase = .67;
    }else if (purpose == 2){
        weightBase = .85;
    }else if (purpose == 3){
        weightBase = .75;
    }
    
    if ([sportPart isEqualToString:@"胸部"]) {
        if (wotui > 0) {
            weight = wotui * weightBase;
        }
    } else if ([sportPart isEqualToString:@"腿部"]) {
        if (shendun > 0) {
            weight = shendun * weightBase;
        }
    } else if ([sportPart isEqualToString:@"背部"]) {
        if (yingla > 0) {
            weight = yingla * weightBase;
        }
    } else if ([sportPart isEqualToString:@"手臂"] || [sportPart isEqualToString:@"肩部"]) {
        if (wanju > 0) {
            weight = wanju * weightBase;
        }
    } else {
        weight = 30;
    }
    
    if ([age integerValue] < 18 || [age integerValue] > 55) {
        weight *= .85;
    }
    
    for (int i = 0; i < 5; i++) {
        if ((int)weight % 5 != 0) {
            weight = weight + i;
        }
    }
    
    return (int)weight;
}

//次数
- (int)timesValuedata:(NSDictionary *)tempDic
{
    NSInteger purpose = [tempDic[@"purpose"] integerValue];
    int times = 10;
    int i = arc4random() % 5;
    
    if (purpose == 0){
        times = 15 + i;
    }else if (purpose == 1){
        times = 10 + i;
    }else if (purpose == 2){
        times = 5 + i;
    }else if (purpose == 3){
        times = 9 + i;
    }
    
    return times;
}

//组数RM
- (int)rapsValuedata:(NSDictionary *)tempDic
{
    NSInteger stamina = [tempDic[@"stamina"] integerValue];
    NSInteger purpose = [tempDic[@"purpose"] integerValue];
    int raps = 0;
    
    if (purpose == 0){
        raps = 6;
    }else if (purpose == 1){
        raps = 4;
    }else if (purpose == 2){
        raps = 3;
    }else if (purpose == 3){
        raps = 4;
    }
    
    if (stamina == 0) {
        raps -= 1;
    }else if (stamina == 1) {
        
    }else if (stamina == 2) {
        raps += 1;
    }
    
    return raps;
}

@end
