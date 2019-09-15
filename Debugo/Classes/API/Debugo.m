//
//  Debugo.m
//  Debugo
//
//  GitHub https://github.com/ripperhe/Debugo
//  Created by ripper on 2018/9/1.
//  Copyright © 2018年 ripper. All rights reserved.
//

#import "Debugo.h"
#import "DGAssistant.h"
#import "DGCommon.h"
#import "DebugoEnable.h"
#import "DGActionPlugin.h"
#import "DGAccountPlugin.h"

@interface Debugo()

@property (nonatomic, assign) BOOL isFire;

@end

@implementation Debugo

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        printf("[☄️ %s ● %s ● %d] %s ● %s\n", [NSDate date].dg_dateString.UTF8String, ([NSString stringWithFormat:@"%s", __FILE__].lastPathComponent).UTF8String, __LINE__, NSStringFromSelector(_cmd).UTF8String, [[NSString stringWithFormat:@"Debugo canBeEnabled %@\n", [Debugo canBeEnabled] ? @"✅" : @"❌"] UTF8String]);
    });
}

+ (BOOL)canBeEnabled {
#if DebugoCanBeEnabled
    return YES;
#else
    return NO;
#endif
}

static Debugo *_instance = nil;
+ (instancetype)shared {
    if (!_instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[self alloc] init];
        });
    }
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

#pragma mark -
+ (void)fireWithConfiguration:(void (^)(DGConfiguration *configuration))block {
    dg_exec_main_queue_only_can_be_enabled(^{
        if (Debugo.shared.isFire) return;
        
        Debugo.shared->_isFire = YES;
        DGConfiguration *configuration = [DGConfiguration new];
        if (block) {
            block(configuration);
        }
        [DGAssistant.shared setup];
    });
}

+ (void)closeDebugWindow {
    dg_exec_main_queue_only_can_be_enabled(^{
        if (!Debugo.shared.isFire) return;
        
        [DGAssistant.shared closeDebugWindow];
    });
}

+ (void)executeCodeForUser:(NSString *)user handler:(void (NS_NOESCAPE ^)(void))handler {
    if (![self canBeEnabled]) return;
    dg_exec(user, handler);
}

#pragma mark - action plugin

+ (void)addActionWithTitle:(NSString *)title handler:(DGActionHandlerBlock)handler {
    dg_exec_main_queue_only_can_be_enabled(^{
        [DGActionPlugin.shared addActionForUser:nil withTitle:title autoClose:YES handler:handler];
    });
}

+ (void)addActionWithTitle:(NSString *)title handler:(DGActionHandlerBlock)handler autoClose:(BOOL)autoClose {
    dg_exec_main_queue_only_can_be_enabled(^{
        [DGActionPlugin.shared addActionForUser:nil withTitle:title autoClose:autoClose handler:handler];
    });
}

+ (void)addActionForUser:(NSString *)user title:(NSString *)title handler:(DGActionHandlerBlock)handler {
    dg_exec_main_queue_only_can_be_enabled(^{
        [DGActionPlugin.shared addActionForUser:user withTitle:title autoClose:YES handler:handler];
    });
}

+ (void)addActionForUser:(NSString *)user title:(NSString *)title handler:(nonnull DGActionHandlerBlock)handler autoClose:(BOOL)autoClose {
    dg_exec_main_queue_only_can_be_enabled(^{
        [DGActionPlugin.shared addActionForUser:user withTitle:title autoClose:autoClose handler:handler];
    });
}

#pragma mark - account plugin

+ (void)accountPluginAddAccount:(DGAccount *)account {
    dg_exec_main_queue_only_can_be_enabled(^{
        if ([account isKindOfClass:[DGAccount class]] && account.isValid){
            [DGAccountPlugin.shared addAccount:account];
        }else{
            DGLog(@"获取到未知登陆数据 %@", account);
        }
    });
}

@end

@implementation Debugo (Additional)

+ (UIViewController *)topViewController {
    return [DGUIMagic topViewController];
}

+ (UIViewController *)topViewControllerForWindow:(UIWindow *)window {
    return [DGUIMagic topViewControllerForWindow:window];
}

+ (UIWindow *)topVisibleFullScreenWindow {
    return [DGUIMagic topVisibleFullScreenWindow];
}

+ (UIWindow *)keyboardWindow {
    return [DGUIMagic keyboardWindow];
}

+ (NSArray <UIWindow *>*)getAllWindows {
    return [DGUIMagic getAllWindows];
}

@end
