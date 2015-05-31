//
//  MyEasyCurl.h
//  CocoaCurl
//
//  Created by Michael Jones on 12/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//

#ifndef CocoaCurl_MyEasyCurl_h
#define CocoaCurl_MyEasyCurl_h
#import <Foundation/Foundation.h>
#import "MyEasyCurlTypes.h"

@interface MyEasyCurl : NSObject {
    
    // C++
    void* myImpl;
}

@property NSString *MyGreeting;

- (void)greeting;

- (void)helloCurl;

- (BOOL)initConnection:(NSError**)curlError;

- (BOOL)setGetMethod:(NSError**)curlError;

- (BOOL)setPostMethod:(NSError**)curlError;

- (BOOL)setPutMethod:(NSError**)curlError;

- (BOOL)setDeleteMethod:(NSError**)curlError;

- (BOOL)setPostData:(NSString*)data error:(NSError**)curlError;

- (BOOL)setPutData:(NSString*)data error:(NSError**)curlError;

- (BOOL)setImageDataNoCache:(NSData*) data error:(NSError**)curlError;

- (BOOL)setJsonContent:(NSError**)curlError;

- (BOOL)setPlainTextContent:(NSError**)curlError;

- (BOOL)setJpegContent:(NSError**)curlError;

- (BOOL)setDebugOn:(NSError**)curlError;

- (BOOL)runUrl:(NSString*)url error:(NSError**)curlError;

- (NSString*)getContent;

- (NSString*)getDump;

- (NSString*)getError;

- (id)init;

- (void)dealloc;


@end


#endif
