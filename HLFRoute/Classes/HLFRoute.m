//
//  HLFRoute.m
//  CocoaLumberjack
//
//  Created by 陈舒澳 on 2018/11/28.
//

#import "HLFRoute.h"
#import "HLFRouteRequest.h"
#import "UIViewController+HLFRoute.h"
#import "NSError+HLFRoute.h"

static NSString * const HLFRoutePathPattern=@"[a-zA-Z0-9-_][^/]+";

@interface HLFRoute(){}
@property (nonatomic, strong) NSMutableDictionary *routeDict;    //路由表达式字典
@property (nonatomic, strong) NSMutableDictionary *vcDict;       //控制器字典

@end

@implementation HLFRoute

+ (void)load
{
    [super load];
    [self sharedInstance];
}

+ (instancetype)sharedInstance
{
    static id _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.routeDict = [[NSMutableDictionary alloc]init];
        self.vcDict = [[NSMutableDictionary alloc]init];
    }
    return self;
}

#pragma mark - Public Method
//注册路由
- (void)registerRoute:(NSString *)route viewControllerClassName:(NSString *)name
{
    //获取路径，并作为关键字存储路由表达式和视图控制器
    NSString *path = [self getPathInRoute:route];
    
    [self.routeDict setObject:route forKey:path];
    [self.vcDict setObject:name forKey:path];
}

//跳转路由
- (void)openRouteWithURL:(NSURL *)url primitiveParams:(NSDictionary *)primitiveParams callBack:(void(^)(NSError *error, id responseObject))callBack
{
    if (![url.scheme isEqualToString:self.defaultScheme]||![url.host isEqualToString:self.defaultHost])
    {//非应用内部默认scheme和host，尝试跳转外部应用
        [[UIApplication sharedApplication]openURL:url];
    }
    
    //获取path，并去除"/"
    NSString *path = [url.path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    
    //根据path获取视图控制器类和路由表达式
    NSString *vcClassName = [self.vcDict objectForKey:path];
    NSString *vcRoute = [self.routeDict objectForKey:path];
    
    if (vcClassName&&vcClassName.length>0)
    {
        //创建路由请求
        HLFRouteRequest *request = [[HLFRouteRequest alloc]initWithURL:url routeExpression:vcRoute primitiveParams:primitiveParams callBack:callBack];
        
        //检测参数是否符合路由表达式的要求
        if ([request checkQueryParameters])
        {
            UIViewController *vc = nil;
            vc = [[NSClassFromString(vcClassName) alloc]init];
            vc.routeRequest = request;
        }
    }
    else
    {
        if (callBack)
        {
            callBack([NSError errorWithErrorScene:HLFRouteErrorSceneRouteExpNoRegister errorKeyDescription:nil],nil);
        }
    }
}

- (void)registerRouteWithFile:(NSString *)file
{
    NSArray *routeArray = [NSArray arrayWithContentsOfFile:file];
    
    for (NSDictionary *dict in routeArray)
    {
        [self registerRoute:[dict objectForKey:@"router"] viewControllerClassName:[dict objectForKey:@"vcClass"]];
    }
}

#pragma mark - Privacy Method
//获取路由中表达的path部分 path/:param1(expression1)/:param2(expression2)
- (NSString *)getPathInRoute:(NSString *)route
{
    NSRegularExpression *regularExp = [[NSRegularExpression alloc]initWithPattern:HLFRoutePathPattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *resultArray = [regularExp matchesInString:route options:NSMatchingReportProgress range:NSMakeRange(0, route.length)];
    
    if (resultArray.count > 0)
    {//path存在
        NSTextCheckingResult *result = resultArray.firstObject;
        return [route substringWithRange:result.range];
    }
    
    return nil;
}

@end
