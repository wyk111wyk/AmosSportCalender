//
//  NewGroupVC.h
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/17.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupSetStore;

@interface NewGroupVC : UIViewController

@property (nonatomic) BOOL isNew;
@property (nonatomic, strong) GroupSetStore *groupStore;

@end
