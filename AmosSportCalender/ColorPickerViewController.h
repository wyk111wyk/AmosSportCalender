//
//  ColorPickerViewController.h
//  AmosSportDiary
//
//  Created by Amos Wu on 15/9/9.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HRColorPickerView;

@interface ColorPickerViewController : UIViewController

- (id)initWithColor:(UIColor *)defaultColor fullColor:(BOOL)fullColor;

@property (nonatomic)NSInteger indexPathRow;

@end