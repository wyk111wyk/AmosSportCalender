//
//  SportImageStore.m
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/18.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import "SportImageStore.h"

@implementation SportImageStore

- (instancetype)init {
    self = [super init];
    if (self) {
        _sportPhoto = @"";
        _sportThumbnailPhoto = @"";
        _imageKey = @"";
    }
    
    return self;
}

@end
