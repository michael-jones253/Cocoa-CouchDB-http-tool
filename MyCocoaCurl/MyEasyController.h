//
//  MyEasyController.h
//  CocoaCurl
//
//  Created by Michael Jones on 13/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//

#ifndef CocoaCurl_MyEasyController_h
#define CocoaCurl_MyEasyController_h
#import <Foundation/Foundation.h>
#import "MyEasyCurlTypes.h"
#import "MyEasyCurl.h"

@interface MyEasyController : NSObject {
    MyEasyCurl* _myImpl;
    BOOL _ok;
}

@property MyHttpMethod httpMethod;
@property NSString* postData;
- (id)init;

- (void)Run: (NSString*)url;

- (NSString*)GetResult;

@end


#endif