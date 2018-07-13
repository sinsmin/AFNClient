//
//  AFCRequest.h
//  AFNClient
//
//  Created by golds on 2018/6/19.
//  Copyright © 2018年 sinsmin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AFCRequestMethod) {
    AFCRequestMethodGET,
    AFCRequestMethodPOST
};

NS_ASSUME_NONNULL_BEGIN

typedef void(^AFCRequestProgressBlock)(NSProgress *progress);

@protocol AFCRequest <NSObject>
@property(nonatomic, copy) NSURL *baseURL;
@property(nonatomic, copy) NSString *path;
@property(nonatomic, assign) AFCRequestMethod method;
@property(nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *headers;
@property(nonatomic, assign) NSTimeInterval timeout;
@end

@protocol AFCParameterRequest <NSObject>
@property(nonatomic, strong, nullable) NSDictionary<NSString *, id> *parameters;
@end

@protocol AFCProgressRequest <NSObject>
@property(nonatomic, strong, nullable) AFCRequestProgressBlock uploadProgressBlock;
@property(nonatomic, strong, nullable) AFCRequestProgressBlock downloadProgressBlock;
@end

@protocol AFCURLEncodedFormRequest <AFCRequest>
@end

@protocol AFCMultipartFormData <NSObject>
@property(nonatomic, strong) NSData *data;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *fileName;
@property(nonatomic, copy) NSString *mimeType;
@end

@protocol AFCMultipartFormRequest <AFCRequest>
@property(nonatomic, strong) NSArray<id<AFCMultipartFormData>> *formDatas;
@end

@protocol AFCDownloadURLRequest <AFCRequest>
@property(nonatomic, copy) NSURL *destination;
@end

@protocol AFCDownloadResumeRequest <AFCDownloadURLRequest>
@property(nonatomic, strong) NSData *resumeData;
@end

NS_ASSUME_NONNULL_END
