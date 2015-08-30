//
//  ImageStore.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/9.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "ImageStore.h"

@interface ImageStore ()

@property (nonatomic, strong) NSMutableDictionary *dictionary;

@end

@implementation ImageStore

+ (instancetype)shareStore
{
    static ImageStore *shareStore = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        shareStore = [[self alloc] initPrivate];
    });
    
    return shareStore;
}

//不允许直接调用init方法
- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use + [YKImageStore shareStore]"
                                 userInfo:nil];
    return nil;
}

//私有的初始化方法
- (instancetype)initPrivate
{
    self = [super init];
    
    if (self) {
        _dictionary = [NSMutableDictionary new];
    }
    
    //18.6 应用智能的通知栏，用以处理内存过低的情况
    //将YKImageStore对象注册为通知中心的观察者
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(clearCache:)
               name:UIApplicationDidReceiveMemoryWarningNotification
             object:nil];
    
    return self;
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key
{
    //    [self.dictionary setObject:image forKey:key];
    self.dictionary[key] = image;
    
    //18.5 获取保存图片的路径
    NSString *imagePath = [self imagePageForKey:key];
    //从图片提取JPEG格式的数据
    NSData *data = UIImageJPEGRepresentation(image, 0.8);
    //将数据写入文件
    [data writeToFile:imagePath atomically:YES]; //yes代表先写一个临时数据，用以保证数据安全(并不是固话)
}

- (UIImage *)imageForKey:(NSString *)key
{
    //首先尝试通过字典获取图片
    UIImage *result = self.dictionary[key];
    
    if (!result) {
        NSString *imagePath = [self imagePageForKey:key];
        
        //通过文件创建UIImage对象
        result = [UIImage imageWithContentsOfFile:imagePath];
        
        //如果能够通过文件创建图片，将其放入缓存
        if (result) {
            self.dictionary[key] = result;
        }
        else{
            NSLog(@"Error: unable to find 图片路径 %@", [self imagePageForKey:key]);
        }
    }
    
    return result;
    
    //    return self.dictionary[key];
}

- (void)deleteImageForKey:(NSString *)key
{
    if (!key) {
        return;
    }
    [self.dictionary removeObjectForKey:key];
    
    //18.5 删除相应的图片文件
    NSString *imagePath = [self imagePageForKey:key];
    [[NSFileManager defaultManager] removeItemAtPath:imagePath
                                               error:nil];
}

//18.5 固化图片 通过NSData将数据写入文件
//该方法：通过key获取储存图片的地址（在Doc目录下）
- (NSString *)imagePageForKey: (NSString *)key
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    return [documentDirectory stringByAppendingPathComponent:key];
}

- (void)clearCache: (NSNotification *)note
{
    NSLog(@"flushing %@ images out of the cache", @([self.dictionary count]));
    [self.dictionary removeAllObjects];
}


@end
