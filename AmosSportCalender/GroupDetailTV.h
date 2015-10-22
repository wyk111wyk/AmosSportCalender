//
//  GroupDetailTV.h
//  AmosSportDiary
//
//  Created by Amos Wu on 15/10/4.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface GroupDetailTV : UITableViewController

@property (strong, nonatomic) NSString *belong;
@property (strong, nonatomic) NSString *navTitle;
@property (strong, nonatomic) NSArray *allDataArray;

@end
