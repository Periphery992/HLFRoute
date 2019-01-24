//
//  HLFRouteRequest.m
//  CocoaLumberjack
//
//  Created by 陈舒澳 on 2018/12/3.
//

#import "HLFRouteRequest.h"
#import "NSError+HLFRoute.h"

@interface HLFRouteRequest(){}

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, copy) NSString *routeExpression;
@property (nonatomic, strong) NSMutableDictionary *queryParameters;
@property (nonatomic, strong) NSMutableDictionary *routeParameters;
@property (nonatomic, strong) NSDictionary *primitiveParams;
@property (nonatomic, strong) NSMutableDictionary *parameters;
@property (nonatomic, copy) NSString *callbackUrl;
@property (nonatomic, copy) NSString *callbackHost;
@property (nonatomic, copy) NSString *callbackScheme;

@end

@implementation HLFRouteRequest

- (instancetype)initWithURL:(NSURL *)url routeExpression:(NSString *)routeExpression primitiveParams:(NSDictionary *)primitiveParams callBack:(void(^)(NSError *error, id responseObject))callBack
{
    if (self = [super init])
    {
        self.url = url;
        
        __weak typeof(self) wSelf = self;
        self.callBack = ^(NSError *error, id responseObject) {

            NSURL *callbakcUrl = [wSelf getCallBackUrlWithResponObject:responseObject error:error];
            //如果有回调url
            if (callbakcUrl)
            {
                [[UIApplication sharedApplication]openURL:callbakcUrl];
            }
            else
            {
                if (callBack)
                {
                    callBack(error,responseObject);
                }
            }
        };
        self.queryParameters = [self getQueryParametersFromQueryString:self.url.query];
        self.routeParameters = [self getRouteParametersFromRouteExpression:routeExpression];
        self.primitiveParams = primitiveParams;
    }
    return self;
}

#pragma mark - Public Method
/**
 检测各个参数是否符合要求

 @return YES 符合要求  NO 不符合要求
 */
- (BOOL)checkQueryParameters
{
    for (NSString *key in self.routeParameters)
    {
        if ([self.parameters.allKeys containsObject:key])
        {
            id object = self.parameters[key];
            
            NSString *expString = [self.routeParameters objectForKey:key];
            
            //没有匹配要求的参数，直接跳过检测
            if (expString.length == 0)
            {
                continue;
            }
            
            //仅检测NSString是否符合要求
            if ([object isKindOfClass:[NSString class]])
            {
                NSString *queryString = [self.parameters objectForKey:key];
                
                NSRegularExpression *exp = [[NSRegularExpression alloc]initWithPattern:expString options:NSRegularExpressionCaseInsensitive error:nil];
                
                NSArray *resutlArray = [exp matchesInString:queryString options:0 range:NSMakeRange(0, queryString.length)];
                
                if (resutlArray.count == 0)
                {
                    if (self.callBack)
                    {
                        self.callBack([NSError errorWithErrorScene:HLFRouteErrorSceneParameterNoMatch errorKeyDescription:key], nil);
                    }
                    return NO;
                }
                
                NSTextCheckingResult *result = [resutlArray firstObject];
                
                if (result.range.length != queryString.length)
                {
                    if (self.callBack)
                    {
                        self.callBack([NSError errorWithErrorScene:HLFRouteErrorSceneParameterNoMatch errorKeyDescription:key], nil);
                    }
                    return NO;
                }
            }
        }
        else
        {
            if (self.callBack)
            {
                self.callBack([NSError errorWithErrorScene:HLFRouteErrorSceneParameterNoMatch errorKeyDescription:key], nil);
            }
            return NO;
        }
    }
    return YES;
}

#pragma mark - Privacy Method
/**
 解析路由表达式，获取参数和参数的正则表达式
 
 将路由表达式path/:key1(exp1)/:key2(exp2)解析成字典@{@"key1":@"exp1",@"key2":@"exp2"}
 
 @param routeExpression 路由正则表达式
 @return 参数和参数的正则表达式的字典
 */
