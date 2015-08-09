//
//  NameManageTableView.h
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/6.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NameManageTableView : UITableViewController

@property (nonatomic, strong) NSArray *sportNames;
@property (nonatomic, strong) NSString *sportType;
@property (nonatomic) NSInteger indexRow;

@end
