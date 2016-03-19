//
//  SportImageStore.h
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/18.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKDBModel.h"

@interface SportImageStore : JKDBModel

@property (nonatomic, strong) NSString *sportPhoto;
@property (nonatomic, strong) NSString *sportThumbnailPhoto;
@property (nonatomic, strong) NSString *imageKey;

@end
