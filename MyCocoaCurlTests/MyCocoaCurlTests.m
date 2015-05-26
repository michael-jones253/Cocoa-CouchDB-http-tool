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
    
    NSError* runError;
    
    BOOL ok = [libObj InitConnection: &runError];
    XCTAssert(ok == TRUE, @"Connection initialised ok");
    XCTAssert(runError == nil, @"Connection initialised no error");
    
    ok = [libObj Run:@"www.example.com" error:&runError];
    
    XCTAssert(ok == TRUE, @"Run returned ok");
    XCTAssert(runError == nil, @"Run no error");

    content = [libObj GetContent];

    XCTAssert([ content containsString: @"Content"], @"Pass with content");
    
    NSLog(@"Content: %@", content);
    
    NSString* emptyDump = [libObj GetDump];
    
    XCTAssert(emptyDump != nil, @"Got a dump ok");
    
    XCTAssert([emptyDump length] == 0, @"Dump length is 0 OK.");
    
    ok = [libObj InitConnection: &runError];
    
    XCTAssert(ok == YES, @"Second connection ok");
    XCTAssert(runError == nil, @"Second Connection initialised no error");
    
    ok = [libObj SetDebugOn: &runError];
    
    XCTAssert(ok == YES, @"Pass");
    
    ok = [libObj Run:@"www.example.com" error:&runError];

    XCTAssert(ok == YES, @"Ran with debug");
    XCTAssert(runError == nil, @"Run with debug no error");

    
    NSString* dump = [libObj GetDump];
    
    XCTAssert(dump != nil, @"Got a dump ok");
    
    XCTAssert([dump length] > 0, @"Dump length > 0");
    
    NSLog(@"DUMP: %@", dump);
    
    
}

- (void)testErrorHandling {
    NSError* runError = nil;
    MyEasyCurl* libObj = [[MyEasyCurl alloc]init];
    BOOL ok = TRUE;

    // We deliberately do not initialise the connection so that curl option setting will fail.
    ok = [libObj SetDebugOn: &runError];
    XCTAssert(ok == FALSE, @"Set debug option expected failure");
    XCTAssert(runError != nil, @"Set debug option expected exception");
    XCTAssert([runError localizedDescription].length > 0, @"Got an error description");
    NSLog(@"Exception: %@", [runError localizedDescription]);
    
    runError = nil;
    ok = [libObj Run:@"www.example.com" error:&runError];
    XCTAssert(ok == FALSE, @"Run expected failure");
    XCTAssert(runError != nil, @"Run expected exception");
    XCTAssert([runError localizedDescription].length > 0, @"Got an error description");
    NSLog(@"Exception: %@", [runError localizedDescription]);
    
    runError = nil;
    ok = [libObj SetDeleteMethod: &runError];
    XCTAssert(ok == FALSE, @"Delete method expected failure");
    XCTAssert(runError != nil, @"Delete method expected exception");
    XCTAssert([runError localizedDescription].length > 0, @"Got an error description");
    NSLog(@"Exception: %@", [runError localizedDescription]);
    
    runError = nil;
    ok = [libObj SetGetMethod: &runError];
    XCTAssert(ok == FALSE, @"Get method expected failure");
    XCTAssert(runError != nil, @"Get method expected exception");
    XCTAssert([runError localizedDescription].length > 0, @"Got an error description");
    NSLog(@"Exception: %@", [runError localizedDescription]);
    
    runError = nil;
    ok = [libObj SetJpegContent: &runError];
    XCTAssert(ok == FALSE, @"Jpeg content expected failure");
    XCTAssert(runError != nil, @"Jpeg content expected exception");
    XCTAssert([runError localizedDescription].length > 0, @"Got an error description");
    NSLog(@"Exception: %@", [runError localizedDescription]);
    
    runError = nil;
    ok = [libObj SetJsonContent: &runError];
    XCTAssert(ok == FALSE, @"json content expected failure");
    XCTAssert(runError != nil, @"json content expected exception");
    XCTAssert([runError localizedDescription].length > 0, @"Got an error description");
    NSLog(@"Exception: %@", [runError localizedDescription]);
    
    runError = nil;
    ok = [libObj SetPlainTextContent: &runError];
    XCTAssert(ok == FALSE, @"plain text content expected failure");
    XCTAssert(runError != nil, @"plain text content expected exception");
    XCTAssert([runError localizedDescription].length > 0, @"Got an error description");
    NSLog(@"Exception: %@", [runError localizedDescription]);
    
    runError = nil;
    NSString* junk = @"Junk";
    ok = [libObj SetPostData:junk error:&runError];
    XCTAssert(ok == FALSE, @"post data expected failure");
    XCTAssert(runError != nil, @"post data expected exception");
    XCTAssert([runError localizedDescription].length > 0, @"Got an error description");
    NSLog(@"Exception: %@", [runError localizedDescription]);
    
    runError = nil;
    ok = [libObj SetPostMethod: &runError];
    XCTAssert(ok == FALSE, @"post method expected failure");
    XCTAssert(runError != nil, @"post method expected exception");
    XCTAssert([runError localizedDescription].length > 0, @"Got an error description");
    NSLog(@"Exception: %@", [runError localizedDescription]);
    
    runError = nil;
    ok = [libObj SetPutData: junk error: &runError];
    XCTAssert(ok == FALSE, @"post method expected failure");
    XCTAssert(runError != nil, @"post method expected exception");
    XCTAssert([runError localizedDescription].length > 0, @"Got an error description");
    NSLog(@"Exception: %@", [runError localizedDescription]);
}

