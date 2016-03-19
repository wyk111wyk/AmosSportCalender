//
//  PersonalDataStore.h
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/18.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKDBModel.h"

@interface PersonalDataStore : NSObject

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
