//
//  AFCHttpClient.h
//  AFNClient
//
//  Created by golds on 2018/6/19.
//  Copyright © 2018年 sinsmin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const AFNClientErrorDomain;

@class AFHTTPSessionManager;
@protocol AFCInterceptor;
@protocol AFCRequest;
@protocol AFCResponse;

@interface AFCHttpClient : NSObject
@property(nonatomic, strong, readonly) AFHTTPSessionManager *manager;
@property(nonatomic, strong, readonly) dispatch_queue_t callbackQueue;
@property(nonatomic, strong, nullable) NSArray<id<AFCInterceptor>> *interceptors;

+ (instancetype)defaultClient;

- (NSURLSessionTask * _Nullable)requestWithTarget:(id<AFCRequest>)target response:(id<AFCResponse>)response;
@end

NS_ASSUME_NONNULL_END
