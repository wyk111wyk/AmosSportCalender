//
//  DateEventStore.h
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/12.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKDBModel.h"

@interface DateEventStore : JKDBModel

@property (nonatomic, strong) NSString *dateKey;
@property (nonatomic, strong) NSString *sportPart;
@property (nonatomic) NSInteger doneCount; ///<已完成的数量
@property (nonatomic) NSInteger doneMins; ///<总的完成的时间数

@end
