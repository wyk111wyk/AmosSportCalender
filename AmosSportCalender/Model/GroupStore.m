//
//  GroupStore.m
//  AmosSportDiary
//
//  Created by Amos Wu on 15/9/29.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "GroupStore.h"
#import "Event.h"

@interface GroupStore()

@end

@implementation GroupStore

+ (instancetype)sharedStore
{
    static GroupStore *sharedStore = nil;
    
    //在多线程中创建线程安全的单例（thread-safe singleton）
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });
    
    return sharedStore;
}

//让其他类无法调用默认的初始化方法
- (instancetype)init
{
    @throw [NSException exceptionWithName:@"SingLeton"
                                   reason:@"Use +[EventStore sharedStore]"
                                 userInfo:nil];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    
    //7. 实现initPrivateItems方法，初始化属性
    if (self) {
        
        //18.3 在启动时载入之前保存的YKItem对象
        NSString *path = [self itemArchivePath];
        self.privateEvents = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        //如果没有读取到保存的数据，就创建新的
        if (!self.privateEvents) {
            self.privateEvents = [NSMutableDictionary dictionary];
        }
    }
    
    return self;
}

- (NSDictionary *)allItems
{
    return [self.privateEvents copy];
}

- (void)updateAllData
{
    NSString *path = [self itemArchivePath];
    self.privateEvents = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

- (void)createGroup:(NSString *)belong groupName:(NSString *)name
{
    NSString *key1 = belong;
    NSString *key2 = name;
    
    if (!self.privateEvents[key1]) {
        self.privateEvents[key1] = [NSMutableDictionary dictionary];
    }
    
    //需要在业务端先检查是否有重复key2
    if (!self.privateEvents[key1][key2]) {
        self.privateEvents[key1][key2] = [NSMutableArray array];
    }
    
}

- (Event *)createItem
{
    Event *event = [[Event alloc] init];
    return event;
}

- (void)createItemInGroup:(Event *)event belong:(NSString *)belong groupName:(NSString *)name
{
    NSString *key1 = belong;
    NSString *key2 = name;
    
    if (event) {
        event.groupBelong = belong;
        
        if (!self.privateEvents[key1][key2]) {
            self.privateEvents[key1][key2] = [NSMutableArray array];
        }
        
        [self.privateEvents[key1][key2] addObject:event];
    }
}

- (void)editTheNameOfGroup:(NSString *)belong groupName:(NSString *)name newName:(NSString *)newName
{
    NSString *key1 = belong;
    NSString *key2 = name;
    
    if (self.privateEvents[key1][key2]) {
        
        NSMutableArray *array = self.privateEvents[key1][key2];
        [self.privateEvents[key1] removeObjectForKey:key2];
        [self.privateEvents[key1] setObject:array forKey:newName];
    }
    
}

- (void)removeGroup:(NSString *)belong groupName:(NSString *)name
{
    NSString *key1 = belong;
    NSString *key2 = name;
    
    if (self.privateEvents[key1][key2]) {
        [self.privateEvents[key1] removeObjectForKey:key2];
    }
}

//实现删除行的方法
- (void)removeItemInGroup:(Event *)event belong:(NSString *)belong groupName:(NSString *)name
{
    NSString *key1 = belong;
    NSString *key2 = name;
    
    //removeObjectIdenticalTo:方法
    if (self.privateEvents[key1][key2]) {
        [self.privateEvents[key1][key2] removeObjectIdenticalTo:event];
    }

}

- (void)removeAllItem
{
    [self.privateEvents removeAllObjects];
}

//实现移动数据的方法
- (void)moveItemAtIndex:(NSUInteger)fromIndex
               toIndex :(NSUInteger)toIndex
                 belong:(NSString *)belong
              groupName:(NSString *)name
{
    //    NSLog(@"group 移动数据库顺序");
    NSString *key1 = belong;
    NSString *key2 = name;
    
    if (fromIndex == toIndex) {
        return;
    }
    //得到需要移动的对象的指针，以便稍后能将其插入新的位置
    if ([self.privateEvents[key1][key2] isKindOfClass:[NSMutableArray class]]) {
        
        Event *event = self.privateEvents[key1][key2][fromIndex];
        
        //将item从allItems数组中移除
        [self.privateEvents[key1][key2] removeObjectAtIndex:fromIndex];
        
        //根据新的索引位置，将item插回allItems数组
        [self.privateEvents[key1][key2] insertObject:event atIndex:toIndex];
    }
}

//18.2 将对象保存至Doc目录中的某个文件，以及读取
- (NSString *)itemArchivePath
{
    //通过该方法获取Doc目录的全路径，三个实参：（指定目录）
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories firstObject];
    
    //最终获取了储存的指定目录
    return [documentDirectory stringByAppendingPathComponent:@"group.archive"];
}

- (BOOL)saveGroupData //储存数据到本地的方法！
{
    NSString *path = [self itemArchivePath];
    return [NSKeyedArchiver archiveRootObject:self.privateEvents toFile:path];
}

@end
