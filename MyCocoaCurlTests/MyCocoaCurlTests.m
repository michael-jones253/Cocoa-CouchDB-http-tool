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
    
    NSString* emptyDump = [libObj GetDump];
    
    XCTAssert(emptyDump != nil, @"Got a dump ok");
    
    XCTAssert([emptyDump length] == 0, @"Dump length is 0 OK.");
    
    ok = [libObj InitConnection];
    
    XCTAssert(ok == YES, @"Second connection ok");
    
    ok = [libObj SetDebugOn];
    
    XCTAssert(ok == YES, @"Pass");
    
    ok = [libObj Run:@"www.example.com"];

    XCTAssert(ok == YES, @"Ran with debug");
    
    NSString* dump = [libObj GetDump];
    
    XCTAssert(dump != nil, @"Got a dump ok");
    
    XCTAssert([dump length] > 0, @"Dump length > 0");
    
    NSLog(@"DUMP: %@", dump);
    
    
}

- (void)testController {
    MyEasyController* controller = [[MyEasyController alloc]init];
    NSError* runError = nil;
    [controller RunUrl:@"www.example.com" applicationData:@"" error:&runError];
    
    NSString* result = [controller GetResult];
    
    NSLog(@"Result: %@", result);
    
    controller.isDumpOn = TRUE;
    [controller RunUrl:@"www.example.com" applicationData:@"" error:&runError];
    
    NSString* dump = [controller GetDump];
    NSLog(@"Controller dump: %@", dump);
    XCTAssert(dump.length > 0, @"Got a dump ok");
    
    XCTAssert([result containsString:@"Content"], @"Run Controller ok");
}

- (void)testLoadImage {
    MyEasyController* controller = [[MyEasyController alloc]init];
    NSError* myError = nil;
    NSUInteger imageLength = 0;
    BOOL ok = [controller LoadImageFromFile:@"" imageSize:&imageLength error:&myError];
    XCTAssert(!ok, @"Expected load image failure");
    XCTAssert(myError != nil, @"Expected exception");
    XCTAssert(imageLength == 0, @"Image length not modified ok");
    
    // Set error to nil for next test.
    myError = nil;

    ok = [controller LoadImageFromFile:@"/Users/michaeljones/Pictures/Exported Photos/IMG_1564.jpg"
                             imageSize:&imageLength
                                 error:&myError];
    XCTAssert(ok, @"Expected load image success");
    XCTAssert(imageLength > 0, @"Image length set ok");
    XCTAssert(myError == nil, @"Expected no exception");
    
    NSString* homeDir = NSHomeDirectory();
    NSLog(@"Home direcotry: %@", homeDir);
    
    NSString* shortPath = @"~/Pictures/Exported Photos/IMG_1564.jpg";
    imageLength = 0;
    ok = [controller LoadImageFromFile:shortPath imageSize:&imageLength error:&myError];
    XCTAssert(ok, @"Expected load image success");
    XCTAssert(myError == nil, @"Expected no exception");
    XCTAssert(imageLength > 0, @"Image length set ok");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
