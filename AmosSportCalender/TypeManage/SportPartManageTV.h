//
//  SportPartManageTV.h
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/10.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SportEventStore;

@interface SportPartManageTV : UITableViewController

@property (nonatomic) NSInteger pageState; ///<0-运动类型管理 1-预置组合选择 2-挑选运动项目
@property (nonatomic) BOOL canEditEvents;
@property (nonatomic, strong) void(^chooseSportBlock)(SportEventStore *);

@end
