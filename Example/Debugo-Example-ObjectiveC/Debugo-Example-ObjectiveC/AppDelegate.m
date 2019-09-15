//
//  AppDelegate.m
//  Debugo-Example-ObjectiveC
//
//  Created by ripper on 2019/2/20.
//  Copyright © 2019 ripperhe. All rights reserved.
//

#import "AppDelegate.h"
#import "Debugo.h"
#import "DGPathFetcher.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    /// 启用并配置
    [DGDebugo fireWithConfiguration:^(DGConfiguration * _Nonnull configuration) {
        
        /// 配置指令模块
        [configuration setupActionPlugin:^(DGActionPluginConfiguration * _Nonnull actionConfiguration) {
            [actionConfiguration setCommonActions:@[
                                                    [DGAction actionWithTitle:@"Log Top ViewController 😘" autoClose:YES handler:^(DGAction *action) {
                UIViewController *vc = DGDebugo.topViewController;
                NSLog(@"%@", vc);
            }],
                                                    [DGAction actionWithTitle:@"Log All Window 🧐" autoClose:YES handler:^(DGAction *action) {
                NSArray *array = [DGDebugo getAllWindows];
                NSLog(@"%@", array);
            }],
                                                    ]];
        }];
        
        /// 配置文件模块
        [configuration setupFilePlugin:^(DGFilePluginConfiguration * _Nonnull fileConfiguration) {
            [fileConfiguration setShortcutForDatabasePaths:@[
                                                             NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject,
                                                             [NSBundle mainBundle].bundlePath,
                                                             ]];
            [fileConfiguration setShortcutForAnyPaths:@[
                                                        NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject,
                                                        DGPathFetcher.userDefaultsPlistFilePath,
                                                        ]];
            // 自定义数据库预览列宽
            [fileConfiguration setDatabaseFilePreviewConfigurationBlock:^DGDatabasePreviewConfiguration * _Nullable(NSString * _Nonnull filePath) {
                if (![filePath.lastPathComponent isEqualToString:@"picooc.production.sqlite"]) {
                    return nil;
                }
                DGDatabasePreviewConfiguration *config = [DGDatabasePreviewConfiguration new];
                // 设置 error_info 的列 pk_createTime 的宽度为 200
                [config setSpecialColumnWidthDictionary:@{@"pk_createTime":@(200)}
                                               forTable:@"error_info"];
                return config;
            }];
        }];
        
        /// 配置自动登陆
        [configuration setupAccountPlugin:^(DGAccountPluginConfiguration * _Nonnull accountConfiguration) {
            [accountConfiguration setIsProductionEnvironment:YES];
            [accountConfiguration setCommonDevelopmentAccounts:@[
                                                                [DGAccount accountWithUsername:@"jintianyoudiantoutong@qq.com" password:@"dasinigewangbadan🤣"],
                                                                [DGAccount accountWithUsername:@"wozhendeyoudianxinfan@qq.com" password:@"niyoubenshizaishuoyiju🧐"],
                                                                [DGAccount accountWithUsername:@"kanshenmekan@gmail.com" password:@"meijianguoma😉"],
                                                                [DGAccount accountWithUsername:@"woshikaiwanxiaode@163.com" password:@"zhendezhende😨"],
                                                                ]];
            [accountConfiguration setCommonProductionAccounts:@[
                                                                [DGAccount accountWithUsername:@"wolaile@gmail.com" password:@"😴wozouleoubuwoshuile"],
                                                                [DGAccount accountWithUsername:@"woshixianshangzhanghao@qq.com" password:@"😉wojiuwennipabupa"],
                                                                [DGAccount accountWithUsername:@"xianshangdeniubiba@qq.com" password:@"😍hahahabixude"],
                                                                ]];
            [accountConfiguration setExecuteLoginBlock:^(DGAccount * _Nonnull account) {
                // 在这里实现自动登陆的功能
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                
                UIViewController *currentVC = [DGDebugo topViewController];
                
                // 假设需要在这两个页面自动登录
                Class DebugoVCClass = NSClassFromString(@"ViewController");
                Class LoginVCClass = NSClassFromString(@"LoginViewController");
                
                if (DebugoVCClass && [currentVC isMemberOfClass:DebugoVCClass]) {
                    // 进入到登陆页面
                    [currentVC performSelector:@selector(clickGoToTestLogin) withObject:nil];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        // 执行登陆方法
                        UIViewController *vc = [DGDebugo topViewController];
                        if ([vc isKindOfClass:LoginVCClass]) {
                            [vc performSelector:@selector(sendLoginRequestWithAccount:password:) withObject:account.username withObject:account.password];
                        }
                    });
                }else if (LoginVCClass && [currentVC isMemberOfClass:LoginVCClass]) {
                    // 直接执行登陆方法
                    [currentVC performSelector:@selector(sendLoginRequestWithAccount:password:) withObject:account.username withObject:account.password];
                }else{
                    DGLog(@"本页面不支持登陆");
                }
#pragma clang diagnostic pop
            }];
        }];
    }];
    
    // 随便添加几个指令 👇
    
    [DGDebugo addActionForUser:@"ripper" title:@"今天吃啥啊？" handler:^(DGAction * _Nonnull action) {
        DGLog(@"不知道啊...");
    }];

    [DGDebugo addActionForUser:@"user1" title:@"来个弹窗 🤣" handler:^(DGAction *action) {
        UIAlertController *alerController = [UIAlertController alertControllerWithTitle:@"Ha Ha" message:@"mei shen me, wo jiu xiang xiao yi xia~" preferredStyle:UIAlertControllerStyleAlert];
        [alerController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"mei shen me, wo zhi dao le!");
        }]];
        [action.viewController presentViewController:alerController animated:YES completion:nil];
    } autoClose:NO];

    [DGDebugo addActionForUser:@"user2" title:@"push 新控制器 👉" handler:^(DGAction *action) {
        UIViewController *vc = [UIViewController new];
        vc.view.backgroundColor = [UIColor orangeColor];
        [action.viewController.navigationController pushViewController:vc animated:YES];
    } autoClose:NO];

    [DGDebugo addActionWithTitle:@"打印 windows" handler:^(DGAction *action) {
        DGLog(@"\n%@", [UIApplication sharedApplication].windows);
        [[UIApplication sharedApplication].windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DGLog(@"%f", obj.windowLevel);
        }];
    }];

    [DGDebugo addActionWithTitle:@"打印 [UIScreen mainScreen].bounds" handler:^(DGAction * _Nonnull action) {
        DGLog(@"%@", NSStringFromCGRect([UIScreen mainScreen].bounds));
    }];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"中文 中文 中文" forKey:@"Test UserDefaults"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    return YES;
}

@end
