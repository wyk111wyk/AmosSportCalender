//
//  LeftMenuViewController.m
//  AmosSportDiary
//
//  Created by Amos Wu on 15/8/20.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//
#import <MobileCoreServices/MobileCoreServices.h>

#import "LeftMenuViewController.h"
#import "LeftMenuView.h"
#import "RESideMenu.h"
#import "CommonMarco.h"
#import "SportPartManageTV.h"
#import "SummaryTableView.h"
#import "TOCropViewController.h"
#import "PersonalDataChangeTV.h"
#import "FeedbackViewController.h"

@interface LeftMenuViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate>

@property (weak, nonatomic) IBOutlet LeftMenuView *sportCalendarView;
@property (weak, nonatomic) IBOutlet LeftMenuView *finishedListView;
@property (weak, nonatomic) IBOutlet LeftMenuView *typeManageView;
@property (weak, nonatomic) IBOutlet LeftMenuView *settingView;
@property (weak, nonatomic) IBOutlet LeftMenuView *feedbackView;
@property (weak, nonatomic) IBOutlet LeftMenuView *aboutView;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalSportCount;

@property (strong, nonatomic) LeftMenuView *currentSelectedView;
@property (nonatomic, strong)NSArray *menuName;

@end

@implementation LeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _avatarImageView.layer.cornerRadius = _avatarImageView.frame.size.height/2;
    _avatarImageView.layer.borderWidth = 1.3;
    _avatarImageView.layer.borderColor = MyWhite.CGColor;
    
    self.menuName = [[NSArray alloc] initWithObjects:Local(@"Sport Cal"), Local(@"Finish List"), Local(@"Data"), Local(@"Setting"), Local(@"Feedback"), Local(@"About"), nil];

    _sportCalendarView.isSelected = YES;
    _sportCalendarView.titleLabel.text = _menuName[0];
    _sportCalendarView.imageView.image = [UIImage imageNamed:@"calendar"];
    _currentSelectedView = _sportCalendarView;
    
    _finishedListView.isSelected = NO;
    _finishedListView.titleLabel.text = _menuName[1];
    _finishedListView.imageView.image = [UIImage imageNamed:@"to_do"];
    
    _typeManageView.isSelected = NO;
    _typeManageView.titleLabel.text = _menuName[2];
    _typeManageView.imageView.image = [UIImage imageNamed:@"manage"];
    
    _settingView.isSelected = NO;
    _settingView.titleLabel.text = _menuName[3];
    _settingView.imageView.image = [UIImage imageNamed:@"settings"];
    
    _feedbackView.isSelected = NO;
    _feedbackView.titleLabel.text = _menuName[4];
    _feedbackView.imageView.image = [UIImage imageNamed:@"feedback"];
    
    _aboutView.isSelected = NO;
    _aboutView.titleLabel.text = _menuName[5];
    _aboutView.imageView.image = [UIImage imageNamed:@"about"];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *userName = [SettingStore sharedSetting].userName;
    NSString *userDataName = [SettingStore sharedSetting].userDataName;
    if (userName.length == 0) {
        userName = Local(@"Default User");
    }
    _nameLabel.text = userName;
    
    UIImage *photoImage = [[TMCache sharedCache] objectForKey:ATCacheKey(userDataName)];
    if (photoImage) {
        _avatarImageView.image = photoImage;
    }else {
        SportImageStore *imageStore = [SportImageStore findFirstWithFormat:@" WHERE imageKey = '%@' ", userDataName];
        if (imageStore) {
            NSString *avatarStr = imageStore.sportPhoto;
            NSData *imageData = [[NSData alloc] initWithBase64EncodedString:avatarStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
            photoImage = [UIImage imageWithData:imageData];
            [[TMCache sharedCache] setObject:photoImage forKey:ATCacheKey(userDataName)];
            _avatarImageView.image = photoImage;
        }else {
            _avatarImageView.image = [UIImage imageNamed:@"photoSq"];
        }
    }
    _avatarImageView.layer.masksToBounds = YES;
    
    NSInteger countNum = [DateEventStore findCounts:nil];
    _totalSportCount.text = [NSString stringWithFormat:Local(@"All exercise day：%@"), @(countNum)];
}

- (IBAction)clickTheButton:(UIButton *)sender {
    if (sender.tag == 1) {
        //头像
        [self alertForChooseCreate];
    }else if (sender.tag == 2) {
        //设置
        _currentSelectedView.isSelected = NO;
        _currentSelectedView = nil;
        PersonalDataChangeTV *personChange = [[PersonalDataChangeTV alloc] initWithStyle:UITableViewStylePlain];
        UINavigationController *personNav = [[UINavigationController alloc] initWithRootViewController:personChange];
        [self.sideMenuViewController setContentViewController:personNav animated:YES];
        [self.sideMenuViewController hideMenuViewController];
    }
}

