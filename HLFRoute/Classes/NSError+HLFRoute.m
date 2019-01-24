//
//  NSError+HLFRoute.m
//  CocoaLumberjack
//
//  Created by 陈舒澳 on 2018/12/12.
//

#import "NSError+HLFRoute.h"

NSString * const NSHLFRouteErrorDomain = @"NSHLFRouteErrorDomain";

@implementation NSError (HLFRoute)

+ (NSError *)errorWithErrorScene:(HLFRouteErrorScene)scene errorKeyDescription:(NSString *)keyDescription
{
    NSError *error;
    
    switch (scene) {
        case HLFRouteErrorSceneRouteExpNoPath:
        {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"HLFRoute Error : routeExpression <%@> can not parse (No path)",keyDescription]};
            error = [[NSError alloc]initWithDomain:NSHLFRouteErrorDomain code:scene userInfo:userInfo];
        }
            break;
        case HLFRouteErrorSceneRouteExpNoRegister:
        {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"HLFRoute Error : routeExpression does no register"]};
            error = [[NSError alloc]initWithDomain:NSHLFRouteErrorDomain code:scene userInfo:userInfo];
        }
        case HLFRouteErrorSceneParameterNoMatch:
        {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"HLFRoute Error : param <%@> is not match",keyDescription]};
            error = [[NSError alloc]initWithDomain:NSHLFRouteErrorDomain code:scene userInfo:userInfo];
        }
        case HLFRouteErrorSceneParameterNoValue:
        {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"HLFRoute Error : does not contain value for key %@",keyDescription]};
            error = [[NSError alloc]initWithDomain:NSHLFRouteErrorDomain code:scene userInfo:userInfo];
        }
            
        default:
            break;
    }
    
    
//    NSLog(@"ERROR: [HLFRoute] %@",error.localizedDescription);
    
    return error;
}

@end
