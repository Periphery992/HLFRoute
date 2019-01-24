//
//  NSError+HLFRoute.h
//  CocoaLumberjack
//
//  Created by 陈舒澳 on 2018/12/12.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSErrorDomain const NSHLFRouteErrorDomain;

typedef enum : NSUInteger {
    HLFRouteErrorSceneRouteExpNoRegister = 1000,   //route表达式未注册
    HLFRouteErrorSceneRouteExpNoPath     = 1001,
    HLFRouteErrorSceneParameterNoMatch   = 1002,   //参数不符合表达式
    HLFRouteErrorSceneParameterNoValue   = 1003,   //参数不存在值
} HLFRouteErrorScene;

@interface NSError (HLFRoute)

+ (NSError *)errorWithErrorScene:(HLFRouteErrorScene)scene errorKeyDescription:(NSString *)keyDescription;
@end