- (void)testController {
    MyEasyController* controller = [[MyEasyController alloc]init];
    NSError* runError = nil;
    [controller runUrl:@"www.example.com" applicationData:@"" error:&runError];
    
    NSString* result = [controller getResult];
    
    NSLog(@"Result: %@", result);
    
    controller.isDumpOn = TRUE;
    [controller runUrl:@"www.example.com" applicationData:@"" error:&runError];
    
    NSString* dump = [controller getDump];
    NSLog(@"Controller dump: %@", dump);
    XCTAssert(dump.length > 0, @"Got a dump ok");
    
    XCTAssert([result containsString:@"Content"], @"Run Controller ok");
}

- (void)testLoadImage {
    MyEasyController* controller = [[MyEasyController alloc]init];
    NSError* myError = nil;
    NSUInteger imageLength = 0;
    BOOL ok = [controller loadImageFromFile:@"" imageSize:&imageLength error:&myError];
    XCTAssert(!ok, @"Expected load image failure");
    XCTAssert(myError != nil, @"Expected exception");
    XCTAssert(imageLength == 0, @"Image length not modified ok");
    
    // Set error to nil for next test.
    myError = nil;

    ok = [controller loadImageFromFile:@"/Users/michaeljones/Pictures/Exported Photos/IMG_1564.jpg"
                             imageSize:&imageLength
                                 error:&myError];
    XCTAssert(ok, @"Expected load image success");
    XCTAssert(imageLength > 0, @"Image length set ok");
    XCTAssert(myError == nil, @"Expected no exception");
    
    NSString* homeDir = NSHomeDirectory();
    NSLog(@"Home direcotry: %@", homeDir);
    
    NSString* shortPath = @"~/Pictures/Exported Photos/IMG_1564.jpg";
    imageLength = 0;
    ok = [controller loadImageFromFile:shortPath imageSize:&imageLength error:&myError];
    XCTAssert(ok, @"Expected load image success");
    XCTAssert(myError == nil, @"Expected no exception");
    XCTAssert(imageLength > 0, @"Image length set ok");
}

