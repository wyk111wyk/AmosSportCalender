//
//  Event.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/7/25.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "Event.h"

@interface Event()

@end

@implementation Event

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        self.sportType = @"胸部";
        self.sportName = @"平板卧推";
        
        self.weight = 30;
        self.times = 15;
        self.rap = 3;
        self.timelast = 15;
        self.done = NO;
        
        //    生成一个唯一的标识（UUID），用作保存图片的key
        NSUUID *uuid = [NSUUID new];
        NSString *key = [uuid UUIDString];
        self.itemKey = key;
    }
    
    return self;
}

//18.1 持久化的方法
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.eventDate forKey:@"eventDate"];
    [aCoder encodeObject:self.sportName forKey:@"sportName"];
    [aCoder encodeObject:self.sportType forKey:@"sportType"];
    [aCoder encodeObject:self.itemKey forKey:@"itemKey"];
    
    [aCoder encodeFloat:self.weight forKey:@"weight"];
    [aCoder encodeInt:self.times forKey:@"times"]; //Int类型编码
    [aCoder encodeInt:self.rap forKey:@"rap"];
    [aCoder encodeInt:self.timelast forKey:@"timelast"];
    [aCoder encodeInt:self.timesDone forKey:@"timesDone"];
    
    [aCoder encodeBool:self.done forKey:@"done"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.eventDate = [aDecoder decodeObjectForKey:@"eventDate"];
        self.sportName = [aDecoder decodeObjectForKey:@"sportName"];
        self.sportType = [aDecoder decodeObjectForKey:@"sportType"];
        self.itemKey = [aDecoder decodeObjectForKey:@"itemKey"];
        
        self.weight = [aDecoder decodeFloatForKey:@"weight"];
        self.times = [aDecoder decodeIntForKey:@"times"];
        self.rap = [aDecoder decodeIntForKey:@"rap"];
        self.timelast = [aDecoder decodeIntForKey:@"timelast"];
        self.timesDone = [aDecoder decodeIntForKey:@"timesDone"];
        
        self.done = [aDecoder decodeBoolForKey:@"done"];
    }
    return self;
}

@end
