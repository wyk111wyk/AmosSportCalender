//
//  SummaryViewController.h
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/3.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYPieChart.h"

@interface SummaryViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *view1;

@property (nonatomic, strong)NSMutableDictionary *eventsMostByDate;
//@property (nonatomic)CGFloat screenWidth;
//@property (nonatomic)CGFloat screenHight;
@property (nonatomic)CGFloat contentHight;

+(UIImage*)captureView: (UIView *)theView;

@end
