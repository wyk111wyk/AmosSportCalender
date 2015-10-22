//
//  NewGroupTVViewController.m
//  AmosSportDiary
//
//  Created by Amos Wu on 15/10/17.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "NewGroupTVViewController.h"
#import "NYSegmentedControl.h"
#import "SearchResultTV.h"
#import "PersonInfoStore.h"

@interface NewGroupTVViewController ()<UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate, UISearchBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchResultsUpdating, UISearchControllerDelegate>
{
    NSDate *finalSeletedDate;
    NSString *timesSaved;
    NSString *rapsSaved;
    NSString *weightsSaved;
}

@property (strong, nonatomic)PersonInfoStore *personal;

//TextField
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UITextField *sportTypeTextField;
@property (weak, nonatomic) IBOutlet UITextField *sportNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *weightTextFeild;
@property (weak, nonatomic) IBOutlet UITextField *timelastFeild;
@property (weak, nonatomic) IBOutlet UITextField *timesFeild;
@property (weak, nonatomic) IBOutlet UITextField *rapFeild;

@property NYSegmentedControl *closeWeights;

@property (weak, nonatomic) IBOutlet UISlider *weightSlider;
@property (weak, nonatomic) IBOutlet UISlider *timelastSlider;
@property (weak, nonatomic) IBOutlet UILabel *weightUnitLabel;

//View
@property (weak, nonatomic) IBOutlet UIView *outsideView; ///<边框和背景View
@property (weak, nonatomic) IBOutlet UIView *seprateView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *rapLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;

@property (strong, nonatomic) UITextField *searchBarType;

//Utility
@property (strong, nonatomic) UIPickerView *sportPicker;
@property (strong, nonatomic) UIPickerView *sportTypePicker;

@property (strong, nonatomic) UISearchBar *sportSearchBar;
@property (nonatomic, strong) UISearchController *searchController;
@property (strong, nonatomic) SearchResultTV *searchTVC;

//Data
@property (strong, nonatomic)NSMutableArray *sportNameTemps;
@property (nonatomic) NSInteger indexRow;
@property (strong, nonatomic) NSArray *numberArray; ///<numberPicker的数据
@property (strong, nonatomic) NSString *selectedNumber; ///<numberPicker点选后的值
@property (strong, nonatomic) NSMutableArray *searchTempDateArray; ///>搜索时临时存放供挑选的数据

@end

@implementation NewGroupTVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *creatButton = [[UIBarButtonItem alloc] initWithTitle:@"新建" style:UIBarButtonItemStyleDone target:self action:@selector(createNewItem)];
    self.navigationItem.rightBarButtonItem = creatButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createNewItem
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
