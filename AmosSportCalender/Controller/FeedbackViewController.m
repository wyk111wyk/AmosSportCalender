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
#import "RESideMenu.h"
#import "DMPasscode.h"
#import "SettingStore.h"

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
    
    [self.sideMenuViewController setPanFromEdge:NO];
//    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)tapBackground:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)closeAndOpenDrower:(UIBarButtonItem *)sender {
//    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (IBAction)sendTheFeedbackToAmos:(UIBarButtonItem *)sender {
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法发送"
                                                         message:@"当前系统版本不支持应用内发送邮件功能，您需要前往邮件应用"
                                                        delegate:self
                                               cancelButtonTitle:@"好的"
                                               otherButtonTitles: nil];
        [alert show];
        
        return;
    }
    if (![mailClass canSendMail]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法发送"
                                                         message:@"您还没有设置邮件账户"
                                                        delegate:self
                                               cancelButtonTitle:@"好的"
                                               otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    
    NSDictionary *infoDictionary =[[NSBundle mainBundle]infoDictionary];
    NSString *infoStr = [NSString stringWithFormat:@"(%@.%@)", [infoDictionary objectForKey:@"CFBundleShortVersionString"], [infoDictionary objectForKey:@"CFBundleVersion"]];
    NSString *contectStr = [NSString stringWithFormat:@"联系方式：%@", _emailStr];
    
    //设置标题等
    NSString *titleTemp = @"无内容";
    NSString *containTemp = @"无内容";
    titleTemp = [NSString stringWithFormat:@"ASD%@-%@-%@", infoStr, _typeStr, _titleStr];
    containTemp = [NSString stringWithFormat:@"%@-%@\n\n%@\n\n%@", _typeStr, _titleStr, _containStr, contectStr];
    
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
    _sendButton.enabled = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _titleTextField) {
        _titleStr = textField.text;
        
        if (textField.text.length > 0) {
            _sendButton.enabled = YES;
        }
        
    }else if(textField == _emailTextField){
        _emailStr = textField.text;
        
        if (textField.text.length > 0) {
            _sendButton.enabled = YES;
        }
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
    if (textView.text.length > 5) {
    NSString *compStr = [textView.text substringToIndex:5];
    
    if ([compStr isEqualToString:@"请在此输入"]) {
    textView.text = @"";
    }}
    
    _sendButton.enabled = NO;
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
