//
//  DetailSummaryVC.h
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/9.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailSummaryVC : UIViewController

@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@property (nonatomic, strong)NSMutableArray *eventsByDateForTable;
@property (nonatomic, strong)NSString *sportTypeStr;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *sportTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timesLabel;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *avegSpaceLabel;
@property (weak, nonatomic) IBOutlet UILabel *avegTime;
@property (weak, nonatomic) IBOutlet UILabel *belowTableViewLabel;

@end