- (IBAction)menuSelected:(LeftMenuView *)sender {
    
    if (sender == _currentSelectedView) {
        [self.sideMenuViewController hideMenuViewController];
    }else{
        _currentSelectedView.isSelected = NO;
        sender.isSelected = YES;
        _currentSelectedView = sender;
        
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        
        if (sender == _sportCalendarView) {
            [self.sideMenuViewController setContentViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"nav"] animated:YES];
        }else if (sender == _finishedListView){
            SummaryTableView *summaryTV = [[SummaryTableView alloc] initWithStyle:UITableViewStylePlain];
            UINavigationController *summaryNav = [[UINavigationController alloc] initWithRootViewController:summaryTV];
            [self.sideMenuViewController setContentViewController:summaryNav];
        }else if (sender == _typeManageView){
            SportPartManageTV *partTV = [[SportPartManageTV alloc] initWithStyle:UITableViewStylePlain];
            partTV.canEditEvents = YES;
            partTV.pageState = 0;
            UINavigationController *partNav = [[UINavigationController alloc] initWithRootViewController:partTV];
            [self.sideMenuViewController setContentViewController:partNav];
        }else if (sender == _settingView){
            [self.sideMenuViewController setContentViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"settingNav"] animated:YES];
        }else if (sender == _feedbackView){
            [self.sideMenuViewController setContentViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"feedbackNav"] animated:YES];
        }else if (sender == _aboutView){
            if (DeBugMode) { NSLog(@"click 6"); }
            [self.sideMenuViewController setContentViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"aboutNav"] animated:YES];
        }
        
        [self.sideMenuViewController hideMenuViewController];
    }
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertForChooseCreate
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:Local(@"Choose Avatar operation")
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Take photo")                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                //拍照
                                                if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
                                                    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                                                    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                    if ([self isFrontCameraAvailable]) {
                                                        //先启动后置相机
                                                        controller.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                                                    }
                                                    NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                                                    [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                                                    controller.mediaTypes = mediaTypes;
                                                    controller.delegate = self;
                                                    [self presentViewController:controller
                                                                       animated:YES
                                                                     completion:nil];
                                                }
                                                
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Choose from library")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                //从相册中选取
                                                if ([self isPhotoLibraryAvailable]) {
                                                    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                                                    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                    NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                                                    [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                                                    controller.mediaTypes = mediaTypes;
                                                    controller.delegate = self;
                                                    [self presentViewController:controller
                                                                       animated:YES
                                                                     completion:nil];
                                                }
                                                
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Delete the photo")
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * action) {
        //删除
        _avatarImageView.image = [UIImage imageNamed:@"photoSq"];
                                        
        NSString *userDataName = [SettingStore sharedSetting].userDataName;
        [SportImageStore deleteObjectsWithFormat:@" WHERE imageKey = '%@' ", userDataName];
        [[TMCache sharedCache] removeObjectForKey:ATCacheKey(userDataName)];
                                                
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - 拍完照后的回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    //先将拍摄的图片缩小，按比例，最长的边为150
    portraitImg = [[ASBaseManage sharedManage] scaleToSize:portraitImg size:portraitImg.size sizeLine:150];
    //将缩小后的图片再进行压缩
    NSData *dataImg3 = UIImageJPEGRepresentation(portraitImg, 0.7);
    UIImage *newImage = [UIImage imageWithData:dataImg3];
    
    [picker dismissViewControllerAnimated:YES completion:^() {
        TOCropViewController *cropController = [[TOCropViewController alloc] initWithImage:newImage];
        cropController.delegate = self;
        [self presentViewController:cropController animated:YES completion:nil];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    //照片被取消
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Cropper Delegate -
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    CGRect viewFrame = [self.view convertRect:self.avatarImageView.frame toView:self.navigationController.view];
    [cropViewController dismissAnimatedFromParentViewController:cropViewController toFrame:viewFrame completion:^{
        _avatarImageView.image = image;
        _avatarImageView.layer.masksToBounds = YES;
        
        NSData *imgData = UIImageJPEGRepresentation(image, 1);
        NSString* pictureDataString = [imgData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        
        NSString *userDataName = [SettingStore sharedSetting].userDataName;
        SportImageStore *imageStore = [SportImageStore findFirstWithFormat:@" WHERE imageKey = '%@' ", userDataName];
        if (imageStore) {
            imageStore.sportPhoto = pictureDataString;
            imageStore.sportThumbnailPhoto = @"";
            [imageStore update];
        }else {
            SportImageStore *imageStore = [SportImageStore new];
            imageStore.imageKey = userDataName;
            imageStore.sportPhoto = pictureDataString;
            imageStore.sportThumbnailPhoto = @"";
            [imageStore save];
        }
        
        [[TMCache sharedCache] setObject:image forKey:ATCacheKey(userDataName)];
    }];
}

- (void)alertForCanNotDeleteImage
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:Local(@"Error operation")
                                                                   message:Local(@"Reason：system image can’t be deleted")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:Local(@"Okay")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Camera Utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

@end
