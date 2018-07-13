//
//  AFCTestRequest.h
//  AFNClientTests
//
//  Created by golds on 2018/6/19.
//  Copyright © 2018年 sinsmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFCRequest.h"

@interface AFCTestRequest : NSObject <AFCURLEncodedFormRequest>
@property(nonatomic, copy) NSURL *baseURL;
@property(nonatomic, copy) NSString *path;
@property(nonatomic, assign) AFCRequestMethod method;
@property(nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *headers;
@property(nonatomic, assign) NSTimeInterval timeout;
@property(nonatomic, strong, nullable) NSDictionary<NSString *, id> *parameters;
@end
