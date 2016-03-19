//
//  PersonInfoStore.h
//  AmosSportDiary
//
//  Created by Amos Wu on 15/8/26.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersonInfoStore : NSObject

+ (instancetype)sharedSetting;

@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *age;
@property (nonatomic, strong)NSString *gender;

@property (nonatomic, strong)NSString *sqdataName;

@property (nonatomic, strong)NSString *defaultSportType;
@property (nonatomic, strong)NSString *defaultSportName;

@property (nonatomic)float wanjuWeight;
@property (nonatomic)float woutuiWeight;
@property (nonatomic)float shengdunWeight;
@property (nonatomic)float yinglaWeight;

@property (nonatomic)float purpose;
@property (nonatomic)float stamina;
@property (nonatomic)float frequency;

@end
