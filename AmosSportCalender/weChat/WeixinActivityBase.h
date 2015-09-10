//
//  WeixinActivity.h
//  WeixinActivity
//
//  Created by Johnny iDay on 13-12-2.
//  Copyright (c) 2013年 Johnny iDay. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WXApi.h"

@interface WeixinActivityBase : UIActivity

{
    NSString *title;
    UIImage *image;
    NSURL *url;
    enum WXScene scene;
    BOOL isQQ;
    BOOL isQQzone;
    BOOL isWeiXin;
}

- (void)setThumbImage:(SendMessageToWXReq *)req;

@end
