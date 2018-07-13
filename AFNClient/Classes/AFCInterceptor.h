//
//  AFCInterceptor.h
//  AFNClient
//
//  Created by sinsmin on 2018/6/19.
//  Copyright © 2018年 sinsmin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AFCRequest;

@protocol AFCInterceptor <NSObject>

@optional
- (NSURLRequest *)prepareWithTarget:(id<AFCRequest>)target request:(NSURLRequest *)request;

- (void)willSendWithTarget:(id<AFCRequest>)target request:(NSURLRequest *)request;

- (id _Nullable)didReceiveWithURLResponse:(NSURLResponse *)urlResponse responseObject:(id _Nullable)responseObject;
@end

NS_ASSUME_NONNULL_END
