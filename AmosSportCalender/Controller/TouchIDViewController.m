//
//  TouchIDViewController.m
//  AmosSportDiary
//
//  Created by Amos Wu on 15/8/19.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "TouchIDViewController.h"
#import "DMPasscode.h"
#import "SettingStore.h"
#import "PersonInfoStore.h"

@interface TouchIDViewController ()
@property (weak, nonatomic) IBOutlet UIButton *touchIDButton;
@property (nonatomic)BOOL isFirst;
@property (weak, nonatomic) IBOutlet UILabel *helloLabel;

@end

@implementation TouchIDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isFirst = YES;
    _touchIDButton.enabled = YES;
    
    
    PersonInfoStore *personal = [PersonInfoStore sharedSetting];
    if (personal.name.length > 0) {
        _helloLabel.text = [NSString stringWithFormat:@"你好，%@！\n请使用指纹进行解锁。", personal.name];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    if (_isFirst) {
    [self TouchIDButtonClick:_touchIDButton];
        _isFirst = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)TouchIDButtonClick:(UIButton *)sender {
    SettingStore *setting = [SettingStore sharedSetting];
    [DMPasscode showPasscodeInViewController:self completion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"TouchID success");
            setting.passWordOfFingerprint = YES;
            
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            if (error) {
                // Failed authentication
                
                _helloLabel.text = @"不知道密码请不要轻易尝试，万一发生不好的事情就不好了。\n少侠请过几分钟再来尝试吧。";
                [_helloLabel sizeToFit];
                _touchIDButton.enabled = NO;
                NSLog(@"TouchID Error");
            } else {
                // Cancelled
                NSLog(@"TouchID Cancell");
            }
        }
    }];
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
