//
//  QQSessionAct.m
//  AmosSportDiary
//
//  Created by Amos Wu on 15/8/27.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "QQSessionAct.h"

@implementation QQSessionAct

- (id)init
{
    self = [super init];
    if (self) {
        isQQ = YES;
    }
    return self;
}

- (UIImage *)activityImage
{
    return [[[UIDevice currentDevice] systemVersion] intValue] >= 8 ? [UIImage imageNamed:@"qq.png"] : [UIImage imageNamed:@"qq.png"];
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"QQ", nil);
}

@end
