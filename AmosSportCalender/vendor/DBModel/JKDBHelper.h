//
//  JKDataBase.h
//  JKBaseModel
//
//  Created by zx_04 on 15/6/24.
//
//  github:https://github.com/Joker-King/JKDBModel

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface JKDBHelper : NSObject

@property (nonatomic, retain, readonly) FMDatabaseQueue *dbQueue;

+ (JKDBHelper *)shareInstance;
+ (NSString *)dbPathWithDirectoryName:(NSString *)directoryName;
+ (NSString *)dbPath;

- (BOOL)changeDBWithDirectoryName:(NSString *)directoryName;
- (BOOL)changeDBWithVenderName:(NSString *)directoryName;

@end
