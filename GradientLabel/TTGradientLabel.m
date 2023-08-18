//  TTGradientLabel.m
//  Pomelo
//
//  Created by Alienchang on 2023/8/8.
//  Copyright © 2023 Pomelo. All rights reserved.

#import "TTGradientLabel.h"
#import <Masonry/Masonry.h>
#import <UIKit/UIKit.h>
@interface TTGradientLabel()

@property (nonatomic ,strong) CAGradientLayer * gradientLayer;
@property (nonatomic ,strong) NSArray *cgColors;
@property (nonatomic ,strong) NSArray *originalCGColors;
@property (nonatomic ,strong) NSArray <NSNumber *>*positions;
@property (nonatomic ,strong) UILabel *gradientLabel;
@property (nonatomic ,strong) UILabel *normalLabel;
@end

@implementation TTGradientLabel

- (instancetype)init{
    if (self = [super init]){
        self.textColor = [UIColor blackColor];
        self.textAlignment = NSTextAlignmentCenter;
        self.font = [UIFont systemFontOfSize:24 weight:(UIFontWeightBold)];
        self.type = TTGradientNone;
        [self addSubview:self.normalLabel];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]){
        self.textColor = [UIColor blackColor];
        self.textAlignment = NSTextAlignmentCenter;
        self.font = [UIFont systemFontOfSize:24 weight:(UIFontWeightBold)];
        self.type = TTGradientNone;
        [self addSubview:self.normalLabel];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        self.textColor = [UIColor blackColor];
        self.textAlignment = NSTextAlignmentCenter;
        self.font = [UIFont systemFontOfSize:24 weight:(UIFontWeightBold)];
        self.type = TTGradientNone;
        [self addSubview:self.normalLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.normalLabel.frame = self.bounds;
}

#pragma mark -- private func
- (void)initGradientLayer {
    self.gradientLayer.startPoint = self.startPoint;
    self.gradientLayer.endPoint = self.endPoint;
    switch (self.type) {
        case TTGradientNone:
        {
            self.normalLabel.hidden = NO;
            self.gradientLayer.hidden = YES;
        }
            break;
        case TTGradientStatic:
        {
            self.gradientLayer.colors = self.originalCGColors;
            self.gradientLayer.locations = @[@(0),@(1)];
            self.normalLabel.hidden = YES;
            self.gradientLayer.hidden = NO;
        }
            break;
        case TTGradientColorful:
        {
            NSArray * colors = self.cgColors?self.cgColors:@[(__bridge id)[UIColor redColor].CGColor,
                                 (__bridge id)[UIColor yellowColor].CGColor,
                                 (__bridge id)[UIColor blueColor].CGColor,
                                 (__bridge id)[UIColor redColor].CGColor];
            self.gradientLayer.colors = colors;
            NSArray * locations = self.positions?self.positions:@[@(0.2),@(0.4),@(0.6),@(0.8)];
            self.gradientLayer.locations = locations;
            self.normalLabel.hidden = YES;
            self.gradientLayer.hidden = NO;
        }
            break;
        default:
            break;
    }
    
    if (self.type != TTGradientNone) {
        [self.layer insertSublayer:self.gradientLayer atIndex:0];
    } else {
        self.normalLabel.hidden = NO;
        self.gradientLayer.hidden = YES;
    }
}

- (void)gradientAnimation {
    CABasicAnimation * anim = [CABasicAnimation animationWithKeyPath:@"locations"];
    switch (self.type) {
        case TTGradientColorful:
        {
            CGFloat progress = 0.5 /self.cgColors.count;
            NSMutableArray *fromValue = [NSMutableArray new];
            NSMutableArray *toValue = [NSMutableArray new];
            for (NSInteger i = 0; i < self.cgColors.count; ++i) {
                [fromValue addObject:@(i * progress)];
                [toValue insertObject:@(1 - i * progress) atIndex:0];
            }
            
            if (self.startPoint.x < self.endPoint.x) {
                anim.fromValue = fromValue;
                anim.toValue = toValue;
            } else {
                anim.fromValue = @[@(-0.55),@(-0.4),@(-0.3),@(-0.2),@(-0.1)];
                anim.toValue = @[@(0.55),@(0.575),@(0.75),@(0.875),@(1)];
            }
        }
            break;
        default:
            break;
    }

    if (self.type != TTGradientNone) {
        self.gradientLayer.hidden = NO;
        if (self.type == TTGradientStatic) {
            self.gradientLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
            self.gradientLabel.frame = self.bounds;
        } else {
            anim.duration = 3.0;
            anim.repeatCount = CGFLOAT_MAX;
            anim.removedOnCompletion = NO;
            [self.gradientLayer addAnimation:anim forKey:@"Gradient"];
            self.gradientLayer.frame = CGRectMake(- self.bounds.size.width, -self.bounds.size.height, 3 * self.bounds.size.width, 3 * self.bounds.size.height);
            self.gradientLabel.frame = self.bounds;
            self.gradientLabel.x = self.bounds.size.width;
            self.gradientLabel.y = self.bounds.size.height;
        }
        
        self.gradientLayer.mask = self.gradientLabel.layer;
    } else {
        self.normalLabel.hidden = NO;
        self.gradientLayer.hidden = YES;
    }
}

#pragma mark -- public func
- (void)setupWithCGColors:(NSArray*)cgColors
             useHighlight:(BOOL)useHighlight {
    self.originalCGColors = cgColors;
    NSMutableArray *tempCGColors = [NSMutableArray new];
    NSMutableArray *positions = [NSMutableArray new];
    [tempCGColors addObjectsFromArray:cgColors];
    if (useHighlight) {
        [tempCGColors addObject:(__bridge id)UIColor.whiteColor.CGColor];
    }
    NSInteger loopCount = cgColors.count * 2 + (useHighlight?1:0);
    for (NSInteger i = 0; i < loopCount; ++i) {
        [positions addObject:@(1.0 * (i + 1) / (loopCount + 1))];
    }
    [tempCGColors addObjectsFromArray:[cgColors reverseObjectEnumerator].allObjects];
    self.cgColors = tempCGColors;
    self.positions = positions;
    [self initGradientLayer];
    [self gradientAnimation];
}

- (void)setupWithColorfulNickModel:(TTUserColorfulNickModel *)model {
    NSMutableArray *cgColors = [NSMutableArray new];
    if (!model.colorfulList.count) {
        self.normalLabel.hidden = NO;
        self.gradientLayer.hidden = YES;
        return;
    }

    for (NSString *colorString in model.colorfulList) {
        [cgColors addObject:(__bridge id)[UIColor qmui_colorWithHexString:colorString].CGColor];
    }
    if ([model.type isEqualToString:kColorfulNickTypeLRSG]) {
        self.type = TTGradientStatic;
        [self setupWithCGColors:cgColors useHighlight:NO];
    } else if ([model.type isEqualToString:kColorfulNickTypeLRDG]) {
        self.type = TTGradientColorful;
        [self setupWithCGColors:cgColors useHighlight:NO];
    } else if ([model.type isEqualToString:kColorfulNickTypeLRDGS]) {
        self.type = TTGradientColorful;
        [self setupWithCGColors:cgColors useHighlight:YES];
    } else if ([model.type isEqualToString:kColorfulNickTypeUDSG]) {
        self.type = TTGradientStatic;
        self.startPoint = CGPointMake(0, 0);
        self.endPoint = CGPointMake(0, 1);
        [self setupWithCGColors:cgColors useHighlight:NO];
    } else if ([model.type isEqualToString:kColorfulNickTypeUDDG]) {
        self.type = TTGradientColorful;
        self.startPoint = CGPointMake(0, 0);
        self.endPoint = CGPointMake(0, 1);
        [self setupWithCGColors:cgColors useHighlight:NO];
    } else if ([model.type isEqualToString:kColorfulNickTypeUDDG]) {
        self.type = TTGradientColorful;
        self.startPoint = CGPointMake(0, 0);
        self.endPoint = CGPointMake(0, 1);
        [self setupWithCGColors:cgColors useHighlight:YES];
    } else {
        self.type = TTGradientNone;
        self.normalLabel.hidden = NO;
        self.gradientLayer.hidden = YES;
    }
}

#pragma mark -- setter
- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    self.gradientLabel.textAlignment = textAlignment;
    self.normalLabel.textAlignment = textAlignment;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedText = attributedText;
    self.gradientLabel.attributedText = attributedText;
    self.normalLabel.attributedText = attributedText;
    CGSize size = [attributedText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading) context:nil].size;
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
    }];
    [self layoutIfNeeded];
}

