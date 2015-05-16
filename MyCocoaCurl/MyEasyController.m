//
//  MyEasyController.m
//  
//
//  Created by Michael Jones on 13/05/2015.
//
//

#import "MyEasyController.h"

@implementation MyEasyController

- (id)init {
    self = [super init];
    if (self) {
        self.httpMethod = MyHttpMethodGet;
        self.postData = @"{\"company\": \"Example, Inc.\"}";
        self.isPlainTextAttachment = FALSE;
        self->_ok = FALSE;
        self->_myEasyModel = [[MyEasyCurl alloc]init];
    }    
    
    return self;
}

- (void)RunUrl: (NSString*)url applicationData: (NSString*)data {
    self->_ok = [self->_myEasyModel InitConnection];
    
    if (!self->_ok) {
        // FIX ME return NSError
        return;
    }
    
    if (self.isPlainTextAttachment && self.httpMethod != MyHttpMethodPut) {
        // FIX ME return NSError
        return;
    }

    if (self.isPlainTextAttachment && ![url containsString:@"?rev="]) {
        // FIX ME return NSError
        return;
    }

    if (self.isPlainTextAttachment && ![url containsString:@"attachment"]) {
        // FIX ME return NSError
        return;
    }
    
    self.postData = data;
    
    switch (self.httpMethod) {
        case MyHttpMethodGet:
            self->_ok = [self->_myEasyModel SetGetMethod];
            break;
            
        case MyHttpMethodPost:
            self->_ok = [self->_myEasyModel SetPostMethod];
            
            if (self->_ok) {
                [self->_myEasyModel SetPostData:self.postData];
            }
            
            if (self->_ok) {
                [self->_myEasyModel SetJsonContent];
            }
            break;
            
        case MyHttpMethodPut:
            self->_ok = [self->_myEasyModel SetPutMethod];
            
            if (self->_ok) {
                self->_ok = [self->_myEasyModel SetPutData:self.postData];
            }
            
            if (!self->_ok) {
                return;
            }
            
            if (self.isPlainTextAttachment) {
                self->_ok = [self->_myEasyModel SetPlainTextContent];
            }
            else {
                self->_ok = [self->_myEasyModel SetJsonContent];
            }
            
            break;
            
        case MyHttpMethodDelete:
            self->_ok = [self->_myEasyModel SetDeleteMethod];
            break;
            
        default:
            break;
    }

    if (self->_ok) {
        self->_ok = [self->_myEasyModel Run:url];
    }
}

- (NSString*)GetResult {
    if (self->_ok) {
        return [self->_myEasyModel GetContent];
    }
    
    return [self->_myEasyModel GetError];
}

@end
