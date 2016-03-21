//
//  NumberValuePicker.m
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/10.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import "NumberValuePicker.h"
#import "CommonMarco.h"
#import "ZVScrollSlider.h"

@interface NumberValuePicker()<ZVScrollSliderDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *selfWeghtButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;
@property (nonatomic, strong) ZVScrollSlider *productSlider;

@end

@implementation NumberValuePicker

+ (instancetype)viewFromNib {
    NumberValuePicker *result = [[[NSBundle mainBundle] loadNibNamed: NSStringFromClass([self class])
                                                              owner: self options: nil] firstObject];
    return result;
}

- (void)awakeFromNib {
    _selfWeghtButton.layer.cornerRadius = 4;
    _selfWeghtButton.layer.borderColor = [UIColor orangeColor].CGColor;
    _selfWeghtButton.layer.borderWidth = 0.7;
    _selfWeghtButton.hidden = YES;
    
    _clearButton.layer.cornerRadius = 4;
    _clearButton.layer.borderWidth = 0.7;
    _clearButton.layer.borderColor = MYBlueColor.CGColor;
}

- (void)configUITitle:(NSString*)titleText unit:(NSString*)unitText min:(int)min max:(int)max step:(int)step initNum:(int)initNum {
    _titleLabel.text = titleText;
    _unitLabel.text = unitText;
    if ([titleText isEqualToString:Local(@"Weight")]) {
        _selfWeghtButton.hidden = NO;
    }
    CGFloat sliderHeight = [ZVScrollSlider heightWithBoundingWidth:screenWidth Title:titleText];
    _productSlider  = [[ZVScrollSlider alloc]initWithFrame:CGRectMake(0, self.frame.size.height-sliderHeight, screenWidth, sliderHeight)
                                                     Title:@""
                                                  MinValue:min
                                                  MaxValue:max
                                                      Step:step
                                                      Unit:unitText
                                              HasDeleteBtn:NO];
    [_productSlider setRealValue:initNum Animated:YES];
    _numberLabel.text = [NSString stringWithFormat:@"%d", initNum];
    
    _productSlider.delegate = self;
    
    [self addSubview:_productSlider];
    [self sendSubviewToBack:_productSlider];
}

- (void)ZVScrollSlider:(ZVScrollSlider *)slider ValueChange:(int)value {
    _numberLabel.text = [NSString stringWithFormat:@"%d", value];
    if (self.valueChangeBlock) {
        self.valueChangeBlock(value);
    }
}

- (IBAction)buttonClicked:(UIButton *)sender {
    if (sender.tag == 0) {
        if (self.clearBlock) {
            self.clearBlock();
        }
    }else if (sender.tag == 1) {
        if (self.selfWeghtBlock) {
            self.selfWeghtBlock();
        }
    }
}
@end