- (void)setText:(NSString *)text {
    _text = text;
    self.normalLabel.text = text;
    self.gradientLabel.text = text;
    CGSize size = [text getTextSizeWithSpecificFont:self.font maxSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    self.size = size;
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
    }];
    [self layoutIfNeeded];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    self.normalLabel.font = font;
    self.gradientLabel.font = font;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.normalLabel.textColor = textColor;
    self.gradientLabel.textColor = textColor;
}

#pragma mark -- getter
- (CGPoint)startPoint {
    if (CGPointEqualToPoint(CGPointZero, _startPoint)) {
        return CGPointMake(0, 0.5);
    } else {
        return _startPoint;
    }
}

- (CGPoint)endPoint {
    if (CGPointEqualToPoint(CGPointZero, _endPoint)) {
        return CGPointMake(1, 0.5);
    } else {
        return _endPoint;
    }
}

- (UILabel *)normalLabel {
    if (!_normalLabel) {
        _normalLabel = [UILabel new];
        _normalLabel.textAlignment = NSTextAlignmentLeft;
        _normalLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _normalLabel;
}

- (UILabel *)gradientLabel {
    if (!_gradientLabel) {
        _gradientLabel = [UILabel new];
        _gradientLabel.textAlignment = NSTextAlignmentLeft;
        _gradientLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _gradientLabel;
}

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer new];
    }
    return _gradientLayer;
}
@end
