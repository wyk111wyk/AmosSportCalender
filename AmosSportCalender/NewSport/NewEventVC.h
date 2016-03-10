//
//  NewEventVC.h
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/9.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SportRecordStore.h"
@class SportEventStore;

@interface NewEventVC : UIViewController

@property (nonatomic) NSInteger pageState; ///<0-添加项目 1-编辑项目 2-新建项目 3-修改
@property (nonatomic, strong) SportRecordStore *recordStore;
@property (nonatomic, strong) SportEventStore *eventStore;

@end
