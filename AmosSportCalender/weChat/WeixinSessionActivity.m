//
//  WeixinSessionActivity.m
//  WeixinActivity
//
//  Created by Johnny iDay on 13-12-2.
//  Copyright (c) 2013年 Johnny iDay. All rights reserved.
//

#import "WeixinSessionActivity.h"

@implementation WeixinSessionActivity

- (id)init
{
    self = [super init];
    if (self) {
        scene = WXSceneSession;
        isWeiXin = YES;
    }
    return self;
}

- (UIImage *)activityImage
{
    return [[[UIDevice currentDevice] systemVersion] intValue] >= 8 ? [UIImage imageNamed:@"icon_session-8.png"] : [UIImage imageNamed:@"icon_session.png"];
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"微信好友", nil);
}

@end
