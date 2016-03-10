//
//  SportRecordStore.h
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/9.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JKDBModel.h"

@interface SportRecordStore : JKDBModel

@property (nonatomic) NSInteger eventTimeStamp; ///<事件安排的时间
@property (nonatomic, strong) NSString *dateKey; ///<xxxx-xx-xx
@property (nonatomic, strong) NSString *sportName; ///<运动的名称
@property (nonatomic, strong) NSString *sportPart; ///<运动的部位
@property (nonatomic, strong) NSString *muscles; ///<肌肉
@property (nonatomic, strong) NSString *sportEquipment; ///<运动器械
@property (nonatomic, strong) NSString *sportSerialNum; ///<该运动编号

@property (nonatomic) NSInteger sportType; ///<运动的类型：0=有氧、1=抗阻、2=拉伸
@property (nonatomic) BOOL isSystemMade; ///<是否系统自带的
@property (nonatomic) int weight; ///<重量（kg）
@property (nonatomic) int RM; ///<每组做多少次（12-15）
@property (nonatomic) int repeatSets; ///<做多少组（3-6）
@property (nonatomic) int timeLast; ///<运动的持续时间(分钟)

@property (nonatomic) BOOL isDone; ///<是否完成该事件
@property (nonatomic, strong) NSString *imageKey; ///<储存图片用的唯一编码

@property (nonatomic) NSInteger doneTimeStamp;

@end
