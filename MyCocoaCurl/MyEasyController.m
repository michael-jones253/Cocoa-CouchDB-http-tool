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
        self->_ok = FALSE;
        self->_myImpl = [[MyEasyCurl alloc]init];
    }    
    
    return self;
}

- (void)Run: (NSString*)url {
    self->_ok = [self->_myImpl InitConnection];
    
    if (!self->_ok) {
        return;
    }
    
    switch (self.httpMethod) {
        case MyHttpMethodGet:
            self->_ok = [self->_myImpl SetGetMethod];
            break;
            
        case MyHttpMethodPost:
            self->_ok = [self->_myImpl SetPostMethod];
            
            if (self->_ok) {
                [self->_myImpl SetJsonContent];
            }
            break;
            
        default:
            break;
    }

    if (self->_ok) {
        self->_ok = [self->_myImpl Run:url];
    }
}

- (NSString*)GetResult {
    if (self->_ok) {
        return [self->_myImpl GetContent];
    }
    
    return [self->_myImpl GetError];
}

@end
