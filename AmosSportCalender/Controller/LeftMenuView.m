//
//  LeftMenuView.m
//  AmosSportDiary
//
//  Created by Amos Wu on 15/8/20.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//

#import <pop/POP.h>
#import "LeftMenuView.h"

@interface LeftMenuView()

@end

@implementation LeftMenuView

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    
    _imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    _pieView = [[UIView alloc]initWithFrame:CGRectZero];
    
    _nMesagePieView = [[UIView alloc] initWithFrame:CGRectZero];
    _nMessageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    self.pieView.frame = CGRectMake(10, (CGRectGetHeight(self.bounds) - 28) / 2, 30, 30);
    self.pieView.layer.cornerRadius = 14;
    self.pieView.layer.masksToBounds = YES;
    self.pieView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [self addSubview:self.pieView];
    
    _imageView.frame = CGRectMake(10, (CGRectGetHeight(self.bounds) - 28) / 2, 18, 18);
    _imageView.center = _pieView.center;
    _imageView.opaque = 0.6;
    [self addSubview:_imageView];
    
    _titleLabel.frame = CGRectMake(CGRectGetMaxX(self.imageView.frame) + 20, 0, 120, CGRectGetHeight(self.bounds));
    _titleLabel.font = [UIFont fontWithName:@"Arial" size:18];
    _titleLabel.textColor = [UIColor colorWithWhite:0.95 alpha:1];
//    [_titleLabel sizeToFit];
    [self addSubview:_titleLabel];
    
    _nMesagePieView.frame = CGRectMake(CGRectGetMaxX(self.imageView.frame) + 60, 12, 18, 18);
    _nMesagePieView.layer.cornerRadius = 9;
    _nMesagePieView.layer.masksToBounds = YES;
    _nMesagePieView.backgroundColor = [UIColor redColor];
    [self addSubview:_nMesagePieView];
    
    _nMessageLabel.frame = CGRectMake(0, 0, 15, 18);
    _nMessageLabel.center = _nMesagePieView.center;
    _nMessageLabel.font = [UIFont fontWithName:@"Arial" size:14];
    _nMessageLabel.textColor = [UIColor whiteColor];
    _nMessageLabel.text = @"";
    _nMessageLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_nMessageLabel];
    
    _nMesagePieView.hidden = YES;
    
    return self;
}


- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    _isSelected ? [self zoomIn] : [self zoomOut];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self zoomIn];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    if (_isSelected) {
        
    }else{[self zoomOut];}
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if (_isSelected) {
        
    }else{[self zoomOut];}
}

- (void)zoomIn
{
    POPSpringAnimation *zoomInAni = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    zoomInAni.springBounciness = 20;
    zoomInAni.springSpeed = 20;
    zoomInAni.dynamicsTension = 1000;
    zoomInAni.toValue = [NSValue valueWithCGSize:CGSizeMake(1.2, 1.2)];
    [self.pieView pop_addAnimation:zoomInAni forKey:@"zoomAnimation"];
    [self.imageView pop_addAnimation:zoomInAni forKey:@"zoomAnimation"];
    
    POPBasicAnimation *layerColor = [POPBasicAnimation animationWithPropertyNamed:kPOPViewBackgroundColor];
    layerColor.toValue = [UIColor colorWithRed:0.2000 green:0.6235 blue:0.9882 alpha:0.8];
    [self.pieView pop_addAnimation:layerColor forKey:@"backgroundColorAnimation"];
    
    POPBasicAnimation *textColor = [POPBasicAnimation animationWithPropertyNamed:kPOPLabelTextColor];
    textColor.toValue = [UIColor colorWithRed:0.2000 green:0.6235 blue:0.9882 alpha:1];
    [self.titleLabel pop_addAnimation:textColor forKey:@"textColorAnimation"];
    
    _titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:19];
}

- (void)zoomOut
{
    POPSpringAnimation *zoomOutAni = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    zoomOutAni.springBounciness = 20;
    zoomOutAni.springSpeed = 20;
    zoomOutAni.dynamicsTension = 1000;
    zoomOutAni.toValue = [NSValue valueWithCGSize:CGSizeMake(1., 1.)];
    [self.pieView pop_addAnimation:zoomOutAni forKey:@"zoomAnimation"];
    [self.imageView pop_addAnimation:zoomOutAni forKey:@"zoomAnimation"];
    
    POPBasicAnimation *layerColor = [POPBasicAnimation animationWithPropertyNamed:kPOPViewBackgroundColor];
    layerColor.toValue = [UIColor colorWithWhite:0.95 alpha:1];
    [self.pieView pop_addAnimation:layerColor forKey:@"backgroundColorAnimation"];
    
    POPBasicAnimation *textColor = [POPBasicAnimation animationWithPropertyNamed:kPOPLabelTextColor];
    textColor.toValue = [UIColor colorWithWhite:0.95 alpha:1];
    [self.titleLabel pop_addAnimation:textColor forKey:@"textColorAnimation"];
    
    _titleLabel.font = [UIFont fontWithName:@"Arial" size:18];
}

@end
