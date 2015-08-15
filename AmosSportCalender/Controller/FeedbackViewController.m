//
//  FeedbackViewController.m
//  AmosSportCalender
//
//  Created by Amos Wu on 15/8/15.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "FeedbackViewController.h"
#import "FeedbackTVCell.h"
#import "UIViewController+MMDrawerController.h"

static NSString *const cellID = @"feedbackcell";

@interface FeedbackViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate,MFMailComposeViewControllerDelegate>

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

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"FeedbackTVCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:cellID];
    _tableView.rowHeight = 50;
    _tableView.allowsSelection = NO;
    
    _sendButton.enabled = NO;
    
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
    
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)tapBackground:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)closeAndOpenDrower:(UIBarButtonItem *)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (IBAction)sendTheFeedbackToAmos:(UIBarButtonItem *)sender {
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发送邮件"
                                                         message:@"当前系统版本不支持应用内发送邮件功能，您可以使用mailto方法代替"
                                                        delegate:self
                                               cancelButtonTitle:@"好的"
                                               otherButtonTitles: nil];
        [alert show];
        
        return;
    }
    if (![mailClass canSendMail]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发送邮件"
                                                         message:@"用户还没有设置邮件账户"
                                                        delegate:self
                                               cancelButtonTitle:@"好的"
                                               otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    
    //设置标题等
    NSString *titleTemp = @"无内容";
    NSString *containTemp = @"无内容";
    if (_titleStr.length > 0) {
        titleTemp = [NSString stringWithFormat:@"ASC-%@-%@", _typeStr, _titleStr];
    }
    
    if (_containStr.length >0) {
        containTemp = [NSString stringWithFormat:@"%@-%@\n%@", _typeStr, _titleStr, _containStr];
    }
    
    [mc setSubject:titleTemp];
    [mc setToRecipients:[NSArray arrayWithObject:@"wyk111wyk@icloud.com"]];
    [mc setMessageBody:containTemp isHTML:NO];
    
    // 添加一张图片
//    UIImage *addPic = [UIImage imageNamed: @"深蹲"];
//    NSData *imageData = UIImagePNGRepresentation(addPic);            // 转换成png
//    [mc addAttachmentData: imageData mimeType: @"" fileName: @"深蹲.png"];
    
    //添加一个pdf附件
//    NSString *file = [self fullBundlePathFromRelativePath:@"高质量C++编程指南.pdf"];
//    NSData *pdf = [NSData dataWithContentsOfFile:file];
//    [mc addAttachmentData: pdf mimeType: @"" fileName: @"高质量C++编程指南.pdf"];
    
    [self presentViewController:mc animated:YES completion:nil];
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _titleTextField) {
        _titleStr = textField.text;
        
        if (textField.text.length > 0) {
            _sendButton.enabled = YES;
        }
    }else if(textField == _emailTextField){
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - TextView

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    textView.text = @"";
    textView.textColor = [UIColor blackColor];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _containStr = textView.text;
    if (textView.text.length > 0) {
        _sendButton.enabled = YES;
    }
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedbackTVCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    
    return cell;
}

#pragma mark - email

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail send canceled...");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved...");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent...");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail send errored: %@...", [error localizedDescription]);
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
