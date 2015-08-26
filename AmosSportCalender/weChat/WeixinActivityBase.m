//
//  WeixinActivity.m
//  WeixinActivity
//
//  Created by Johnny iDay on 13-12-2.
//  Copyright (c) 2013年 Johnny iDay. All rights reserved.
//
#define YouMen_AppKey @"55dd6364e0f55ab05b000502"

#import "WeixinActivityBase.h"
#import "MobClickSocialAnalytics.h"

@implementation WeixinActivityBase

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

- (NSString *)activityType
{
    return NSStringFromClass([self class]);
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        for (id activityItem in activityItems) {
            if ([activityItem isKindOfClass:[UIImage class]]) {
                return YES;
            }
            if ([activityItem isKindOfClass:[NSURL class]]) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[UIImage class]]) {
            image = activityItem;
        }
        if ([activityItem isKindOfClass:[NSURL class]]) {
            url = activityItem;
        }
        if ([activityItem isKindOfClass:[NSString class]]) {
            title = activityItem;
        }
    }
}

- (void)setThumbImage:(SendMessageToWXReq *)req
{
    if (image) {
        CGFloat width = 100.0f;
        CGFloat height = image.size.height * 100.0f / image.size.width;
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        [image drawInRect:CGRectMake(0, 0, width, height)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [req.message setThumbImage:scaledImage];
    }
}

- (void)performActivity
{
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.scene = scene;
//    req.bText = NO;
    req.message = WXMediaMessage.message;
    if (scene == WXSceneSession) {
        req.message.title = [NSString stringWithFormat:NSLocalizedString(@"%@ 分享",nil), NSLocalizedStringFromTable(@"AmosSportDiary", @"InfoPlist", nil)];
        req.message.description = title;
    } else {
        req.message.title = title;
    }
    [self setThumbImage:req];
    if (url) {
        WXWebpageObject *webObject = WXWebpageObject.object;
        webObject.webpageUrl = [url absoluteString];
        req.message.mediaObject = webObject;
    } else if (image) {
        WXImageObject *imageObject = WXImageObject.object;
        imageObject.imageData = UIImageJPEGRepresentation(image, 1);
        req.message.mediaObject = imageObject;
    }
    [WXApi sendReq:req];
    
    NSString *shareType;
    if (image.size.width == 375 && image.size.height == 239.5) {
        shareType = @"总结-运动概况";
    }else if (image.size.width == 320 && image.size.height == 229){
        shareType = @"总结-运动概况";
    }else if (image.size.width == 414 && image.size.height == 247){
        shareType = @"总结-运动概况";
    }else{
        shareType = @"当日-运动项目";
    }
    
    //友盟社交分享统计
    MobClickSocialWeibo *weChat=[[MobClickSocialWeibo alloc] initWithPlatformType:@"微信" weiboId:nil usid:nil param:nil];
    [MobClickSocialAnalytics postWeiboCounts:@[weChat] appKey:YouMen_AppKey topic:shareType completion:^(NSDictionary *response, NSError *error) {
        NSLog(@"result is %@",response);
        //result里面包含分别为key为st、msg、data，分别代表错误码、错误描述、返回数据
        //error代表网络连接等错误
    }];
    
    [self activityDidFinish:YES];
}

@end
