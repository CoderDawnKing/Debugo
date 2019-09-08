//
//  DGAccountManager.h
//  Debugo-Example-ObjectiveC
//
//  Created by ripper on 2019/5/31.
//  Copyright © 2019 ripperhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DGBase.h"
#import "DGSuspensionBubble.h"
#import "DGAccountConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface DGAccountManager : NSObject

@property (nonatomic, strong) DGAccountConfiguration *configuration;

@property (nonatomic, strong, nullable) NSArray <DGAccount *>*currentCommonAccountArray;
@property (nonatomic, strong, nullable) DGOrderedDictionary <NSString *, DGAccount *>*temporaryAccountDic;


+ (instancetype)shared;

- (void)setupWithConfiguration:(DGAccountConfiguration *)configuration;

- (void)reset;

- (void)addAccount:(DGAccount *)account;


@property (nonatomic, weak, readonly) DGSuspensionBubble *loginBubble;
@property (nonatomic, weak, readonly) DGWindow *loginWindow;

- (void)showLoginBubble;

- (void)removeLoginBubble;
- (void)removeLoginWindow;
@end

NS_ASSUME_NONNULL_END
