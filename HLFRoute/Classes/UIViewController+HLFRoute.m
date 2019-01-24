//
//  UIViewController+HLFRoute.m
//  CocoaLumberjack
//
//  Created by 陈舒澳 on 2018/12/4.
//

#import "UIViewController+HLFRoute.h"
#import <objc/runtime.h>

@implementation UIViewController (HLFRoute)

#pragma mark - GET/SET
- (HLFRouteRequest *)routeRequest
{
    return objc_getAssociatedObject(self, "HLFRouteRequest");
}

- (void)setRouteRequest:(HLFRouteRequest *)routeRequest
{
    objc_setAssociatedObject(self, "HLFRouteRequest", routeRequest, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self transitionWithRequest:routeRequest];
}

- (void)transitionWithRequest:(HLFRouteRequest *)routeRequest
{
    [self pushSelf];
}

- (void)pushSelf
{
    UIViewController *vc = [UIApplication sharedApplication].windows[0].rootViewController;
    
    if ([vc isKindOfClass:[UINavigationController class]])
    {
        [(UINavigationController *)vc pushViewController:self animated:YES];
    }
}

- (void)presentSelf
{
    UIViewController *vc = [UIApplication sharedApplication].windows[0].rootViewController;
    
    if ([vc isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:self];
        [[(UINavigationController *)vc topViewController] presentViewController:nav animated:YES completion:nil];
    }
}

@end
