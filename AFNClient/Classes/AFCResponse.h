//
//  AFCResponse.h
//  AFNClient
//
//  Created by golds on 2018/6/19.
//  Copyright © 2018年 sinsmin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AFCResponse <NSObject>

- (void)didFailWithError:(NSError * _Nullable)error;
@end

@protocol AFCURLResponse <AFCResponse>

- (void)didCompleteWithURLResponse:(NSURLResponse *)urlResponse responseObject:(id _Nullable)responseObject;
@end

@protocol AFCDownloadResponse <AFCResponse>

- (void)didCompleteWithURLResponse:(NSURLResponse *)urlResponse filePath:(NSURL * _Nullable)filePath;
@end

NS_ASSUME_NONNULL_END
