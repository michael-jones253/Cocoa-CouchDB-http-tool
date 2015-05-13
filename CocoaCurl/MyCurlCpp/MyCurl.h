//
//  MyCurl.h
//  CocoaCurl
//
//  Created by Michael Jones on 12/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//

#ifndef __CocoaCurl__MyCurl__
#define __CocoaCurl__MyCurl__

#include <stdio.h>
#include <memory>
#include <string>

/* The classes below are exported */
#pragma GCC visibility push(default)

namespace MyCurlCpp {
    // Hide impl.
    class MyCurlCppImpl;
    
    class MyCurl final {
        std::unique_ptr<MyCurlCppImpl> _impl;
        
    public:
        MyCurl();
        ~MyCurl();
        
        bool HelloCurl() const;
        
        bool InitConnection();
        
        bool SetGetMethod();
        
        bool SetPostMethod();
        
        bool SetPutMethod();
        
        bool SetDeleteMethod();
        
        bool SetPostData(char const* postData);
        
        bool SetJsonContent();
        
        bool Run(char const* url);
        
        std::string GetContent() const;
        
        std::string GetError() const;
    };
}

#pragma GCC visibility pop

#endif /* defined(__CocoaCurl__MyCurl__) */
