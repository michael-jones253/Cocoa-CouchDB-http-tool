//
//  MyCocoaCurlTests.m
//  MyCocoaCurlTests
//
//  Created by Michael Jones on 12/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "MyCocoaCurl.h"

@interface MyCocoaCurlTests : XCTestCase

@end

@implementation MyCocoaCurlTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    MyEasyCurl* libObj = [[MyEasyCurl alloc]init];
    [libObj Greeting];
    
    NSLog(@"Greeting from property: %@", libObj.MyGreeting);

    XCTAssert(YES, @"Pass");
}

- (void)testRun {
    // This is an example of a functional test case.
    MyEasyCurl* libObj = [[MyEasyCurl alloc]init];
    
    NSString* content = [libObj GetContent];
    
    XCTAssert([ content isEqualToString: @""], @"Pass with content empty");
    
    BOOL ok = [libObj InitConnection];
    XCTAssert(ok == TRUE, @"Connection initialised ok");
    
    ok = [libObj Run:@"www.example.com"];
    
    XCTAssert(ok == TRUE, @"Run returned ok");

    content = [libObj GetContent];

    XCTAssert([ content containsString: @"Content"], @"Pass with content");
    
    NSLog(@"Content: %@", content);
    
    XCTAssert(YES, @"Pass");
}

- (void)testController {
    MyEasyController* controller = [[MyEasyController alloc]init];
    
    [controller RunUrl:@"www.example.com" applicationData:@""];
    
    NSString* result = [controller GetResult];
    
    NSLog(@"Result: %@", result);
    
    XCTAssert([result containsString:@"Content"], @"Run Controller ok");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
