//
//  AFNClientTests.m
//  AFNClientTests
//
//  Created by sinsmin on 2018/6/19.
//  Copyright © 2018年 sinsmin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AFCHttpClient.h"
#import "AFCTestRequest.h"
#import "AFCTestResponse.h"
#import "AFCTestInterceptor.h"

@interface AFNClientTests : XCTestCase

@end

@implementation AFNClientTests

- (void)setUp {
    [super setUp];
    [[AFCHttpClient defaultClient] setInterceptors:@[[[AFCTestInterceptor alloc] init]]];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    XCTestExpectation *expectation = [self expectationWithDescription:@"AFNClient Testing"];
    NSURLSessionTask *task = [[AFCHttpClient defaultClient] requestWithTarget:[[AFCTestRequest alloc] init] response:[AFCTestResponse testResponseWithExpectation:expectation]];
    XCTAssertNotNil(task);
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"%@", [error localizedDescription]);
        }
    }];
}


@end
