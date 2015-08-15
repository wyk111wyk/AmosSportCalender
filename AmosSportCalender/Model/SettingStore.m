//
//  SettingStore.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/10.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "SettingStore.h"

static NSString *const kNameKey = @"name";
static NSString *const kAgeKey = @"age";
static NSString *const kGenderKey = @"gender";
static NSString *const kiCloudKey = @"iCloud";
static NSString *const kpassWordOfFingerprintKey = @"passWordOfFingerprint";
static NSString *const ksportTypeImageMaleKey = @"sportTypeImageMale";
static NSString *const kIconBadgeNumber = @"IconBadgeNumber";

@interface SettingStore()

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation SettingStore

+ (instancetype)sharedSetting
{
    static SettingStore *sharedSetting = nil;
    
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
                                          kiCloudKey: @NO,
                                          kpassWordOfFingerprintKey: @NO,
                                          ksportTypeImageMaleKey: @YES,
                                          kIconBadgeNumber: @YES}];
        
        _name = [_userDefaults stringForKey:kNameKey];
        _age = [_userDefaults stringForKey:kAgeKey];
        _gender = [_userDefaults stringForKey:kGenderKey];
        _iCloud = [_userDefaults boolForKey:kiCloudKey];
        _passWordOfFingerprint = [_userDefaults boolForKey:kpassWordOfFingerprintKey];
        _sportTypeImageMale = [_userDefaults boolForKey:ksportTypeImageMaleKey];
        _iconBadgeNumber = [_userDefaults boolForKey:kIconBadgeNumber];
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

- (void)setICloud:(BOOL)iCloud
{
    _iCloud = iCloud;
    [self.userDefaults setBool:iCloud forKey:kiCloudKey];
}

- (void)setPassWordOfFingerprint:(BOOL)passWordOfFingerprint
{
    _passWordOfFingerprint = passWordOfFingerprint;
    [self.userDefaults setBool:passWordOfFingerprint forKey:kpassWordOfFingerprintKey];
}

- (void)setSportTypeImageMale:(BOOL)sportTypeImageMale
{
    _sportTypeImageMale = sportTypeImageMale;
    [self.userDefaults setBool:sportTypeImageMale forKey:ksportTypeImageMaleKey];
}

- (void)setIconBadgeNumber:(BOOL)iconBadgeNumber
{
    _iconBadgeNumber = iconBadgeNumber;
    [self.userDefaults setBool:iconBadgeNumber forKey:kIconBadgeNumber];
}

@end
