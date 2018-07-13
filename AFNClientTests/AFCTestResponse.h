//
//  AFCTestResponse.h
//  AFNClientTests
//
//  Created by sinsmin on 2018/6/19.
//  Copyright © 2018年 sinsmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTestExpectation.h>
#import "AFCResponse.h"

@interface AFCTestResponse : NSObject <AFCURLResponse>
@property(nonatomic, strong, readonly) XCTestExpectation *expectation;

+ (instancetype)testResponseWithExpectation:(XCTestExpectation *)expectation;
@end
