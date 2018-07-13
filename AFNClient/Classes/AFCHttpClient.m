//
//  AFCHttpClient.m
//  AFNClient
//
//  Created by sinsmin on 2018/6/19.
//  Copyright © 2018年 sinsmin. All rights reserved.
//

#import "AFCHttpClient.h"
#import "AFCRequest.h"
#import "AFCResponse.h"
#import "AFCInterceptor.h"
#import <AFNetworking/AFHTTPSessionManager.h>

NSErrorDomain const AFNClientErrorDomain = @"AFNClientErrorDomain";

@implementation AFCHttpClient
{
    dispatch_queue_t _processQueue;
}

- (instancetype)init
{
    if (self = [super init]) {
        _manager = [AFHTTPSessionManager manager];
        _manager.completionQueue = dispatch_queue_create("cn.sinsmin.afnclient.callback", DISPATCH_QUEUE_CONCURRENT);
        NSMutableSet *contentTypes = [_manager.responseSerializer.acceptableContentTypes mutableCopy];
        [contentTypes addObject:@"text/html"];
        _manager.responseSerializer.acceptableContentTypes = contentTypes;
        _processQueue = dispatch_queue_create("cn.sinsmin.afnclient.process", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (instancetype)defaultClient
{
    static AFCHttpClient *_client;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _client = [[AFCHttpClient alloc] init];
    });
    return _client;
}

- (NSURLSessionTask *)requestWithTarget:(id<AFCRequest>)target response:(id<AFCResponse>)response
{
    NSString *urlString = target.baseURL.absoluteString;
    if ([urlString isEqualToString:@""] || [target.path isEqualToString:@""]) {
        if ([response respondsToSelector:@selector(didFailWithError:)]) {
            NSError *error = [NSError errorWithDomain:AFNClientErrorDomain code:400 userInfo:@{NSLocalizedDescriptionKey: @"The url cannot be empty"}];
            [response didFailWithError:error];
        }
        return nil;
    }
    NSError *error = nil;
    NSURLRequest *request = [self requestWithTarget:target error:&error];
    if (error) {
        if ([response respondsToSelector:@selector(didFailWithError:)]) {
            [response didFailWithError:error];
        }
        return nil;
    }
    if (!request) {
        if ([response respondsToSelector:@selector(didFailWithError:)]) {
            NSError *error = [NSError errorWithDomain:AFNClientErrorDomain code:500 userInfo:@{NSLocalizedDescriptionKey: @"The request cannot be initialized"}];
            [response didFailWithError:error];
        }
        return nil;
    }
    __block NSURLRequest *wrapRequest = request;
    for (id<AFCInterceptor> interceptor in _interceptors) {
        if ([interceptor respondsToSelector:@selector(prepareWithTarget:request:)]) {
            dispatch_sync(_processQueue, ^{
                wrapRequest = [interceptor prepareWithTarget:target request:wrapRequest];
            });
        }
    }
    NSURLSessionTask *dataTask = [self taskWithRequest:wrapRequest target:target response:response];
    for (id<AFCInterceptor> interceptor in _interceptors) {
        if ([interceptor respondsToSelector:@selector(willSendWithTarget:request:)]) {
            [interceptor willSendWithTarget:target request:wrapRequest];
        }
    }
    [dataTask resume];
    return dataTask;
}

- (dispatch_queue_t)callbackQueue
{
    return _manager.completionQueue;
}

#pragma mark - Private
- (NSURLRequest *)requestWithTarget:(id<AFCRequest>)target error:(NSError **)error
{
    NSMutableURLRequest *request = nil;
    NSString *urlString = target.baseURL.absoluteString;
    if ([urlString hasSuffix:@"/"] && [target.path hasPrefix:@"/"]) {
        urlString = [NSString stringWithFormat:@"%@%@", urlString, [target.path substringFromIndex:1]];
    } else if (![urlString hasSuffix:@"/"] && ![target.path hasPrefix:@"/"]) {
        urlString = [NSString stringWithFormat:@"%@/%@", urlString, target.path];
    } else {
        urlString = [NSString stringWithFormat:@"%@%@", urlString, target.path];
    }
    NSString *method = (target.method == AFCRequestMethodGET) ? @"GET" : @"POST";
    AFHTTPRequestSerializer *requestSerializer = _manager.requestSerializer;
    NSDictionary *parameters = nil;
    if ([target conformsToProtocol:@protocol(AFCParameterRequest)]) {
        parameters = ((id<AFCParameterRequest>)target).parameters;
    }
    if ([target conformsToProtocol:@protocol(AFCMultipartFormRequest)]) {
        id<AFCMultipartFormRequest> multipartForm = (id<AFCMultipartFormRequest>)target;
        request = [requestSerializer multipartFormRequestWithMethod:method URLString:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            if (multipartForm.formDatas) {
                for (id<AFCMultipartFormData> file in multipartForm.formDatas) {
                    [formData appendPartWithFileData:file.data name:file.name fileName:file.fileName mimeType:file.mimeType];
                }
            }
        } error:error];
    } else {
        request = [requestSerializer requestWithMethod:method URLString:urlString parameters:parameters error:error];
    }
    if (request) {
        request.timeoutInterval = (target.timeout < 1.0 ? 10.0 : target.timeout);
        NSMutableDictionary *headers = [(target.headers ?: @{}) mutableCopy];
        if ([target conformsToProtocol:@protocol(AFCURLEncodedFormRequest)]) {
            [headers setObject:@"application/x-www-form-urlencoded; charset=utf-8" forKey:@"Content-Type"];
        }
        [headers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [request addValue:obj forHTTPHeaderField:key];
        }];
    }
    return request;
}

