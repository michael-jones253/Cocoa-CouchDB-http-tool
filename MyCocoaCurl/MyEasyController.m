//
//  MyEasyController.m
//  
//
//  Created by Michael Jones on 13/05/2015.
//
//

#import "MyEasyController.h"

@interface MyEasyController()
// Private.
- (NSError*)MakeRunError: (NSString*const)message;

- (NSData*) dataFromImageFile: (NSString*)fileName error: (NSError**)loadError;

@end


@implementation MyEasyController

- (id)init {
    self = [super init];
    if (self) {
        self.httpMethod = MyHttpMethodGet;
        self.postData = @"{\"company\": \"Example, Inc.\"}";
        self.isPlainTextAttachment = FALSE;
        self->_myEasyModel = [[MyEasyCurl alloc]init];
    }    
    
    return self;
}

- (BOOL)RunUrl: (NSString*)url applicationData: (NSString*)data error: (NSError**)runError {
    BOOL ok = FALSE;
    ok = [self->_myEasyModel InitConnection];
    
    if (!ok) {
        if (runError != nil) {
            *runError = [self MakeRunError:[self->_myEasyModel GetError]];
        }
        return FALSE;
    }
    
    if (self.isPlainTextAttachment && self.httpMethod != MyHttpMethodPut) {
        if (runError != nil) {
            *runError = [self MakeRunError:@"Plain text attachment must use PUT"];
        }
        return FALSE;
    }

    if (self.isPlainTextAttachment && ![url containsString:@"attachment"]) {
        if (runError != nil) {
            *runError = [self MakeRunError:@"Plain text attachment must have \"attachment?rev=<revision>\" in URI"];
        }
        return FALSE;
    }
    
    if (self.isPlainTextAttachment && ![url containsString:@"?rev="]) {
        if (runError != nil) {
            *runError = [self MakeRunError:@"Plain text attachment must specify document revision: ?rev=<revision>"];
        }
        return FALSE;
    }
    
    if (self.isDumpOn) {
        ok = [self->_myEasyModel SetDebugOn];
        if (!ok) {
            if (runError != nil) {
                *runError = [self MakeRunError:@"Failed to set dump on"];
            }
            return FALSE;
        }
    }

    self.postData = data;
    
    switch (self.httpMethod) {
        case MyHttpMethodGet:
            ok = [self->_myEasyModel SetGetMethod];
            break;
            
        case MyHttpMethodPost:
            ok = [self->_myEasyModel SetPostMethod];
            if (!ok) {
                break;
            }
            
            ok = [self->_myEasyModel SetPostData:self.postData];
            if (!ok) {
                break;
            }
            
            ok = [self->_myEasyModel SetJsonContent];
            break;
            
        case MyHttpMethodPut:
            ok = [self->_myEasyModel SetPutMethod];
            if (!ok) {
                break;
            }
            
            ok = [self->_myEasyModel SetPutData:self.postData];
            
            if (!ok) {
                break;
            }
            
            if (self.isPlainTextAttachment) {
                ok = [self->_myEasyModel SetPlainTextContent];
            }
            else {
                ok = [self->_myEasyModel SetJsonContent];
            }
            
            break;
            
        case MyHttpMethodDelete:
            ok = [self->_myEasyModel SetDeleteMethod];
            break;
            
        default:
            break;
    }

    if (ok) {
        ok = [self->_myEasyModel Run:url];
    }
    
    // Note to self: this error object Vs exception throwing control flow can get a bit messy.
    if (!ok) {
        if (runError != nil) {
            *runError = [self MakeRunError:[self->_myEasyModel GetError]];
        }
        
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL)LoadImageFromFile: (NSString*) fileName error: (NSError**)loadError {
    self.imageData = [self dataFromImageFile:fileName error:loadError];
    
    [self->_myEasyModel SetImageDataNoCache:self.imageData];

    return self.imageData != nil;
}


- (NSString*)GetResult {
    return [self->_myEasyModel GetContent];
}

- (NSString*)GetDump {
    return [self->_myEasyModel GetDump];
}

- (NSError*)MakeRunError: (NSString*const)message {
    NSString *domain = @"com.Jones.CocoaCurl.ErrorDomain";
    NSString *desc = NSLocalizedString(message, nil);
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
    
    NSError *error = [NSError errorWithDomain:domain
                                         code:-101
                                     userInfo:userInfo];
    return error;
}

- (NSData*) dataFromImageFile: (NSString*)fileName error: (NSError**)loadError{
    NSData* imageData = [NSData dataWithContentsOfFile:fileName options:NSDataReadingMappedAlways error:loadError];
    return imageData;
}

@end
