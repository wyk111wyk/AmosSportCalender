//
//  ZVScrollSider.m
//  scrllSlider
//
//  Created by 子为 on 15/12/25.
//  Copyright © 2015年 wealthBank. All rights reserved.
//


#define dialColorGrayscale 0.789 //刻度的颜色灰度
#define textColorGrayscale 0.629 //文字的颜色灰度
#define textRulerFont [UIFont systemFontOfSize:9]

#define dialGap 6
#define dialLong 18
#define dialShort 9

#import "ZVScrollSlider.h"

#pragma mark - -------------------------------蛋疼的分割线--------------------------------

@interface ZVRulerView : UIView
@property (nonatomic, assign) int minValue;
@property (nonatomic, assign) int maxValue;
@property (nonatomic, copy) NSString *unit;
@end

@implementation ZVRulerView

/**
 *  绘制标尺view
 *
 *  @param rect rect
 */
-(void)drawRect:(CGRect)rect
{
    //计算位置
    CGFloat startX = 0;
    
    CGFloat lineCenterX = dialGap;
    CGFloat shortLineY = rect.size.height - dialShort;
    CGFloat longLineY = rect.size.height - dialLong;
    CGFloat bottomY = rect.size.height;
    
    if (_maxValue == 0)
    {
        _maxValue = 1000;
    }
    CGFloat step = (_maxValue-_minValue)/10;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
    //CGContextSetRGBStrokeColor(context, dialColorGrayscale, dialColorGrayscale, dialColorGrayscale, 1);//设置线的颜色, 如果不设置默认是黑色的
    CGContextSetLineWidth(context, 0.5);//设置线的宽度, 默认是1像素
    CGContextSetLineCap(context, kCGLineCapButt);
    for (int i = 0; i<=10; i++)
    {
        if (i%10 == 0)
        {
            CGContextMoveToPoint(context,startX + lineCenterX*i, longLineY);//起使点
            NSString *Num = [NSString stringWithFormat:@"%.f%@",i*step+_minValue,_unit];
            if ([Num floatValue]>1000000)
            {
                Num = [NSString stringWithFormat:@"%.f万%@",[Num floatValue]/10000.f,_unit];
            }
            
            NSDictionary *attribute = @{NSFontAttributeName:textRulerFont,NSForegroundColorAttributeName:[UIColor colorWithWhite:textColorGrayscale alpha:1]};
            CGFloat width = [Num boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:0 attributes:attribute context:nil].size.width;
            [Num drawInRect:CGRectMake(startX + lineCenterX*i-width/2, longLineY-14, width, 14) withAttributes:attribute];
        }
        else
        {
            CGContextMoveToPoint(context,startX +  lineCenterX*i, shortLineY);//起使点
        }
        CGContextAddLineToPoint(context,startX +  lineCenterX*i, bottomY);
        CGContextStrokePath(context);//开始绘制
    }
}

@end

#pragma mark - -------------------------------蛋疼的分割线--------------------------------

@interface ZVFooterRulerView : UIView
@property (nonatomic, assign) int maxValue;
@property (nonatomic, copy) NSString *unit;
@end

@implementation ZVFooterRulerView

-(void)drawRect:(CGRect)rect
{
    CGFloat longLineY = rect.size.height - dialLong;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, dialColorGrayscale, dialColorGrayscale, dialColorGrayscale, 1);//设置线的颜色, 如果不设置默认是黑色的
    //        CGContextSetLineWidth(context, 2.0);//设置线的宽度, 默认是1像素
    CGContextSetLineCap(context, kCGLineCapButt);

    CGContextMoveToPoint(context,0, longLineY);//起使点
    NSString *Num = [NSString stringWithFormat:@"%d%@",_maxValue,_unit];
    if ([Num floatValue]>1000000)
    {
        Num = [NSString stringWithFormat:@"%.f万%@",[Num floatValue]/10000.f,_unit];
    }
        
    NSDictionary *attribute = @{NSFontAttributeName:textRulerFont,NSForegroundColorAttributeName:[UIColor colorWithWhite:textColorGrayscale alpha:1]};
    CGFloat width = [Num boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:0 attributes:attribute context:nil].size.width;
    [Num drawInRect:CGRectMake(0-width/2, longLineY-14, width, 14) withAttributes:attribute];
    CGContextAddLineToPoint(context,0, rect.size.height);
    CGContextStrokePath(context);//开始绘制
}

@end

#pragma mark - -------------------------------蛋疼的分割线--------------------------------
@interface ZVHeaderRulerView : UIView
@property (nonatomic, assign) int minValue;
@property (nonatomic, copy) NSString *unit;
@end

@implementation ZVHeaderRulerView

