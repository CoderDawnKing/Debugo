//
//  DGAssistant.m
//  Debugo
//
//  GitHub https://github.com/ripperhe/Debugo
//  Created by ripper on 2018/9/1.
//  Copyright © 2018年 ripper. All rights reserved.
//


#import "DGAssistant.h"
#import "DGFPSLabel.h"
#import "DGCache.h"
#import "DGQuickLoginViewController.h"

static NSString * const kDGDebugWindowKey = @"kDGDebugWindowKey";
static NSString * const kDGLoginWindowKey = @"kDGLoginWindowKey";

NSString *const DGDebugWindowWillShowNotificationKey = @"DGDebugWindowWillShowNotificationKey";
NSString *const DGDebugWindowDidHiddenNotificationKey = @"DGDebugWindowDidHiddenNotificationKey";

NSInteger const DGDebugBubbleTag = 1;
NSInteger const DGLoginBubbleTag = 2;
UIWindowLevel const DGContentWindowLevel = 999999;

@interface DGAssistant ()<DGSuspensionBubbleDelegate>

@property (nonatomic, weak) DGSuspensionBubble *debugBubble;
@property (nonatomic, weak) DGWindow *debugWindow;
@property (nonatomic, weak, nullable) DGDebugViewController *debugViewController;

@property (nonatomic, weak) DGSuspensionBubble *loginBubble;
@property (nonatomic, weak, nullable) DGWindow *loginWindow;

@end

@implementation DGAssistant

static DGAssistant *_instance;
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
- (void)setupWithConfiguration:(DGConfiguration *)configuration {
    _instance->_configuration = [configuration copy];
    
    [DGCache.shared.settingPlister setBool:self.configuration.isShowBottomBarWhenPushed forKey:kDGSettingIsShowBottomBarWhenPushed];
    
    [self refreshDebugBubbleWithIsOpenFPS:self.configuration.isOpenFPS];
    [DGCache.shared.settingPlister setBool:self.configuration.isOpenFPS forKey:kDGSettingIsOpenFPS];
    
    DGTouchMonitor.shared.shouldDisplayTouches = self.configuration.isShowTouches;
    [DGCache.shared.settingPlister setBool:self.configuration.isShowTouches forKey:kDGSettingIsShowTouches];

    if (self.configuration.accountEnvironmentIsBeta) {
        self.currentCommonAccountArray = self.configuration.commonBetaAccounts;
    }else{
        self.currentCommonAccountArray = self.configuration.commonOfficialAccounts;
    }

    if (self.configuration.needLoginBubble && (self.configuration.haveLoggedIn == NO)) {
        [self showLoginBubble];
    }
    [self showDebugBubble];
}

- (void)reset {
    [self refreshDebugBubbleWithIsOpenFPS:NO];
    DGTouchMonitor.shared.shouldDisplayTouches = NO;
    
    self->_configuration = nil;
    self.currentCommonAccountArray = nil;
    
    [self removeDebugBubble];
    [self removeDebugWindow];
    
    [self removeLoginBubble];
    [self removeLoginWindow];
}

- (void)addActionForUser:(NSString *)user withTitle:(NSString *)title autoClose:(BOOL)autoClose handler:(DGActionHandlerBlock)handler {
    DGAction *action = [DGAction actionWithTitle:title autoClose:autoClose handler:handler];
    if (!action.isValid) {
        NSAssert(0, @"DGAction : titile 和 handler 不能为空!");
        return;
    }
    
    if (user.length) {
        action.user = user;
        DGOrderedDictionary <NSString *, DGAction *>*actionDic = [self.usersActionsDic objectForKey:user];
        if (!actionDic) {
            actionDic = [DGOrderedDictionary dictionary];
            actionDic.moveToLastWhenUpdateValue = YES;
            [self.usersActionsDic setObject:actionDic forKey:user];
        }
        [actionDic setObject:action forKey:action.title];
    }else {
        [self.anonymousActionDic setObject:action forKey:action.title];
    }
}

- (void)addAccountWithUsername:(NSString *)username password:(NSString *)password {
    DGAccount *newAccount = [DGAccount accountWithUsername:username password:password];
    if (!newAccount.isValid) return;
    
    for (DGAccount *account in self.currentCommonAccountArray) {
        if ([newAccount.username isEqualToString:account.username] && [newAccount.password isEqualToString:account.password]) {
            // 重复账号 忽略
            return;
        }
    }
    
    // 在 permanent 中没有重复账号，添加到 temporary
    [self.temporaryAccountDic setObject:newAccount forKey:newAccount.username];
    // 缓存到本地
    [DGCache.shared.accountPlister setObject:newAccount.password forKey:newAccount.username];
}

