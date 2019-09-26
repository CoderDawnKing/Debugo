//
//  UIColor+Debugo.h
//  Debugo-Example-ObjectiveC
//
//  Created by ripper on 2019/9/26.
//  Copyright © 2019 ripperhe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Debugo)

/// 随机色
+ (UIColor *)dg_randomColor;
/// 浅色系的随机色
+ (UIColor *)dg_lightRandomColor;

@end

NS_ASSUME_NONNULL_END
