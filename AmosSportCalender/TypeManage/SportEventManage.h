//
//  SportEventManage.h
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/10.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SportEventStore;
@protocol ASEventDelegate <NSObject>
@optional
-(void)ASEventDidChoose:(SportEventStore *)eventStore;
@end

@interface SportEventManage : UITableViewController

@property (nonatomic) BOOL canEditEvents;
@property (nonatomic) NSInteger colorIndex;
@property (nonatomic, strong) NSString *sportPart;
@property (nonatomic, weak) id<ASEventDelegate> delegate;

@end
