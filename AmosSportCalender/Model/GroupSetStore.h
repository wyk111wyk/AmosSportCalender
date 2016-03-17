//
//  GroupSetStore.h
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/15.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKDBModel.h"

@interface GroupSetStore : JKDBModel

@property (nonatomic, strong) NSString *groupPart;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic) NSInteger groupLevel; ///<运动等级1-初级 2-中级 3-高级

@end