- (NSMutableDictionary *)getRouteParametersFromRouteExpression:(NSString *)routeExpression
{
    //解析路由表达式
    NSMutableDictionary *routeParameters = [NSMutableDictionary dictionary];
    NSRegularExpression *pairExp = [[NSRegularExpression alloc]initWithPattern:@":[a-zA-Z0-9-_][^/]+" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *pairResutlArray = [pairExp matchesInString:routeExpression options:0 range:NSMakeRange(0, routeExpression.length)];
    //不存在参数要求
    if (pairResutlArray.count == 0)
    {
        return nil;
    }
    
    for (NSTextCheckingResult *pairResult in pairResutlArray)
    {
        NSString *pairResultString = [routeExpression substringWithRange:pairResult.range];
        
        NSRegularExpression *KeyExp = [[NSRegularExpression alloc]initWithPattern:@"[a-zA-Z0-9-_]+" options:NSRegularExpressionCaseInsensitive error:nil];
        
        NSArray *keyResultArray = [KeyExp matchesInString:pairResultString options:0 range:NSMakeRange(0, pairResultString.length)];
        
        if (keyResultArray.count == 0)
        {
            NSLog(@"!! warn routeParameters <%@> can not parse",pairResultString);
            
            [routeParameters setObject:@"" forKey:pairResultString];
            continue;
        }
        
        NSTextCheckingResult *keyResult = [keyResultArray firstObject];
        
        NSString *key = [pairResultString substringWithRange:keyResult.range];
        NSString *value = [pairResultString substringWithRange:NSMakeRange(keyResult.range.length + keyResult.range.location, pairResultString.length - keyResult.range.length - keyResult.range.location)];
        
        [routeParameters setObject:value forKey:key];
    }
    
    return routeParameters;
}


/**
 解析url的query字段，获取参数以及值
 
 将url中?之后的query字段key1=value1&key2=value2解析成字典@{@"key1":@"value1",@"key2":@"value2"}
 
 @param query url的query字段，查询的内容
 @return 返回参数的字典
 */
- (NSMutableDictionary *)getQueryParametersFromQueryString:(NSString *)query
{
    NSMutableDictionary *queryParameters = [NSMutableDictionary dictionary];
    
    NSArray *params = [query componentsSeparatedByString:@"&"];
    
    for (NSString *param in params)
    {
        NSArray *pairs = [param componentsSeparatedByString:@"="];
        
        if (pairs.count == 2)
        {
            if (@available(iOS 7.0, *))
            {
                [queryParameters setObject:[pairs.lastObject stringByRemovingPercentEncoding] forKey:[pairs.firstObject stringByRemovingPercentEncoding]];
            }
        }
        else if (pairs.count == 1)
        {
            if (@available(iOS 7.0, *))
            {
                [queryParameters setObject:@"" forKey:[pairs.firstObject stringByRemovingPercentEncoding]];
            }
        }
    }
    
    if ([queryParameters.allKeys containsObject:@"callbackURL"])
    {
        self.callbackUrl = [queryParameters objectForKey:@"callbackURL"];
        [queryParameters removeObjectForKey:@"callbackURL"];
    }
    
    return queryParameters;
}


/**
 获取回调的url
 
 @param responseObject 回调的参数
 @return 回调的url
 */
- (NSURL *)getCallBackUrlWithResponObject:(id)responseObject error:(NSError *)error
{
    NSURLComponents *components;

    if (self.callbackUrl&&self.callbackUrl.length>0)
    {
        components = [[NSURLComponents alloc]initWithString:[self.callbackUrl stringByRemovingPercentEncoding]];
    }
    
    if (error&&error.localizedDescription.length > 0)
    {
        if (@available(iOS 8.0, *))
        {
            NSURLQueryItem *item = [[NSURLQueryItem alloc]initWithName:@"error" value:error.localizedDescription];
            components.queryItems = @[item];
        }
    }
    else
    {
        NSMutableArray *mutarrQueryItem = [[NSMutableArray alloc]init];
        
        [responseObject enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            NSString *value = @"";
            if ([obj isKindOfClass:[NSString class]])
            {
                value = [NSString stringWithFormat:@"%@",obj];
            }
            else if ([obj isKindOfClass:[NSNumber class]])
            {
                value = [NSString stringWithFormat:@"%@",[(NSNumber *)obj stringValue]];
            }
            
            if (@available(iOS 8.0, *))
            {
                NSURLQueryItem *item = [[NSURLQueryItem alloc]initWithName:[key stringByRemovingPercentEncoding] value:value];
                [mutarrQueryItem addObject:item];
            }
        }];
        
        NSArray *queryItems = [NSArray arrayWithArray:mutarrQueryItem];
        
        if (@available(iOS 8.0, *))
        {
            components.queryItems = queryItems;
        }
    }
    
    
    if (components.URL)
    {
        return components.URL;
    }
    
    return nil;
}


- (NSString *)description
{
    return [NSString stringWithFormat:
            @"\n<%@ %p\n\n"
            @"URL: \"%@\"\n\n"
            @"queryParameters: \"%@\"\n\n"
            @"routeParameters: \"%@\"\n\n"
            @"PrimitiveParam: \"%@\"\n\n"
            @">",
            NSStringFromClass([self class]),
            self,
            [self.url description],
            self.queryParameters,
            self.routeParameters,
            self.primitiveParams];
}

#pragma mark - GET/SET
- (NSMutableDictionary *)parameters
{
    if (!_parameters)
    {
        _parameters = ({
            
            NSMutableDictionary *parameters= [[NSMutableDictionary alloc]init];
            
            for (NSString *key in self.routeParameters)
            {
                if ([self.queryParameters.allKeys containsObject:key])
                {
                    [parameters setObject:self.queryParameters[key] forKey:key];
                }
                else if ([self.primitiveParams.allKeys containsObject:key])
                {
                    [parameters setObject:self.primitiveParams[key] forKey:key];
                }
                else
                {
                    NSLog(@"!! HLFRoute warn : does not contain value for key %@",key);
                    
                }
            }
            
            parameters;
        });
    }
    return _parameters;
}

@end
