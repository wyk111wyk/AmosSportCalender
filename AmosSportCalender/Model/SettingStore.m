//
//  SettingStore.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/10.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "SettingStore.h"
#import "CommonMarco.h"

static NSString *const kAutoUpDate = @"autoUpDate";
static NSString *const kfirstDayOfWeekKey = @"firstDayOfWeek";
static NSString *const isTouchIDOnKey = @"isTouchIDOn";
static NSString *const ksportTypeImageMaleKey = @"sportTypeImageMale";
static NSString *const kIconBadgeNumber = @"IconBadgeNumber";
static NSString *const kalertForSport = @"alertForSport";
static NSString *const kalertForDays = @"alertForDays";
static NSString *const kTypeColorArray = @"TypeColorArray";
static NSString *const weightUnitKey = @"weightUnit";

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
    
    [self setTheColorArray];
    
    if (self) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
        
        [_userDefaults registerDefaults:@{kfirstDayOfWeekKey: @YES,
                                          kAutoUpDate: @YES,
                                          isTouchIDOnKey: @NO,
                                          ksportTypeImageMaleKey: @YES,
                                          kIconBadgeNumber: @YES,
                                          kalertForDays: @1,
                                          kalertForSport: @YES,
                                          kTypeColorArray: _typeColorArray,
                                          weightUnitKey: @0}];
        
        _typeColorArray = [_userDefaults objectForKey:kTypeColorArray];
        _firstDayOfWeek = [_userDefaults boolForKey:kfirstDayOfWeekKey];
        _autoUpDate = [_userDefaults boolForKey:kAutoUpDate];
        _isTouchIDOn = [_userDefaults boolForKey:isTouchIDOnKey];
        _sportTypeImageMale = [_userDefaults boolForKey:ksportTypeImageMaleKey];
        _iconBadgeNumber = [_userDefaults boolForKey:kIconBadgeNumber];
        _alertForSport = [_userDefaults boolForKey:kalertForSport];
        _alertForDays = [_userDefaults integerForKey:kalertForDays];
        _weightUnit = [_userDefaults integerForKey:weightUnitKey];
    }
    return self;
}

- (void)setTypeColorArray:(NSMutableArray *)typeColorArray
{
    _typeColorArray = typeColorArray;
    [self.userDefaults setObject:typeColorArray forKey:kTypeColorArray];
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

- (void)setIsTouchIDOn:(BOOL)isTouchIDOn
{
    _isTouchIDOn = isTouchIDOn;
    [self.userDefaults setBool:isTouchIDOn forKey:isTouchIDOnKey];
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

- (void)setTheColorArray
{
    if (!self.typeColorArray) {
        self.typeColorArray = [NSMutableArray array];
    }
    
    NSArray *colorArray = @[[UIColor colorWithRed:0.4000 green:0.7059 blue:0.8980 alpha:1],
                            [UIColor colorWithRed:0.1647 green:0.7451 blue:0.6863 alpha:1],
                            [UIColor colorWithRed:0.0039 green:0.8667 blue:0.8118 alpha:1],
                            [UIColor colorWithRed:0.8745 green:0.7765 blue:0.1412 alpha:1],
                            [UIColor colorWithRed:0.5882 green:0.8667 blue:0.0980 alpha:1],
                            [UIColor colorWithRed:0.4353 green:0.5098 blue:0.8745 alpha:1],
                            [UIColor colorWithRed:0.8824 green:0.4314 blue:0.4824 alpha:1],
                            [UIColor colorWithRed:0.8667 green:0.5451 blue:0.8980 alpha:1],
                            [UIColor colorWithRed:0.9922 green:0.5765 blue:0.1490 alpha:1]];
    
    for (UIColor *color in colorArray){
        CGFloat red, green, blue;
        [color getRed:&red
                green:&green
                 blue:&blue
                alpha:nil];
        NSArray *oneColor = @[@(red), @(green), @(blue)];
        [self.typeColorArray addObject:oneColor];
    }
}

- (void)setWeightUnit:(NSInteger)weightUnit {
    _weightUnit = weightUnit;
    [self.userDefaults setInteger:weightUnit forKey:weightUnitKey];
}

@end
