//
//  UIViewController+HLFRoute.h
//  CocoaLumberjack
//
//  Created by 陈舒澳 on 2018/12/4.
//

#import <UIKit/UIKit.h>
#import "HLFRouteRequest.h"

@interface UIViewController (HLFRoute)
@property (nonatomic, strong) HLFRouteRequest *routeRequest;

/**
 根据路由请求进行转场动画

 @param routeRequest 路由请求
 */
- (void)transitionWithRequest:(HLFRouteRequest *)routeRequest;

/**
 以push的方式显示视图控制器
 */
- (void)pushSelf;

/**
 以present的方式显示视图控制器
 */
- (void)presentSelf;

@end
