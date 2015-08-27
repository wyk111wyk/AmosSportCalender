//
//  QZoneAct.m
//  AmosSportDiary
//
//  Created by Amos Wu on 15/8/27.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "QZoneAct.h"

@implementation QZoneAct

- (id)init
{
    self = [super init];
    if (self) {
        isQQ = YES;
        isQQzone = YES;
    }
    return self;
}

- (UIImage *)activityImage
{
    return [[[UIDevice currentDevice] systemVersion] intValue] >= 8 ? [UIImage imageNamed:@"qzone.png"] : [UIImage imageNamed:@"qzone.png"];
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"QZone", nil);
}

@end
