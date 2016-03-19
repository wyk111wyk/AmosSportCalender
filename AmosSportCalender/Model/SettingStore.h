//
//  SettingStore.h
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/10.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface SettingStore : NSObject

+ (instancetype)sharedSetting;

@property (nonatomic)BOOL autoUpDate;
@property (nonatomic)BOOL firstDayOfWeek;
@property (nonatomic)BOOL isTouchIDOn;
@property (nonatomic)BOOL sportTypeImageMale;
@property (nonatomic)BOOL iconBadgeNumber;
@property (nonatomic)BOOL alertForSport;
@property (nonatomic)NSInteger alertForDays;
@property (nonatomic)NSInteger weightUnit; ///<0=kg 1=lb
@property (nonatomic, strong)NSMutableArray *typeColorArray;

@property (nonatomic, strong)NSString *userDataName;
@property (nonatomic, strong)NSString *userName;

@end
