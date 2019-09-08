//
//  NSObject+Debugo.h
//  Debugo
//
//  GitHub https://github.com/ripperhe/Debugo
//  Created by ripper on 2018/9/1.
//  Copyright © 2018年 ripper. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSObject (Debugo)

@property (nonatomic, strong) id dg_strongExtObj;
@property (nonatomic, weak) id dg_weakExtObj;
@property (nonatomic, copy) id dg_copyExtObj;

@end

@interface NSObject (Debugo_Runtime)

+ (void)dg_swizzleInstanceMethod:(SEL)originalSelector newSelector:(SEL)newSelector;

+ (void)dg_swizzleClassMethod:(SEL)originalSelector newSelector:(SEL)newSelector;

@end

@interface NSObject (Debugo_Make)

+ (instancetype)dg_make:(void (^)(id obj))block;

- (id)dg_put:(void (^)(id obj))block;

@end