-(void)drawRect:(CGRect)rect
{
    CGFloat longLineY = rect.size.height - dialLong;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, dialColorGrayscale, dialColorGrayscale, dialColorGrayscale, 1);//设置线的颜色, 如果不设置默认是黑色的
    //        CGContextSetLineWidth(context, 2.0);//设置线的宽度, 默认是1像素
    CGContextSetLineCap(context, kCGLineCapButt);

    CGContextMoveToPoint(context,rect.size.width, longLineY);//起使点
    NSString *Num = [NSString stringWithFormat:@"%d%@",_minValue,_unit];
    if ([Num floatValue]>1000000)
    {
        Num = [NSString stringWithFormat:@"%.f万%@",[Num floatValue]/10000.f,_unit];
    }
        
    NSDictionary *attribute = @{NSFontAttributeName:textRulerFont,NSForegroundColorAttributeName:[UIColor colorWithWhite:textColorGrayscale alpha:1]};
    CGFloat width = [Num boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:0 attributes:attribute context:nil].size.width;
    [Num drawInRect:CGRectMake(rect.size.width-width/2, longLineY-14, width, 14) withAttributes:attribute];
    CGContextAddLineToPoint(context,rect.size.width, rect.size.height);
    CGContextStrokePath(context);//开始绘制
}

@end

#pragma mark - -------------------------------蛋疼的分割线--------------------------------

@interface ZVScrollSlider ()<UIScrollViewDelegate,UITextFieldDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIButton         *deleteBtn;
@property (nonatomic, strong) UILabel          *titleLabel;
@property (nonatomic, strong) UITextField      *valueTF;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIImageView      *redLine;
@property (nonatomic, strong) UIImageView      *bottomLine;

@property (nonatomic, assign) int              stepNum;
@property (nonatomic, assign) int              value;
@property (nonatomic, assign) BOOL             scrollByHand;

@end

@implementation ZVScrollSlider

-(instancetype)initWithFrame:(CGRect)frame Title:(NSString *)title MinValue:(int)minValue MaxValue:(int)maxValue Step:(int)step Unit:(NSString *)unit HasDeleteBtn:(BOOL)hasDeleteBtn
{
    if(self = [super initWithFrame:frame])
    {
        
        //readOnly设置
        _title = title;
        _minValue = minValue;
        _maxValue = maxValue;
        _step = step;
        _stepNum = (_maxValue-_minValue)/_step/10;
        _unit = unit;
        _scrollByHand = NO;
        
        //删除按钮
        
        _deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 40, 18, 18)];
        [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"删除"] forState:UIControlStateNormal];
        [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"删除"] forState:UIControlStateHighlighted];
        [_deleteBtn setBackgroundColor:[UIColor lightGrayColor]];
        _deleteBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        _deleteBtn.layer.cornerRadius = 9;
        _deleteBtn.layer.masksToBounds = YES;
        [_deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
        if (hasDeleteBtn)
        {
            [self addSubview:_deleteBtn];
        }
        
        //名称Label
        CGFloat height            = [_title boundingRectWithSize:CGSizeMake(frame.size.width-10-18-6-15, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size.height;
        _titleLabel               = [[UILabel alloc]initWithFrame:CGRectMake(10+18+6, 40, frame.size.width-10-18-6-15, height)];
        if (!hasDeleteBtn)
        {
            _titleLabel.frame = CGRectMake(15, 40, frame.size.width-30, height);
        }
        _titleLabel.font          = [UIFont systemFontOfSize:14];
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text          = _title;
        _titleLabel.textColor     = [UIColor blackColor];
        [self addSubview:_titleLabel];
        
        //输入框
        _valueTF                          = [[UITextField alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_titleLabel.frame)+10, frame.size.width, 20)];
        _valueTF.defaultTextAttributes    = @{NSUnderlineColorAttributeName:[UIColor orangeColor],
                                           NSUnderlineStyleAttributeName:@(1),
                                           NSFontAttributeName:[UIFont systemFontOfSize:18],
                                           NSForegroundColorAttributeName:[UIColor orangeColor]};
        _valueTF.textAlignment            = NSTextAlignmentCenter;
        _valueTF.delegate                 = self;
        _valueTF.keyboardType             = UIKeyboardTypeNumberPad;
        if (_isAllowInput) {
            _valueTF.enabled = YES;
        }else {
            _valueTF.enabled = NO;
        }
        
        _valueTF.attributedPlaceholder    = [[NSAttributedString alloc]initWithString:@"滑动标尺或输入"
                                                                           attributes:@{NSUnderlineColorAttributeName:[UIColor lightGrayColor],
                                                                                        NSUnderlineStyleAttributeName:@(1),
                                                                                        NSFontAttributeName:[UIFont systemFontOfSize:12],
                                                                                        NSForegroundColorAttributeName:[UIColor grayColor]}];
        [self addSubview:_valueTF];
        
        //标尺
        UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [flowLayout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        _collectionView  =[[UICollectionView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_valueTF.frame), self.bounds.size.width, 50) collectionViewLayout:flowLayout];
        self.backgroundColor = [UIColor whiteColor];
        _collectionView.backgroundColor = [UIColor redColor];
        
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"systemCell"];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"custemCell"];
        
        _collectionView.bounces = NO;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [self addSubview:_collectionView];
        
        _redLine = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2-0.5, CGRectGetMaxY(_valueTF.frame)+5, 1, 45)];
        _redLine.backgroundColor = [UIColor orangeColor];
        [self addSubview:_redLine];
        
        _bottomLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height-0.5, self.bounds.size.width, 0.5)];
        _bottomLine.backgroundColor = [UIColor grayColor];
        [self addSubview:_bottomLine];
    }
    return self;
}

