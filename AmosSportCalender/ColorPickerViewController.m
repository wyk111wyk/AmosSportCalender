//
//  ColorPickerViewController.m
//  AmosSportDiary
//
//  Created by Amos Wu on 15/9/9.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import "ColorPickerViewController.h"
#import "HRColorPickerView.h"
#import "HRColorMapView.h"
#import "HRBrightnessSlider.h"

#import "CommonMarco.h"
#import "SettingStore.h"

@interface ColorPickerViewController ()

@end

@implementation ColorPickerViewController
{
    HRColorPickerView *colorPickerView;
    UIColor *_color;
    BOOL _fullColor;
}

- (id)initWithColor:(UIColor *)defaultColor fullColor:(BOOL)fullColor {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _color = defaultColor;
        _fullColor = fullColor;
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = Local(@"Change theme color" );
    
    colorPickerView = [[HRColorPickerView alloc] init];
    colorPickerView.color = _color;
    
    if (_fullColor) {
        HRColorMapView *colorMapView = [[HRColorMapView alloc] init];
        colorMapView.saturationUpperLimit = @1;
        colorMapView.tileSize = @1;
        [colorPickerView addSubview:colorMapView];
        colorPickerView.colorMapView = colorMapView;
        
        HRBrightnessSlider *slider = [[HRBrightnessSlider alloc] init];
        slider.brightnessLowerLimit = @0;
        [colorPickerView addSubview:slider];
        colorPickerView.brightnessSlider = slider;
    }
    
//    [colorPickerView addTarget:self
//                        action:@selector(colorWasChanged:)
//              forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:colorPickerView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    colorPickerView.frame = (CGRect) {.origin = CGPointZero, .size = self.view.frame.size};
    
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        CGRect frame = colorPickerView.frame;
        frame.origin.y = self.topLayoutGuide.length;
        frame.size.height -= self.topLayoutGuide.length;
        colorPickerView.frame = frame;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:Local(@"Save") style:UIBarButtonItemStyleDone target:self action:@selector(clickToChangeColor)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)clickToChangeColor
{
    SettingStore *setting = [SettingStore sharedSetting];
    CGFloat red, green, blue;
    [colorPickerView.color
     getRed:&red
     green:&green
     blue:&blue
     alpha:nil];
    NSArray *oneColor = @[@(red), @(green), @(blue)];
    
    NSMutableArray *tempMuArray = [[NSMutableArray alloc] initWithArray:[setting.typeColorArray copy]];
    [tempMuArray replaceObjectAtIndex:self.indexPathRow withObject:oneColor];
    
    setting.typeColorArray = tempMuArray;
    if (self.refreshBlock) {
        self.refreshBlock();
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

@end
