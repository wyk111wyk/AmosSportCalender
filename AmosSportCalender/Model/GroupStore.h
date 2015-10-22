//
//  GroupStore.h
//  AmosSportDiary
//
//  Created by Amos Wu on 15/9/29.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Event;

@interface GroupStore : NSObject
//3. 声明一个SharedStore类方法
+ (instancetype)sharedStore;

//5. 声明一个方法和属性，分别用于创建和保存YKItem对象
@property (nonatomic, strong)NSDictionary *allItems;
@property (nonatomic)NSMutableDictionary *privateEvents;
- (void)createGroup:(NSString *)belong groupName:(NSString *)name;
- (void)createItemInGroup:(Event *)event belong:(NSString *)belong groupName:(NSString *)name;

//声明一个新的方法，用于删除行
- (void)removeAllItem;
- (void)removeGroup:(NSString *)belong groupName:(NSString *)name;
- (void)removeItemInGroup:(Event *)event belong:(NSString *)belong groupName:(NSString *)name;

//声明一个方法，用于移动行
- (void)moveItemAtIndex:(NSUInteger)fromIndex
               toIndex :(NSUInteger)toIndex
                 belong:(NSString *)belong
              groupName:(NSString *)name;

- (void)editTheNameOfGroup:(NSString *)belong groupName:(NSString *)name newName:(NSString *)newName;
- (void)updateAllData;
- (BOOL)saveGroupData;
- (Event *)createItem;
@end
