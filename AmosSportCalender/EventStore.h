//
//  EventStore.h
//  AmosSportCalender
//
//  Created by Amos Wu on 15/7/25.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Event;

@interface EventStore : NSObject

//3. 声明一个SharedStore类方法
+ (instancetype)sharedStore;

//5. 声明一个方法和属性，分别用于创建和保存YKItem对象
- (Event *)createItem;
- (Event *)createItem:(Event *)event  date:(NSDate *)date;
@property (nonatomic, strong)NSDictionary *allItems;

//声明一个新的方法，用于删除行
- (void)removeItem:(Event *)event date:(NSDate *)date;

//声明一个方法，用于移动行
- (void)moveItemAtIndex:(NSUInteger)fromIndex
               toIndex :(NSUInteger)toIndex
                   date:(NSDate *)date;

- (BOOL)saveChanges;

@end