- (void)testReplicate {
    MyEasyController* controller = [[MyEasyController alloc]init];
    NSError* myError = nil;
    
    NSArray* dbNames = [controller getDbNamesForHost:@"127.0.0.1" error:&myError];
    
    XCTAssert(dbNames != nil, @"Localhost CouchDB running");
    XCTAssert([dbNames count] >= 2, @"Localhost is running and contains at least the default databases");
    
    BOOL isReplicatorThere = FALSE;
    BOOL isUsersThere = FALSE;
    for (NSInteger index = 0; index < [dbNames count]; ++index) {
        NSString* dbName = [dbNames objectAtIndex:index];
        NSLog(@"Database: %@", dbName);
        if ([dbName isEqualToString:@"_replicator"]) {
            isReplicatorThere = TRUE;
        }
        
        if ([dbName isEqualToString:@"_users"]) {
            isUsersThere = TRUE;
        }
    }
    
    XCTAssert(isReplicatorThere, @"Replicator found");
    XCTAssert(isUsersThere, @"Users database found");

    dbNames = [controller getDbNamesForHost:@"www.example.com" error:&myError];
    XCTAssert(myError != nil, @"Expected error from getting databases at example.com");
    
    isReplicatorThere = FALSE;
    isUsersThere = FALSE;
    for (NSInteger index = 0; index < [dbNames count]; ++index) {
        NSString* dbName = [dbNames objectAtIndex:index];
        NSLog(@"Database: %@", dbName);
        if ([dbName isEqualToString:@"_replicator"]) {
            isReplicatorThere = TRUE;
        }
        
        if ([dbName isEqualToString:@"_users"]) {
            isUsersThere = TRUE;
        }
    }
    
    XCTAssert(!isReplicatorThere, @"Replicator found");
    XCTAssert(!isUsersThere, @"Users database found");

    BOOL ok = [controller pushReplicateUrl:@"http://localhost:5984/hello" destinationUrl:@"http://example.com:5984/hello-rep" error:&myError];
    XCTAssert(!ok, @"Expected replicate failure");
    XCTAssert(myError != nil, @"Expected replicate error");
    
    myError = nil;
    ok = [controller pushReplicateUrl:@"http://localhost:5984/hello" destinationUrl:@"http://127.0.0.1:5984/hello-rep" error:&myError];
    XCTAssert(ok, @"Expected replicate ok");
    XCTAssert(myError == nil, @"Expected no replicate error");
    
    myError = nil;
    ok = [controller pullReplicateUrl:@"http://localhost:5984/hello-rep-pulled" destinationUrl:@"http://127.0.0.1:5984/hello-rep" error:&myError];
    XCTAssert(ok, @"Expected replicate ok");
    XCTAssert(myError == nil, @"Expected no replicate error");

}

- (void)testReplicateValidaton {
    MyEasyController* controller = [[MyEasyController alloc]init];
    NSError* myError = nil;

    BOOL ok = [controller pushReplicateUrl:@"http://127.0.0.1:5984/hello-rep"
                  destinationUrl:@"http://localhost:5984/hello"
                           error:&myError];
    ok = [controller pullReplicateUrl:@"http://127.0.0.1:5984/hello-rep"
                            destinationUrl:@"http://localhost:5984/hello"
                                     error:&myError];
    
    XCTAssert(!ok, @"expected failure due to pre-existing target for replicate");
    NSLog(@"Pre-existing target error: %@", [myError localizedDescription]);
    
    ok = [controller pushReplicateUrl:@"http://127.0.0.1:5984/_hello-rep"
                            destinationUrl:@"http://localhost:5984/hello"
                                     error:&myError];
    XCTAssert(!ok, @"expected failure due to source having system prefix.");
    NSLog(@"System prefix source error: %@", [myError localizedDescription]);
    
    ok = [controller pushReplicateUrl:@"http://127.0.0.1:5984/hello-rep"
                       destinationUrl:@"http://localhost:5984/_hello"
                                error:&myError];
    XCTAssert(!ok, @"expected failure due to target having system prefix.");
    NSLog(@"System prefix target error: %@", [myError localizedDescription]);
    
    ok = [controller pushSyncUrl:@"http://127.0.0.1:5984/hello-rep"
                       destinationUrl:@"http://localhost:5984/_hello"
                                error:&myError];
    XCTAssert(!ok, @"expected failure due to target having system prefix.");
    NSLog(@"System prefix target error: %@", [myError localizedDescription]);
    
    ok = [controller pullReplicateUrl:@"http://127.0.0.1:5984/hello-rep"
                       destinationUrl:@"http://localhost:5984/_hello"
                                error:&myError];
    XCTAssert(!ok, @"expected failure due to target having system prefix.");
    NSLog(@"System prefix target error: %@", [myError localizedDescription]);
    
    ok = [controller pullSyncUrl:@"http://127.0.0.1:5984/hello-rep"
                  destinationUrl:@"http://localhost:5984/_hello"
                           error:&myError];
    XCTAssert(!ok, @"expected failure due to target having system prefix.");
    NSLog(@"System prefix target error: %@", [myError localizedDescription]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
