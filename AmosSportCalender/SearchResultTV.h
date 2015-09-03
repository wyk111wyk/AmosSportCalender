//
//  SearchResultTV.h
//  AmosSportDiary
//
//  Created by Amos Wu on 15/9/1.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultTV : UITableViewController

@property (nonatomic, strong) NSMutableArray *searchTempDatas;
@property (nonatomic, strong) NSString *theNewStr;

@property (nonatomic, copy) void(^changeValueBlock)(NSDictionary *);
@property (nonatomic, copy) void(^createNewBlock)(NSString *);

@end
