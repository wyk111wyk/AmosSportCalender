//
//  SettingStore.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/10.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "SettingStore.h"

static NSString *const kAutoUpDate = @"autoUpDate";
static NSString *const kfirstDayOfWeekKey = @"firstDayOfWeek";
static NSString *const kpassWordOfFingerprintKey = @"passWordOfFingerprint";
static NSString *const ksportTypeImageMaleKey = @"sportTypeImageMale";
static NSString *const kIconBadgeNumber = @"IconBadgeNumber";
static NSString *const kalertForSport = @"alertForSport";
static NSString *const kalertForDays = @"alertForDays";

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
        
        [_userDefaults registerDefaults:@{kfirstDayOfWeekKey: @YES,
                                          kAutoUpDate: @YES,
                                          kpassWordOfFingerprintKey: @NO,
                                          ksportTypeImageMaleKey: @YES,
                                          kIconBadgeNumber: @YES,
                                          kalertForDays: @1,
                                          kalertForSport: @YES}];
        
        _firstDayOfWeek = [_userDefaults boolForKey:kfirstDayOfWeekKey];
        _autoUpDate = [_userDefaults boolForKey:kAutoUpDate];
        _passWordOfFingerprint = [_userDefaults boolForKey:kpassWordOfFingerprintKey];
        _sportTypeImageMale = [_userDefaults boolForKey:ksportTypeImageMaleKey];
        _iconBadgeNumber = [_userDefaults boolForKey:kIconBadgeNumber];
        _alertForSport = [_userDefaults boolForKey:kalertForSport];
        _alertForDays = [_userDefaults integerForKey:kalertForDays];
    }
    return self;
}

- (void)setAlertForDays:(NSInteger)alertForDays
{
    _alertForDays = alertForDays;
    [self.userDefaults setInteger:alertForDays forKey:kalertForDays];
}

- (void)setAlertForSport:(BOOL)alertForSport
{
    _alertForSport = alertForSport;
    [self.userDefaults setBool:alertForSport forKey:kalertForSport];
}

- (void)setFirstDayOfWeek:(BOOL)firstDayOfWeek
{
    _firstDayOfWeek = firstDayOfWeek;
    [self.userDefaults setBool:firstDayOfWeek forKey:kfirstDayOfWeekKey];
}

- (void)setAutoUpDate:(BOOL)autoUpDate
{
    _autoUpDate = autoUpDate;
    [self.userDefaults setBool:autoUpDate forKey:kAutoUpDate];
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
