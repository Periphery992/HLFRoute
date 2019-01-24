//
//  HLFRouteRequest.h
//  CocoaLumberjack
//
//  Created by 陈舒澳 on 2018/12/3.
//

#import <Foundation/Foundation.h>

@interface HLFRouteRequest : NSObject

@property (nonatomic, strong ,readonly) NSURL *url;
@property (nonatomic, strong ,readonly) NSMutableDictionary *parameters;
@property (nonatomic, copy) void(^callBack)(NSError *error, id responseObject);

/**
 创建路由请求

 @param url 路由url
 @param routeExpression 路由表达式
 @param primitiveParams 原生参数字典
 @param callBack 结果回调
 @return 路由请求实例
 */
- (instancetype)initWithURL:(NSURL *)url routeExpression:(NSString *)routeExpression primitiveParams:(NSDictionary *)primitiveParams callBack:(void(^)(NSError *error, id responseObject))callBack;

/**
 检测参数是否符合要求

 @return YES 符合 ，NO 不符合
 */
- (BOOL)checkQueryParameters;
@end
