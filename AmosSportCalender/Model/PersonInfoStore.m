//
//  PersonInfoStore.m
//  AmosSportDiary
//
//  Created by Amos Wu on 15/8/26.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "PersonInfoStore.h"

static NSString *const kNameKey = @"name";
static NSString *const kAgeKey = @"age";
static NSString *const kGenderKey = @"gender";
static NSString *const kWanju = @"wanjuWeight";
static NSString *const kWoutui = @"woutuiWeight";
static NSString *const kShengdun = @"shengdunWeight";
static NSString *const kYingla = @"yinglaWeight";
static NSString *const kPurpose = @"purpose";
static NSString *const kStamina = @"stamina";
static NSString *const kFrequency = @"frequency";

@interface PersonInfoStore()

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation PersonInfoStore

+ (instancetype)sharedSetting
{
    static PersonInfoStore *sharedSetting = nil;
    
    //在多线程中创建线程安全的单例（thread-safe singleton）
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedSetting = [[self alloc] init];
    });
    
    return sharedSetting;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
        
        [_userDefaults registerDefaults:@{kNameKey: @(""),
                                          kAgeKey: @(""),
                                          kGenderKey: @(""),
                                          kWanju: @0,
                                          kWoutui: @0,
                                          kShengdun: @0,
                                          kYingla: @0,
                                          kPurpose: @0,
                                          kStamina: @0,
                                          kFrequency: @0
                                          }];
        
        _name = [_userDefaults stringForKey:kNameKey];
        _age = [_userDefaults stringForKey:kAgeKey];
        _gender = [_userDefaults stringForKey:kGenderKey];
        
        _wanjuWeight = [_userDefaults floatForKey:kWanju];
        _woutuiWeight = [_userDefaults floatForKey:kWoutui];
        _shengdunWeight = [_userDefaults floatForKey:kShengdun];
        _yinglaWeight = [_userDefaults floatForKey:kYingla];
        
        _purpose = [_userDefaults floatForKey:kPurpose];
        _stamina = [_userDefaults floatForKey:kStamina];
        _frequency = [_userDefaults floatForKey:kFrequency];
        
    }
    return self;
}

- (void)setName:(NSString *)name
{
    _name = name;
    [self.userDefaults setObject:name forKey:kNameKey];
}

- (void)setAge:(NSString *)age
{
    _age = age;
    [self.userDefaults setObject:age forKey:kAgeKey];
}

- (void)setGender:(NSString *)gender
{
    _gender = gender;
    
    [self.userDefaults setObject:gender forKey:kGenderKey];
}

- (void)setWanjuWeight:(float)wanjuWeight
{
    _wanjuWeight = wanjuWeight;
    [self.userDefaults setFloat:wanjuWeight forKey:kWanju];
}

- (void)setWoutuiWeight:(float)woutuiWeight
{
    _woutuiWeight = woutuiWeight;
    [self.userDefaults setFloat:woutuiWeight forKey:kWoutui];
}

- (void)setShengdunWeight:(float)shengdunWeight
{
    _shengdunWeight = shengdunWeight;
    [self.userDefaults setFloat:shengdunWeight forKey:kShengdun];
}

- (void)setYinglaWeight:(float)yinglaWeight
{
    _yinglaWeight = yinglaWeight;
    [self.userDefaults setFloat:yinglaWeight forKey:kYingla];
}

- (void)setPurpose:(float)purpose
{
    _purpose = purpose;
    [self.userDefaults setFloat:purpose forKey:kPurpose];
}

- (void)setStamina:(float)stamina
{
    _stamina = stamina;
    [self.userDefaults setFloat:stamina forKey:kStamina];
}

- (void)setFrequency:(float)frequency
{
    _frequency = frequency;
    [self.userDefaults setFloat:frequency forKey:kFrequency];
}

@end
