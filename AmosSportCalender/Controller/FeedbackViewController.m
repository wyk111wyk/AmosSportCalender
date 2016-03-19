//
//  FeedbackViewController.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/15.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <Bugtags/Bugtags.h>
#import "FeedbackViewController.h"
#import "FeedbackTVCell.h"
#import "RESideMenu.h"
#import "DMPasscode.h"
#import "CommonMarco.h"

static NSString *const cellID = @"feedbackcell";

@interface FeedbackViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *bugReportLabel;
@property (weak, nonatomic) IBOutlet UILabel *adviseLabel;
@property (weak, nonatomic) IBOutlet UILabel *improveLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherLabel;
@property (weak, nonatomic) IBOutlet UIButton *bugReportButton;
@property (weak, nonatomic) IBOutlet UIButton *adviseButton;
@property (weak, nonatomic) IBOutlet UIButton *improveButton;
@property (weak, nonatomic) IBOutlet UIButton *otherButton;
@property (weak, nonatomic) IBOutlet UIImageView *bugReportImageView;
@property (weak, nonatomic) IBOutlet UIImageView *impoveImageView;
@property (weak, nonatomic) IBOutlet UIImageView *otherImageView;
@property (weak, nonatomic) IBOutlet UIImageView *adviseImageView;


@property (weak, nonatomic) IBOutlet UITextView *feedbackTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;

@property (weak, nonatomic) IBOutlet UIView *viewTop;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;

@property (strong, nonatomic) UIImage *checkImg;
@property (strong, nonatomic) UIImage *uncheckImg;
@property (strong, nonatomic) NSString *typeStr;
@property (strong, nonatomic) NSString *titleStr;
@property (strong, nonatomic) NSString *containStr;
@property (strong, nonatomic) NSString *emailStr;

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"FeedbackTVCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:cellID];
    _tableView.rowHeight = 50;
    _tableView.allowsSelection = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    
    _checkImg = [UIImage imageNamed:@"check"];
    _uncheckImg = [UIImage imageNamed:@"uncheck"];
    
    _viewTop.layer.cornerRadius = 5;
    _feedbackTextField.layer.cornerRadius = 5;
    _titleTextField.returnKeyType = UIReturnKeyDone;
    _emailTextField.returnKeyType = UIReturnKeyDone;
    
    _typeStr = _bugReportLabel.text;
    
    if ([UIScreen mainScreen].bounds.size.width == 320) {
        UIFont *font = [UIFont systemFontOfSize:15];
        [_bugReportLabel setFont:font];
        [_adviseLabel setFont:font];
        [_improveLabel setFont:font];
        [_otherLabel setFont:font];
    }
    
    [self.sideMenuViewController setPanFromEdge:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)tapBackground:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)sendTheFeedback:(UIBarButtonItem *)sender {
    NSString *feedbackText = [NSString stringWithFormat:@"类型：%@ 内容：(%@)(%@) 联系方式：%@", _typeStr, _titleTextField.text, _feedbackTextField.text, _emailTextField.text];
    if (_titleTextField.text.length == 0) {
        [self alertForSampleWarning:@"标题不能为空"];
    }else {
        [Bugtags sendFeedback:feedbackText];
        [Bugtags setAfterSendingCallback:^{
            [KVNProgress showSuccessWithStatus:@"反馈发送成功！"];
        }];
    }
}

- (IBAction)closeAndOpenDrower:(UIBarButtonItem *)sender {
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (IBAction)selectFeedbackType:(UIButton *)sender {
    
    if (sender == _bugReportButton) {
        _bugReportLabel.textColor = [UIColor blackColor];
        _adviseLabel.textColor = [UIColor lightGrayColor];
        _improveLabel.textColor = [UIColor lightGrayColor];
        _otherLabel.textColor = [UIColor lightGrayColor];
        
        _bugReportImageView.image = _checkImg;
        _adviseImageView.image = _uncheckImg;
        _impoveImageView.image = _uncheckImg;
        _otherImageView.image = _uncheckImg;
        
        _typeStr = _bugReportLabel.text;
    }else if (sender == _adviseButton) {
        _bugReportLabel.textColor = [UIColor lightGrayColor];
        _adviseLabel.textColor = [UIColor blackColor];
        _improveLabel.textColor = [UIColor lightGrayColor];
        _otherLabel.textColor = [UIColor lightGrayColor];
        
        _bugReportImageView.image = _uncheckImg;
        _adviseImageView.image = _checkImg;
        _impoveImageView.image = _uncheckImg;
        _otherImageView.image = _uncheckImg;
        
        _typeStr = _adviseLabel.text;
    }else if (sender == _improveButton) {
        _bugReportLabel.textColor = [UIColor lightGrayColor];
        _adviseLabel.textColor = [UIColor lightGrayColor];
        _improveLabel.textColor = [UIColor blackColor];
        _otherLabel.textColor = [UIColor lightGrayColor];
        
        _bugReportImageView.image = _uncheckImg;
        _adviseImageView.image = _uncheckImg;
        _impoveImageView.image = _checkImg;
        _otherImageView.image = _uncheckImg;
        
        _typeStr = _improveLabel.text;
    }else if (sender == _otherButton) {
        _bugReportLabel.textColor = [UIColor lightGrayColor];
        _adviseLabel.textColor = [UIColor lightGrayColor];
        _improveLabel.textColor = [UIColor lightGrayColor];
        _otherLabel.textColor = [UIColor blackColor];
        
        _bugReportImageView.image = _uncheckImg;
        _adviseImageView.image = _uncheckImg;
        _impoveImageView.image = _uncheckImg;
        _otherImageView.image = _checkImg;
        
        _typeStr = _otherLabel.text;
    }
}

#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - TextView

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView.text.length > 5) {
    NSString *compStr = [textView.text substringToIndex:5];
    
    if ([compStr isEqualToString:@"请在此输入"]) {
    textView.text = @"";
    }}
    
    textView.textColor = [UIColor darkGrayColor];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedbackTVCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    
    cell.clickToVoteBlock = ^(){
        NSLog(@"点赞还是反对");
        [self alertForVote];
    };
    return cell;
}

#pragma mark - Alert

- (void)alertForSampleWarning: (NSString *)titleStr
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:titleStr
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertForVote
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"反馈：麻烦把xxx这个图标做的稍微大一点"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"△ 赞同，需优先解决"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * action) {
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"▽ 反对，没什么必要"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                            }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
