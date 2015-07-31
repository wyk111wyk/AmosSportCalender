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
        
        self.weight = 120;
        self.times = 15;
        self.rap = 6;
        self.timelast = 30;
        self.done = NO;
    }
    
    [self sportEvent];
    
    return self;
}

- (void)sportEvent
{
    NSArray *sportTypes = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sportTypes" ofType:@"plist"]];
    NSMutableArray *MuSportTypes = [NSMutableArray array];
    
    NSArray *chestArray = @[@"平板卧推", @"上斜卧推", @"哑铃飞鸟", @"哑铃卧推", @"俯卧撑"];
    NSArray *backArray = @[@"引体向上", @"俯身划船", @"坐姿下拉", @"杠铃划船", @"器械划船"];
    NSArray *shoulderArray = @[@"哑铃前平举", @"杠铃直立划船", @"哑铃侧弯举", @"杠铃上推", @"俯身哑铃弯举"];
    NSArray *legArray = @[@"杠铃深蹲", @"杠铃箭步蹲", @"哑铃箭步蹲", @"罗汉蹲", @"坐姿提踵"];
    NSArray *staminaArray = @[@"跑步", @"椭圆机", @"游泳", @"登山机", @"HIIT"];
    NSArray *coreArray = @[@"卷腹", @"山羊挺身", @"杠铃硬拉", @"单腿硬拉", @"杠铃高翻+深蹲", @"平板支撑"];
    NSArray *otherArray = @[@"TRX", @"爬楼梯", @"其他运动"];
    
    NSArray *sportNames0 = [NSArray array];
    //生成一个可变数组，用于编辑该项运动的包含运动名称
    NSMutableArray *chestMuArray = [[NSMutableArray alloc] initWithArray:chestArray];
    sportNames0 = [chestMuArray copy];
    NSMutableDictionary *dic0 = [NSMutableDictionary dictionary];
    [dic0 setObject:[sportTypes[0] objectForKey:@"sportType"] forKey:@"sportType"];
    [dic0 setObject:sportNames0 forKey:@"sportName"];
    [MuSportTypes addObject:dic0];
    
    NSArray *sportNames1 = [NSArray array];
    NSMutableArray *backMuArray = [[NSMutableArray alloc] initWithArray:backArray];
    sportNames1 = [backMuArray copy];
    NSMutableDictionary *dic1 = [NSMutableDictionary dictionary];
    [dic1 setObject:[sportTypes[1] objectForKey:@"sportType"] forKey:@"sportType"];
    [dic1 setObject:sportNames1 forKey:@"sportName"];
    [MuSportTypes addObject:dic1];
    
    NSArray *sportNames2 = [NSArray array];
    NSMutableArray *shoulderMuArray = [[NSMutableArray alloc] initWithArray:shoulderArray];
    sportNames2 = [shoulderMuArray copy];
    NSMutableDictionary *dic2 = [NSMutableDictionary dictionary];
    [dic2 setObject:[sportTypes[2] objectForKey:@"sportType"] forKey:@"sportType"];
    [dic2 setObject:sportNames2 forKey:@"sportName"];
    [MuSportTypes addObject:dic2];
    
    NSArray *sportNames3 = [NSArray array];
    NSMutableArray *legMuArray = [[NSMutableArray alloc] initWithArray:legArray];
    sportNames3 = [legMuArray copy];
    NSMutableDictionary *dic3 = [NSMutableDictionary dictionary];
    [dic3 setObject:[sportTypes[3] objectForKey:@"sportType"] forKey:@"sportType"];
    [dic3 setObject:sportNames3 forKey:@"sportName"];
    [MuSportTypes addObject:dic3];
    
    NSArray *sportNames4 = [NSArray array];
    NSMutableArray *staminaMuArray = [[NSMutableArray alloc] initWithArray:staminaArray];
    sportNames4 = [staminaMuArray copy];
    NSMutableDictionary *dic4 = [NSMutableDictionary dictionary];
    [dic4 setObject:[sportTypes[4] objectForKey:@"sportType"] forKey:@"sportType"];
    [dic4 setObject:sportNames4 forKey:@"sportName"];
    [MuSportTypes addObject:dic4];
    
    NSArray *sportNames5 = [NSArray array];
    NSMutableArray *coreMuArray = [[NSMutableArray alloc] initWithArray:coreArray];
    sportNames5 = [coreMuArray copy];
    NSMutableDictionary *dic5 = [NSMutableDictionary dictionary];
    [dic5 setObject:[sportTypes[5] objectForKey:@"sportType"] forKey:@"sportType"];
    [dic5 setObject:sportNames5 forKey:@"sportName"];
    [MuSportTypes addObject:dic5];
    
    NSArray *sportNames6 = [NSArray array];
    NSMutableArray *otherMuArray = [[NSMutableArray alloc] initWithArray:otherArray];
    sportNames6 = [otherMuArray copy];
    NSMutableDictionary *dic6 = [NSMutableDictionary dictionary];
    [dic6 setObject:[sportTypes[6] objectForKey:@"sportType"] forKey:@"sportType"];
    [dic6 setObject:sportNames6 forKey:@"sportName"];
    [MuSportTypes addObject:dic6];
    
    //获取Library目录
    /*  1. document是那些暴露给用户的数据文件，用户可见，可读写；
     2. library目录是App替用户管理的数据文件，对用户透明。所以，那些用户显式访问不到的文件要存储到这里，可读写。*/
    NSFileManager * defaultManager = [NSFileManager defaultManager];
    NSURL * documentPath = [[defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]firstObject];
    
    //新建一个目录存放该文件（如目录不存在，则新建一个）
    NSString * fileContainFloder = [documentPath.path stringByAppendingPathComponent:@"sportEventData"];
    
    //用函数判断该文件夹是否存在（不存在就写入会直接崩溃）
    BOOL isDic = YES;
    if (![defaultManager fileExistsAtPath:fileContainFloder isDirectory:&isDic])
    {   // 假如该文件夹不存在，直接新建一个
        [defaultManager createDirectoryAtPath:fileContainFloder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //设置创建的文件的目录和名字
    NSString * fileSavePath = [fileContainFloder stringByAppendingPathComponent:@"chestArray.plist"];
                               
   BOOL successWrited = [MuSportTypes writeToFile:fileSavePath atomically:YES];
   
   if (successWrited) {
       NSLog(@"已写入plist数据！");
   }else{
       NSLog(@"写入失败！");
   }
}

@end
