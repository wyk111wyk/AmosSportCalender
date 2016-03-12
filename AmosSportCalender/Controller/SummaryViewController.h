//
//  SummaryViewController.h
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/3.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYPieChart.h"
#import "UUChart.h"

@interface SummaryViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *view1;
@property (strong, nonatomic) IBOutlet UIView *view4;
@property (strong, nonatomic) IBOutlet UIView *viewBackground;

@property (weak, nonatomic) IBOutlet UIView *contantView;
@property (strong, nonatomic) UUChart *chartView;
@property (strong, nonatomic) IBOutlet UIView *view2;
@property (strong, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UIView *vLineView;
@property (weak, nonatomic) IBOutlet UIView *hLineView;
@property (weak, nonatomic) IBOutlet UIView *shadoView1;
@property (weak, nonatomic) IBOutlet UIView *shadoView21;
@property (weak, nonatomic) IBOutlet UIView *shadoView22;
@property (weak, nonatomic) IBOutlet XYPieChart *pieChartView;

@property (weak, nonatomic) IBOutlet UIImageView *mostTypeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *leastTypeImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *theWholeNumber; ///<总计天数
@property (weak, nonatomic) IBOutlet UILabel *theWholeTime; ///<总计时间
@property (weak, nonatomic) IBOutlet UILabel *aveTimesAWeek; ///<平均每周几次
@property (weak, nonatomic) IBOutlet UILabel *aveTime; ///<平均每次多少时间
@property (weak, nonatomic) IBOutlet UILabel *percentageLabel;

@property (nonatomic)CGFloat contentHight;

+(UIImage*)captureView: (UIView *)theView;

@end
