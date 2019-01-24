//
//  NSURL+HLFRoute.m
//  CocoaLumberjack
//
//  Created by 陈舒澳 on 2019/1/21.
//

#import "NSURL+HLFRoute.h"
#import "HLFRoute.h"

@implementation NSURL (HLFRoute)

+ (NSURL *)URLWithPath:(NSString *)path query:(NSString *)query
{
    NSURLComponents *components = [[NSURLComponents alloc]init];
    components.scheme = [HLFRoute sharedInstance].defaultScheme;
    components.host = [HLFRoute sharedInstance].defaultHost;
    components.path = path;
    
    if (components.host.length > 0 && ![components.path hasPrefix:@"/"])
    {//components规则，存在host，post，user，password任一一个时，path必须"/"开头
        components.path = [NSString stringWithFormat:@"/%@",path];
    }
    else if ([components.path hasPrefix:@"//"]&&components.host.length <=0)
    {//components规则，不存在host，post，user，password时，path不能以"//"开头
        do {
            components.path = [components.path stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        } while ([components.path hasPrefix:@"//"]);
    }

    components.query = query;
    
    return components.URL;
}

@end
