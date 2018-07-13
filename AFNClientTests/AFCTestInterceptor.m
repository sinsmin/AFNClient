//
//  AFCTestInterceptor.m
//  AFNClientTests
//
//  Created by sinsmin on 2018/6/19.
//  Copyright © 2018年 sinsmin. All rights reserved.
//

#import "AFCTestInterceptor.h"

@implementation AFCTestInterceptor

- (NSURLRequest *)prepareWithTarget:(id<AFCRequest>)target request:(NSURLRequest *)request
{
    NSLog(@"prepare");
    return request;
}

- (void)willSendWithTarget:(id<AFCRequest>)target request:(NSURLRequest *)request
{
    NSLog(@"willSend");
}

- (id)didReceiveWithURLResponse:(NSURLResponse *)urlResponse responseObject:(id)responseObject
{
    NSLog(@"didReceive");
    return responseObject;
}

@end
