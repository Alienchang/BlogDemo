//
//  TTGradientLabel.h
//  Pomelo
//
//  Created by Alienchang on 2023/8/8.
//  Copyright © 2023 Pomelo. All rights reserved.

#import <UIKit/UIKit.h>
#import "TTUserColorfulNickModel.h"

typedef enum:NSInteger {
    TTGradientNone = 0,
    TTGradientStatic,
    TTGradientColorful,
} GradientType;

@interface TTGradientLabel : UIView

@property (nonatomic ,copy) NSString * text;
@property (nonatomic ,copy) NSAttributedString *attributedText;
@property (nonatomic,strong) UIColor * textColor;
@property(nonatomic) NSTextAlignment textAlignment;
@property(nonatomic,strong) UIFont * font;
@property (nonatomic,assign) GradientType type;
@property (nonatomic ,assign) CGPoint startPoint;
@property (nonatomic ,assign) CGPoint endPoint;
@property (nonatomic ,assign) BOOL disableAnimation;

- (void)setupWithCGColors:(NSArray*)cgColors
             useHighlight:(BOOL)useHighlight;

- (void)setupWithColorfulNickModel:(TTUserColorfulNickModel *)model;
@end
