//
//  EventStore.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/7/25.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "EventStore.h"
#import "Event.h"

@interface EventStore()

@property (nonatomic)NSMutableArray *privateItems;

@end

@implementation EventStore
+ (instancetype)sharedStore
{
    static EventStore *sharedStore = nil;
    
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
        _privateItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        //如果没有读取到保存的数据，就创建新的
        if (!_privateItems) {
            _privateItems = [[NSMutableArray alloc] init];
        }
        
    }
    
    return self;
}

- (NSArray *)allItems
{
    return [self.privateItems copy];
}

- (Event *)createItem
{
    Event *event = [Event new];
    
    [self.privateItems addObject:event];
    return event;
}

//实现删除行的方法
- (void)removeItem:(Event *)event
{
    
//    NSString *key = event.itemKey;
//    [[YKImageStore shareStore] deleteImageForKey:key];
    
    //removeObjectIdenticalTo:方法
    [self.privateItems removeObjectIdenticalTo:event];
}

//实现移动数据的方法
- (void)moveItemAtIndex:(NSUInteger)fromIndex
               toIndex :(NSUInteger)toIndex
{
    if (fromIndex == toIndex) {
        return;
    }
    //得到需要移动的对象的指针，以便稍后能将其插入新的位置
    Event *event = self.privateItems[fromIndex];
    
    //将item从allItems数组中移除
    [self.privateItems removeObjectAtIndex:fromIndex];
    
    //根据新的索引位置，将item插回allItems数组
    [self.privateItems insertObject:event atIndex:toIndex];
}

//18.2 将对象保存至Doc目录中的某个文件，以及读取
- (NSString *)itemArchivePath
{
    //通过该方法获取Doc目录的全路径，三个实参：（指定目录）
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories firstObject];
    
    //最终获取了储存的指定目录
    return [documentDirectory stringByAppendingPathComponent:@"event.archive"];
}

- (BOOL)saveChanges //储存数据到本地的方法！
{
    NSString *path = [self itemArchivePath];
    
    //将所有privateItems中的所有YKItem对象都保存至以上路径的文件
    return [NSKeyedArchiver archiveRootObject:self.privateItems toFile:path];
}

@end