+(CGFloat)heightWithBoundingWidth:(CGFloat )width Title:(NSString *)title
{
    CGFloat height  = [title boundingRectWithSize:CGSizeMake(width-10-18-6-15, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                       attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}
                                          context:nil].size.height;
    return 40+height+10+20+50;
}

#pragma setter
-(void)setRealValue:(float)realValue
{
    [self setRealValue:realValue Animated:NO];
}

-(void)setTitle:(NSString *)title
{
    _title = title;
    _titleLabel.text = _title;
}

-(void)setRealValue:(float)realValue Animated:(BOOL)animated
{
    _realValue = realValue;
    _valueTF.text = [NSString stringWithFormat:@"%d",(int)(_realValue*_step)];
    [_collectionView setContentOffset:CGPointMake(((int)realValue-_minValue)*dialGap, 0) animated:animated];
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZVScrollSlider:ValueChange:)])
    {
        [self.delegate ZVScrollSlider:self ValueChange:realValue*_step];
    }
}

#pragma UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSString *newStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([newStr intValue] > _maxValue)
    {
        _valueTF.text = [NSString stringWithFormat:@"%d",_maxValue];
        [self performSelector:@selector(didChangeValue) withObject:nil afterDelay:0];
        return NO;
    }
    else
    {
        _scrollByHand = NO;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(didChangeValue) withObject:nil afterDelay:1];
        return YES;
    }
}

-(void)didChangeValue
{
    [self setRealValue:[_valueTF.text floatValue]/(float)_step Animated:YES];
}

-(void)deleteAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZVScrollSliderDidDelete:)])
    {
        [self.delegate ZVScrollSliderDidDelete:self];
    }
}

#pragma mark UICollectionViewDataSource & Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2+_stepNum;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0 || indexPath.item == _stepNum+1)
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"systemCell" forIndexPath:indexPath];
        
        UIView *halfView = [cell.contentView viewWithTag:9527];
        if (!halfView)
        {
            if (indexPath.item == 0)
            {
                halfView = [[ZVHeaderRulerView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width/2, 50)];
                ZVHeaderRulerView *header = (ZVHeaderRulerView *)halfView;
                header.backgroundColor = [UIColor whiteColor];
                header.minValue = _minValue;
                header.unit = _unit;
                [cell.contentView addSubview:header];
            }
            else
            {
                halfView = [[ZVFooterRulerView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width/2, 50)];
                ZVFooterRulerView *footer = (ZVFooterRulerView *)halfView;
                footer.backgroundColor = [UIColor whiteColor];
                footer.maxValue = _maxValue;
                footer.unit = _unit;
                [cell.contentView addSubview:footer];
            }
        }
        
        return cell;
    }
    else
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"custemCell" forIndexPath:indexPath];
        ZVRulerView *ruleView = [cell.contentView viewWithTag:9527];
        if (!ruleView)
        {
            ruleView                 = [[ZVRulerView alloc]initWithFrame:CGRectMake(0, 0, dialGap*10, 50)];
            ruleView.backgroundColor = [UIColor whiteColor];
            ruleView.tag             = 9527;
            ruleView.unit            = _unit;
            [cell.contentView addSubview:ruleView];
        }
        ruleView.minValue = _step*10.f*(indexPath.item-1) + _minValue;
        ruleView.maxValue = _step*10.f*indexPath.item + _minValue;
        [ruleView setNeedsDisplay];
        
        return cell;
    }
}

-(CGSize )collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0 || indexPath.item == _stepNum+1)
    {
        return CGSizeMake(self.frame.size.width/2, 50.f);
    }
    else
    {
        return CGSizeMake(dialGap*10.f, 50.f);
    }
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self];
    if (point.y < self.frame.size.height-50-20)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ZVScrollSliderDidTouch:)])
        {
            [self.delegate ZVScrollSliderDidTouch:self];
        }
    }
}

#pragma mark UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_scrollByHand)
    {
        int value = scrollView.contentOffset.x/(dialGap);
        _valueTF.text = [NSString stringWithFormat:@"%d",(value+_minValue)*_step];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _scrollByHand = YES;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)//拖拽时没有滑动动画
    {
        if (scrollView.contentOffset.x < 0) {
            [scrollView setContentOffset:CGPointMake(0, 0)];
        }
        [self setRealValue:round(scrollView.contentOffset.x/(dialGap))+_minValue Animated:YES];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self setRealValue:round(scrollView.contentOffset.x/(dialGap)) Animated:YES];
}

@end// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com