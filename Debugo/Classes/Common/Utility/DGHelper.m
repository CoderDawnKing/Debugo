//
//  DGCurrentUser.m
//  Debugo-Example-ObjectiveC
//
//  Created by ripper on 2019/5/31.
//  Copyright © 2019 ripperhe. All rights reserved.
//

#import "DGHelper.h"
#import "DGLog.h"

NSString * dg_current_user() {
    static NSString *_currentUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [NSString stringWithFormat:@"%s", __FILE__];
        if ([path hasPrefix:@"/Users/"]) {
            NSArray *components = [path componentsSeparatedByString:@"/"];
            if (components.count > 3) {
                _currentUser = components[2];
            }
        }
        DGCLog(@"dg_current_user: %@", _currentUser);
    });
    return _currentUser;
}

void dg_exec(NSString *user, void (NS_NOESCAPE ^handler)(void)) {
    NSString *currentUser = dg_current_user();
    if (!currentUser.length || !user.length) return;
    if (![currentUser isEqualToString:user]) return;
    
    if (handler) {
        handler();
    }
}

void dg_dispatch_main_safe(void(^block)(void)) {
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {
        block();
    }else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

id dg_invoke(id any, SEL selector, NSArray *args) {
    if (!any || selector == NULL) {
        return nil;
    }
    NSMethodSignature *signature = [any methodSignatureForSelector:selector];
    if (signature) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:any];
        [invocation setSelector:selector];
        [args enumerateObjectsUsingBlock:^(id  _Nonnull argument, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx >= (signature.numberOfArguments - 2)) {
                *stop = YES;
                return;
            }
            if ([argument isKindOfClass:[NSNull class]]) {
                return;
            }
            NSInteger index = idx + 2;
            const char *encode = [signature getArgumentTypeAtIndex:index];
            if (strcmp(encode, @encode(void)) == 0) {
            } else if (strcmp(encode, @encode(id)) == 0) {
                [invocation setArgument:&argument atIndex:index];
            } else if (strcmp(encode, @encode(Class)) == 0) {
                Class value = [argument class];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(encode, @encode(char)) == 0) {
                char value = [argument charValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(encode, @encode(int)) == 0) {
                int value = [argument intValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(encode, @encode(short)) == 0) {
                short value = [argument shortValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(encode, @encode(long)) == 0) {
                long value = [argument longValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(encode, @encode(long long)) == 0) {
                long long value = [argument longLongValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(encode, @encode(unsigned char)) == 0) {
                unsigned char value = [argument unsignedCharValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(encode, @encode(unsigned int)) == 0) {
                unsigned int value = [argument unsignedIntValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(encode, @encode(unsigned short)) == 0) {
                unsigned short value = [argument unsignedShortValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(encode, @encode(unsigned long)) == 0) {
                unsigned long value = [argument unsignedLongValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(encode, @encode(unsigned long long)) == 0) {
                unsigned long long value = [argument unsignedLongLongValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(encode, @encode(float)) == 0) {
                float value = [argument floatValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(encode, @encode(double)) == 0) {
                double value = [argument doubleValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(encode, @encode(BOOL)) == 0) {
                BOOL value = [argument boolValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(encode, @encode(CGPoint)) == 0) {
                CGPoint value = [argument CGPointValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(encode, @encode(CGSize)) == 0) {
                CGSize value = [argument CGSizeValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(encode, @encode(CGRect)) == 0) {
                CGRect value = [argument CGRectValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(encode, @encode(UIEdgeInsets)) == 0) {
                UIEdgeInsets value = [argument UIEdgeInsetsValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(encode, @encode(char *)) == 0) {
                const char *value = [argument UTF8String];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(encode, @encode(SEL)) == 0) {
                IMP imp = [argument pointerValue];
                [invocation setArgument:&imp atIndex:index];
            }  else if (strcmp(encode, @encode(IMP))) {
                SEL sel = [argument pointerValue];
                [invocation setArgument:&sel atIndex:index];
            } else {
                NSCAssert(0, @"dg_invoke: 参数类型不支持");
            }
        }];
        [invocation retainArguments];
        [invocation invoke];
        if (signature.methodReturnLength) {
            __unsafe_unretained id returnValue;
            const char *encode = signature.methodReturnType;
            if (strcmp(encode, @encode(void)) == 0) {
            } else if (strcmp(encode, @encode(id)) == 0) {
                [invocation getReturnValue:&returnValue];
            } else if (strcmp(encode, @encode(Class)) == 0) {
                [invocation getReturnValue:&returnValue];
            } else if (strcmp(encode, @encode(char)) == 0) {
                char value;
                [invocation getReturnValue:&value];
                returnValue = @(value);
            } else if (strcmp(encode, @encode(int)) == 0) {
                int value;
                [invocation getReturnValue:&value];
                returnValue = @(value);
            } else if (strcmp(encode, @encode(short)) == 0) {
                short value;
                [invocation getReturnValue:&value];
                returnValue = @(value);
            } else if (strcmp(encode, @encode(long)) == 0) {
                long value;
                [invocation getReturnValue:&value];
                returnValue = @(value);
            } else if (strcmp(encode, @encode(long long)) == 0) {
                long long value;
                [invocation getReturnValue:&value];
                returnValue = @(value);
            } else if (strcmp(encode, @encode(unsigned char)) == 0) {
                unsigned char value;
                [invocation getReturnValue:&value];
                returnValue = @(value);
            } else if (strcmp(encode, @encode(unsigned int)) == 0) {
                unsigned int value;
                [invocation getReturnValue:&value];
                returnValue = @(value);
            } else if (strcmp(encode, @encode(unsigned short)) == 0) {
                unsigned short value;
                [invocation getReturnValue:&value];
                returnValue = @(value);
            } else if (strcmp(encode, @encode(unsigned long)) == 0) {
                unsigned long value;
                [invocation getReturnValue:&value];
                returnValue = @(value);
            } else if (strcmp(encode, @encode(unsigned long long)) == 0) {
                unsigned long long value;
                [invocation getReturnValue:&value];
                returnValue = @(value);
            } else if (strcmp(encode, @encode(float)) == 0) {
                float value;
                [invocation getReturnValue:&value];
                returnValue = @(value);
            } else if (strcmp(encode, @encode(double)) == 0) {
                double value;
                [invocation getReturnValue:&value];
                returnValue = @(value);
            } else if (strcmp(encode, @encode(BOOL)) == 0) {
                BOOL value;
                [invocation getReturnValue:&value];
                returnValue = @(value);
            } else if (strcmp(encode, @encode(CGPoint)) == 0) {
                CGPoint value;
                [invocation getReturnValue:&value];
                returnValue = [NSValue valueWithCGPoint:value];
            } else if (strcmp(encode, @encode(CGSize)) == 0) {
                CGSize value;
                [invocation getReturnValue:&value];
                returnValue = [NSValue valueWithCGSize:value];
            } else if (strcmp(encode, @encode(CGRect)) == 0) {
                CGRect value;
                [invocation getReturnValue:&value];
                returnValue = [NSValue valueWithCGRect:value];
            } else if (strcmp(encode, @encode(UIEdgeInsets)) == 0) {
                UIEdgeInsets value;
                [invocation getReturnValue:&value];
                returnValue = [NSValue valueWithUIEdgeInsets:value];
            } else if (strcmp(encode, @encode(char *)) == 0) {
                const char *value;
                [invocation getReturnValue:&value];
                returnValue = [NSString stringWithUTF8String:value];
            } else if (strcmp(encode, @encode(SEL)) == 0) {
                SEL sel;
                [invocation getReturnValue:&sel];
                returnValue = [NSValue valueWithPointer:sel];
            }  else if (strcmp(encode, @encode(IMP))) {
                IMP imp;
                [invocation getReturnValue:&imp];
                returnValue = [NSValue valueWithPointer:imp];
            } else {
                NSCAssert(0, @"dg_invoke: 参数类型不支持");
            }
            id value = returnValue ?: nil;
            return value;
        }
    }else {
        NSLog(@"dg_invoke: %@ 的 \"%@\" 方法没有找到", any, NSStringFromSelector(selector));
    }
    return nil;
}

#if DebugoCanBeEnabled
void dg_exec_main_queue_only_can_be_enabled(void (^block)(void)) {
    dg_dispatch_main_safe(block);
}
#endif
