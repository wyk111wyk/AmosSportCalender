//
//  ImageStore.h
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/9.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageStore : NSObject

+ (instancetype)shareStore;

- (void)setImage: (UIImage *)image forKey: (NSString *)key;
- (UIImage *)imageForKey: (NSString *)key;
- (void)deleteImageForKey: (NSString *)key;

- (NSString *)imagePageForKey: (NSString *)key;


@end
