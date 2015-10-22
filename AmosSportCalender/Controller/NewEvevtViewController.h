//
//  NewEvevtViewController.h
//  AmosSportCalender
//
//  Created by Amos Wu on 15/7/25.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Event;
@class LeftMenuTableView;

@interface NewEvevtViewController : UIViewController

//用于直接创建另一个事件的block
typedef void (^myBlock)();

@property (nonatomic, copy) myBlock creatEventBlock; //为了不释放，使用copy
@property (nonatomic, copy) NSString *(^textPassBlock)();

@property (nonatomic, strong)NSDate *date; ///<事件创建的日期
@property (nonatomic, strong)Event *event; ///<新建事件时的事件属性

@property (nonatomic, strong)NSArray *sportTypes;
@property (nonatomic, strong)NSArray *sportNames;

@property (nonatomic)BOOL createNewEvent;

@property (nonatomic)BOOL groupEdit;
@property (nonatomic, strong)NSString *belong;
@property (nonatomic, strong)NSString *groupName;

@end
