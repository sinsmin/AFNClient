//
//  AFCTestResponse.m
//  AFNClientTests
//
//  Created by sinsmin on 2018/6/19.
//  Copyright © 2018年 sinsmin. All rights reserved.
//

#import "AFCTestResponse.h"

@implementation AFCTestResponse

+ (instancetype)testResponseWithExpectation:(XCTestExpectation *)expectation
{
    AFCTestResponse *response = [[AFCTestResponse alloc] init];
    response->_expectation = expectation;
    return response;
}

- (void)didFailWithError:(NSError *)error
{
    NSLog(@"%@", [NSThread currentThread]);
    NSLog(@"%@", error);
    [_expectation fulfill];
}

- (void)didCompleteWithURLResponse:(NSURLResponse *)urlResponse responseObject:(id)responseObject
{
    NSLog(@"%@", [NSThread currentThread]);
    NSLog(@"%@", responseObject);
    [_expectation fulfill];
}

@end
