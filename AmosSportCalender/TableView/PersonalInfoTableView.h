//
//  PersonalInfoTableView.h
//  AmosSportDiary
//
//  Created by Amos Wu on 15/8/26.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonalInfoTableView : UITableViewController

@property (nonatomic, strong)NSMutableArray *allUserData;
@property (nonatomic) NSInteger mainIndex;
@property (nonatomic, strong) NSString *userDataPath;

@end
