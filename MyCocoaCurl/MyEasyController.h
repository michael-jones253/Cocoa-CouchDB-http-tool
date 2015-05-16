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
    MyEasyCurl* _myEasyModel;
    BOOL _ok;
}

@property MyHttpMethod httpMethod;
@property NSString* postData;
@property BOOL isPlainTextAttachment;

- (id)init;

- (void)RunUrl: (NSString*)url applicationData: (NSString*)data;

- (NSString*)GetResult;

@end


#endif