#pragma mark - getter
- (NSMutableDictionary<NSString *,DGOrderedDictionary<NSString *,DGAction *> *> *)usersActionsDic {
    if (!_usersActionsDic) {
        _usersActionsDic = [NSMutableDictionary dictionary];
    }
    return _usersActionsDic;
}

- (DGOrderedDictionary<NSString *,DGAction *> *)anonymousActionDic {
    if (!_anonymousActionDic) {
        _anonymousActionDic = [DGOrderedDictionary dictionary];
        _anonymousActionDic.moveToLastWhenUpdateValue = YES;
    }
    return _anonymousActionDic;
}

- (DGOrderedDictionary<NSString *,DGAccount *> *)temporaryAccountDic {
    if (!_temporaryAccountDic) {
        DGOrderedDictionary *accountDic = [DGOrderedDictionary dictionary];
        // 获取本地缓存
        NSDictionary *cacheAccount = [DGCache.shared.accountPlister read];
        NSArray *sortedKeys = [cacheAccount.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *  _Nonnull obj1, NSString *  _Nonnull obj2) {
            return [obj2 compare:obj1];
        }];
        [sortedKeys enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DGAccount *account = [DGAccount accountWithUsername:obj password:[cacheAccount objectForKey:obj]];
            if (account.isValid) {
                [accountDic setObject:account forKey:account.username];
            }
        }];
        _temporaryAccountDic = accountDic;
    }
    return _temporaryAccountDic;
}

#pragma mark - debug bubble
- (void)refreshDebugBubbleWithIsOpenFPS:(BOOL)isOpenFPS {
    if (!self.debugBubble) return;
    
    if (isOpenFPS) {
        if (!self.debugBubble.dg_weakExtObj) {
            // 添加 FPSLabel
            DGFPSLabel *label = [DGFPSLabel new];
            label.backgroundColor = [UIColor clearColor];
            label.frame = CGRectMake(0, 0, 50, 30);
            label.center = CGPointMake(55/2.0, 55/2.0);
            [self.debugBubble.contentView addSubview:label];
            self.debugBubble.dg_weakExtObj = label;
        }
        self.debugBubble.button.backgroundColor = [UIColor colorWithRed:0.07 green:0.07 blue:0.07 alpha:1.00];
        [self.debugBubble.button setImage:nil forState:UIControlStateNormal];
    }else{
        [self.debugBubble.dg_weakExtObj removeFromSuperview];
        self.debugBubble.dg_weakExtObj = nil;
        self.debugBubble.button.backgroundColor = [UIColor colorWithRed:0.0 green:0.478431 blue:1.0 alpha:1.0];
        [self.debugBubble.button setImage:[DGBundle imageNamed:@"debug_bubble"] forState:UIControlStateNormal];
    }
}

- (void)showDebugBubble {
    if (self.debugBubble) {
        [self.debugBubble setHidden:NO];
        return;
    }
    
    DGSuspensionBubbleConfig *config = [DGSuspensionBubbleConfig new];
    config.buttonType = UIButtonTypeSystem;
    config.leanStateAlpha = .9;
    
    DGSuspensionBubble *debugBubble = [[DGSuspensionBubble alloc] initWithFrame:CGRectMake(400, kDGScreenH - (255 + 55 + kDGBottomSafeMargin), 55, 55)
                                                                       config:config];
    debugBubble.name = @"Debug Bubble";
    debugBubble.tag = DGDebugBubbleTag;
    debugBubble.dg_delegate = self;
    [debugBubble.button setTintColor:[UIColor whiteColor]];
    [debugBubble show];
    self.debugBubble = debugBubble;
    [self refreshDebugBubbleWithIsOpenFPS:self.configuration.isOpenFPS];
}

- (void)removeDebugBubble {
    [self.debugBubble removeFromScreen];
}

#pragma mark - debug view controller
- (void)removeDebugWindow {
    [self closeDebugWindow];
    [DGSuspensionBubbleManager.shared destroyWindowForKey:kDGDebugWindowKey];
}

