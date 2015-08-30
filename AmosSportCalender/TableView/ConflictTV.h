//
//  ConflictTV.h
//  AmosSportDiary
//
//  Created by Amos Wu on 15/8/30.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iCloud/iCloud.h>

@interface ConflictTV : UITableViewController


- (IBAction)cancel:(id)sender;

@property (strong) NSString *documentName;
@property (strong) NSArray *documentVersions;

@end
