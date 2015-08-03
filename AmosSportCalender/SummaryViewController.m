//
//  SummaryViewController.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/3.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "SummaryViewController.h"

@interface SummaryViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *view1;

@end

@implementation SummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.scrollView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.scrollView addSubview:self.view1];
    
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height + 200);
    self.scrollView.bounces = YES;
    self.scrollView.bouncesZoom = YES;
    self.scrollView.showsVerticalScrollIndicator = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