- (void)closeDebugWindow {
    DGWindow *containerWindow = self.debugWindow;
    containerWindow.dg_canBecomeKeyWindow = NO;
    if (containerWindow.isKeyWindow) {
        [containerWindow.lastKeyWindow makeKeyWindow];
        containerWindow.lastKeyWindow = nil;
    }
    [containerWindow setHidden:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:DGDebugWindowDidHiddenNotificationKey object:nil userInfo:nil];
}

- (void)openDebugWindow {
    [[NSNotificationCenter defaultCenter] postNotificationName:DGDebugWindowWillShowNotificationKey object:nil];
    DGWindow *containerWindow = self.debugWindow;
    containerWindow.lastKeyWindow = [UIApplication sharedApplication].keyWindow;
    containerWindow.dg_canBecomeKeyWindow = YES;
    if ([DGDebugo keyboardWindow]) {
        // 有键盘的时候，防止挡住视图；没有键盘的时候，尽量不改变 keyWindow
        [containerWindow makeKeyAndVisible];
    }else {
        [containerWindow setHidden:NO];
    }
}

#pragma mark - login bubble
- (void)showLoginBubble {
    if (self.loginBubble) {
        if (!self.loginBubble.rootViewController) {
            NSLog(@"💥💥💥💥💥💥💥💥 woca 出大事儿了，一定是 UIDxxx 引用了我的 Window ！将就用吧，不就是多开辟一点内存嘛 🤣 ");
            [self.loginBubble setHidden:YES];
            self.loginBubble = nil;
        }else{
            [self.loginBubble setHidden:NO];
            return;
        }
    }
    
    DGSuspensionBubbleConfig *config = [DGSuspensionBubbleConfig new];
    config.buttonType = UIButtonTypeSystem;
    config.leanStateAlpha = .9;
    config.showLongPressAnimation = NO;
    
    DGSuspensionBubble *loginBubble = [[DGSuspensionBubble alloc] initWithFrame:CGRectMake(400, kDGScreenH - (165 + 55 + kDGBottomSafeMargin), 55, 55)
                                                                       config:config];
    loginBubble.name = @"Login Bubble";
    loginBubble.tag = DGLoginBubbleTag;
    loginBubble.dg_delegate = self;
    [loginBubble.button setTintColor:[UIColor whiteColor]];
    loginBubble.button.backgroundColor = [UIColor colorWithRed:0.15 green:0.74 blue:0.30 alpha:1.00];
    [loginBubble.button setImage:[DGBundle imageNamed:@"login_bubble"] forState:UIControlStateNormal];
    [loginBubble show];
    self.loginBubble = loginBubble;
}

- (void)removeLoginBubble {
    [self.loginBubble removeFromScreen];
}

#pragma mark - login view controller
- (void)removeLoginWindow {
    [DGSuspensionBubbleManager.shared destroyWindowForKey:kDGLoginWindowKey];
}

#pragma mark - DGSuspensionBubbleDelegate
- (void)suspensionBubbleClick:(DGSuspensionBubble *)suspensionBubble {
    if (suspensionBubble.tag == DGDebugBubbleTag) {
        // debug
        if (self.debugWindow) {
            if (self.debugWindow.isHidden == NO) {
                // hidden
                [self closeDebugWindow];
            }else {
                // show
                [self removeLoginWindow];
                [self openDebugWindow];
            }
        }else{
            // create
            DGDebugViewController *debugVC = [[DGDebugViewController alloc] init];
            DGWindow *window = [[DGWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            window.name = @"Debug Window";
            window.rootViewController = debugVC;
            window.windowLevel = DGContentWindowLevel;
            [DGSuspensionBubbleManager.shared saveWindow:window forKey:kDGDebugWindowKey];
            
            self.debugViewController = debugVC;
            self.debugWindow = window;
            
            // show
            [self removeLoginWindow];
            [self openDebugWindow];
        }
    }else{
        // login
        if (self.loginWindow) {
            // remove
            [self removeLoginWindow];
        }else{
            // create
            DGQuickLoginViewController *loginVC = [[DGQuickLoginViewController alloc] init];
            DGWindow *window = [[DGWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            window.name = @"Login Window";
            window.rootViewController = loginVC;
            window.windowLevel = DGContentWindowLevel;
            
            [DGSuspensionBubbleManager.shared saveWindow:window forKey:kDGLoginWindowKey];
            self.loginWindow = window;
            
            // show
            [self closeDebugWindow];
            [self.loginWindow setHidden:NO];
        }
    }
}

@end
