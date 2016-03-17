//
//  SportEventStore.h
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/9.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JKDBModel.h"

@interface SportEventStore : JKDBModel

@property (nonatomic, strong) NSString *sportName; ///<运动的名称
@property (nonatomic, strong) NSString *sportPart; ///<运动的部位
@property (nonatomic, strong) NSString *muscles; ///<肌肉
@property (nonatomic, strong) NSString *sportEquipment; ///<运动器械
@property (nonatomic, strong) NSString *sportSerialNum; ///<该运动编号

@property (nonatomic) NSInteger sportType; ///<运动的类型：0=有氧、1=抗阻、2=拉伸
@property (nonatomic) BOOL isSystemMade; ///<是否系统自带的
@property (nonatomic) BOOL isStar; ///<是否加星标

@property (nonatomic, copy) NSString *imageKey; ///<储存图片用的唯一编码
@property (nonatomic) int rootPKGroup;

@end
