//
//  HLFRoute.h
//  CocoaLumberjack
//
//  Created by 陈舒澳 on 2018/11/28.
//

#import <Foundation/Foundation.h>

@interface HLFRoute : NSObject
@property (nonatomic, copy) NSString *defaultScheme; //设置默认的协议方案（scheme），跳转的路由的scheme不符合，会跳转到外部应用
@property (nonatomic, copy) NSString *defaultHost;  //设置默认的主机名称（host），跳转的路由的host不符合，会跳转到外部应用

/**
 获取单例

 @return 实例
 */
+ (instancetype)sharedInstance;

/**
 通过plist批量注册路由

 @param file 文件路径，文件格式参考HLFRoute_Demo.plist
 */
- (void)registerRouteWithFile:(NSString *)file;

/**
 注册路由

 @param route 路由表达式,格式为path/:param1(expression1)/:param2(expression2)
              不传入expression视为对参数不做限制
              可以没有任何param
 @param name 该操作的对应的试图控制器类，可以为nil
 */
- (void)registerRoute:(NSString *)route viewControllerClassName:(NSString *)name;

/**
 跳转路由

 @param url 路由url
 @param primitiveParams 特殊类型参数字典，用于支持一些NSURL不支持的参数类型
 @param callBack 结果回调
 */
- (void)openRouteWithURL:(NSURL *)url primitiveParams:(NSDictionary *)primitiveParams callBack:(void(^)(NSError *error, id responseObject))callBack;


@end