- (NSURLSessionTask *)taskWithRequest:(NSURLRequest *)request target:(id<AFCRequest>)target response:(id<AFCResponse>)response
{
    NSURLSessionDataTask *dataTask = nil;
    __weak typeof(self) weakSelf = self;
    AFCRequestProgressBlock uploadProgressBlock = nil;
    AFCRequestProgressBlock downloadProgressBlock = nil;
    if ([target conformsToProtocol:@protocol(AFCProgressRequest)]) {
        uploadProgressBlock = ((id<AFCProgressRequest>)target).uploadProgressBlock;
        downloadProgressBlock = ((id<AFCProgressRequest>)target).downloadProgressBlock;
    }
    if ([target conformsToProtocol:@protocol(AFCMultipartFormRequest)]) {
        dataTask = [_manager uploadTaskWithStreamedRequest:request progress:uploadProgressBlock completionHandler:^(NSURLResponse * _Nonnull resp, id  _Nullable responseObject, NSError * _Nullable error) {
            [weakSelf processCompleteWithURLResponse:resp response:response responseObject:responseObject filePath:nil error:error];
        }];
    } else if ([target conformsToProtocol:@protocol(AFCDownloadResumeRequest)]) {
        id<AFCDownloadResumeRequest> downloadForm = (id<AFCDownloadResumeRequest>)target;
        dataTask = (NSURLSessionDataTask *)[_manager downloadTaskWithResumeData:downloadForm.resumeData progress:downloadProgressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return downloadForm.destination;
        } completionHandler:^(NSURLResponse * _Nonnull resp, NSURL * _Nullable filePath, NSError * _Nullable error) {
            [weakSelf processCompleteWithURLResponse:resp response:response responseObject:nil filePath:filePath error:error];
        }];
    } else if ([target conformsToProtocol:@protocol(AFCDownloadURLRequest)]) {
        id<AFCDownloadURLRequest> downloadForm = (id<AFCDownloadURLRequest>)target;
        dataTask = (NSURLSessionDataTask *)[_manager downloadTaskWithRequest:request progress:downloadProgressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return downloadForm.destination;
        } completionHandler:^(NSURLResponse * _Nonnull resp, NSURL * _Nullable filePath, NSError * _Nullable error) {
            [weakSelf processCompleteWithURLResponse:resp response:response responseObject:nil filePath:filePath error:error];
        }];
    } else {
        dataTask =  [_manager dataTaskWithRequest:request uploadProgress:uploadProgressBlock downloadProgress:downloadProgressBlock completionHandler:^(NSURLResponse * _Nonnull resp, id  _Nullable responseObject, NSError * _Nullable error) {
            [weakSelf processCompleteWithURLResponse:resp response:response responseObject:responseObject filePath:nil error:error];
        }];
    }
    return dataTask;
}

- (void)processCompleteWithURLResponse:(NSURLResponse *)resp response:(id<AFCResponse>)response responseObject:(id)responseObject filePath:(NSURL *)filePath error:(NSError *)error
{
    if (error) {
        if ([response respondsToSelector:@selector(didFailWithError:)]) {
            [response didFailWithError:error];
        }
    } else if ([response conformsToProtocol:@protocol(AFCDownloadResponse)]) {
        id<AFCDownloadResponse> downloadResponse = (id<AFCDownloadResponse>)response;
        if ([downloadResponse respondsToSelector:@selector(didCompleteWithURLResponse:filePath:)]) {
            [downloadResponse didCompleteWithURLResponse:resp filePath:filePath];
        }
    } else if ([response conformsToProtocol:@protocol(AFCURLResponse)]) {
        id<AFCURLResponse> urlResponse = (id<AFCURLResponse>)response;
        __block id wrapResponseObject = responseObject;
        for (id<AFCInterceptor> interceptor in _interceptors) {
            if ([interceptor respondsToSelector:@selector(didReceiveWithURLResponse:responseObject:)]) {
                dispatch_sync(_processQueue, ^{
                    wrapResponseObject = [interceptor didReceiveWithURLResponse:resp responseObject:wrapResponseObject];
                });
            }
        }
        if ([urlResponse respondsToSelector:@selector(didCompleteWithURLResponse:responseObject:)]) {
            [urlResponse didCompleteWithURLResponse:resp responseObject:wrapResponseObject];
        }
    }
}
@end
