//
//  Event.h
//  AmosSportCalender
//
//  Created by Amos Wu on 15/7/25.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JKDBModel.h"

@interface Event : NSObject<NSCoding>

@property (nonatomic, strong) NSDate *eventDate; ///<事件的时间
@property (nonatomic, strong) NSString *sportName; ///<运动的名称
@property (nonatomic, strong) NSString *sportType; ///<运动的类型（选项）
@property (nonatomic) float weight; ///<重量（kg）
@property (nonatomic) int times; ///<每组做多少次（12-15）
@property (nonatomic) int rap; ///<做多少组（3-6）
@property (nonatomic) int timelast; ///<运动的持续时间
@property (nonatomic) int timesDone; ///<已经完成的次数

@property (nonatomic) BOOL done; ///<是否完成该事件
@property (nonatomic, copy) NSString *itemKey; ///<储存图片用的唯一编码

@property (nonatomic, copy) NSString *groupBelong; ///<属于哪一个类别
@property (nonatomic, copy) NSString *groupName; ///<该运动组合的名称

@end
