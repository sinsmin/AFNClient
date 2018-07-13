//
//  AFCTestRequest.m
//  AFNClientTests
//
//  Created by sinsmin on 2018/6/19.
//  Copyright © 2018年 sinsmin. All rights reserved.
//

#import "AFCTestRequest.h"

@implementation AFCTestRequest

- (instancetype)init
{
    if (self = [super init]) {
        _baseURL = [NSURL URLWithString:@"https://www.sojson.com"];
        _path = @"/api/qqmusic/8446666";
        _method = AFCRequestMethodGET;
    }
    return self;
}

@end
