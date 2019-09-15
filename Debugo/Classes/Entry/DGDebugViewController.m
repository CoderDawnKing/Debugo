//
//  DGDebugViewController.m
//  Debugo
//
//  GitHub https://github.com/ripperhe/Debugo
//  Created by ripper on 2018/9/1.
//  Copyright © 2018年 ripper. All rights reserved.
//

#import "DGDebugViewController.h"
#import "DGCommon.h"
#import "DGAssistant.h"
#import "DGNavigationController.h"
#import "DGActionViewController.h"
#import "DGFileViewController.h"
#import "DGPluginViewController.h"

@interface DGDebugViewController ()

@property (nonatomic, weak) UITabBarController *tabBarController;
@property (nonatomic, weak) UIView *contentView;

@end

@implementation DGDebugViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(debugWindowWillShow:) name:DGDebugWindowWillShowNotificationKey object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(debugWindowDidHidden:) name:DGDebugWindowDidHiddenNotificationKey object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITabBarController *tabBarVC = [self generateTabBarController];
    [self addChildViewController:tabBarVC];
    [self.view addSubview:tabBarVC.view];
    self.contentView = tabBarVC.view;
    self.tabBarController = tabBarVC;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.contentView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
}

- (UITabBarController *)generateTabBarController {
    UITabBarController *tabBarVC = [UITabBarController new];
    tabBarVC.tabBar.tintColor = kDGHighlightColor;
    
    DGActionViewController *actionVC = [[DGActionViewController alloc] initWithStyle:UITableViewStyleGrouped];
    actionVC.navigationItem.title = @"指令";
    DGNavigationController *actionNavigationVC = [[DGNavigationController alloc] initWithRootViewController:actionVC];
    actionNavigationVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"指令" image:[[DGBundle imageNamed:@"tab_action_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[DGBundle imageNamed:@"tab_action_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    DGFileViewController *fileVC = [[DGFileViewController alloc] initWithStyle:UITableViewStyleGrouped];
    fileVC.navigationItem.title = @"文件";
    DGNavigationController *fileNavigationVC = [[DGNavigationController alloc] initWithRootViewController:fileVC];
    fileVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"文件" image:[[DGBundle imageNamed:@"tab_file_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[DGBundle imageNamed:@"tab_file_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    DGPluginViewController *pluginVC = [DGPluginViewController new];
    pluginVC.navigationItem.title = @"工具";
    DGNavigationController *pluginNavigationVC = [[DGNavigationController alloc] initWithRootViewController:pluginVC];
    pluginVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"工具" image:[[DGBundle imageNamed:@"tab_plugin_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[DGBundle imageNamed:@"tab_plugin_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    tabBarVC.viewControllers = @[actionNavigationVC, fileNavigationVC, pluginNavigationVC];
    [tabBarVC.viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:kDGHighlightColor} forState:UIControlStateSelected];
        [obj.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.572549 green:0.572549 blue:0.572549 alpha:1.0]} forState:UIControlStateNormal];
    }];
    return tabBarVC;
}

#pragma mark - notification
- (void)debugWindowWillShow:(NSNotification *)sender {
    // Window 隐藏再显示，不会调用 viewWillAppear；为了保证调用子控制器的 viewWillAppear，window 显示的时候重新添加
    if (self.contentView && !self.contentView.superview) {
        [self.view addSubview:self.contentView];
    }
}

- (void)debugWindowDidHidden:(NSNotification *)sender {
    if (self.contentView) {
        [self.contentView removeFromSuperview];
    }
}

@end
