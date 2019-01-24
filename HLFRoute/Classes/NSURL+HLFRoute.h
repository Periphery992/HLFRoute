//
//  NSURL+HLFRoute.h
//  CocoaLumberjack
//
//  Created by 陈舒澳 on 2019/1/21.
//

#import <Foundation/Foundation.h>

@interface NSURL (HLFRoute)

+ (NSURL *)URLWithPath:(NSString *)path query:(NSString *)query;

@end
