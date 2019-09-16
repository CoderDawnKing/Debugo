//
//  DGPlugin.h
//  Debugo-Example-ObjectiveC
//
//  Created by ripper on 2019/9/9.
//  Copyright © 2019 ripperhe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DGPluginProtocol <NSObject>

/// 组件名称；默认为类名
+ (NSString *)pluginName;

/// 组件图像；不设置则使用默认图像
+ (UIImage *)pluginImage;

/// 组件在当前环境是否可以使用；默认为 YES；
+ (BOOL)pluginSupport;

/// 组件对应视图控制器的类；如果实现了本方法，点击本工具按钮会跳转到该页面；否则，会直接启用本工具
+ (Class)pluginViewControllerClass;

/// 组件开关
@property (class, nonatomic, assign) BOOL pluginSwitch;

@end

// 所有组件方法均用于子类重写(所有方法可不重写)，无需调用父类
@interface DGPlugin : NSObject<DGPluginProtocol>

@end

NS_ASSUME_NONNULL_END
