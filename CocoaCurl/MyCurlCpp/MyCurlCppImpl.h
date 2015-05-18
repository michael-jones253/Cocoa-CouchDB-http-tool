//
//  MyCurlCppImpl.h
//  CocoaCurl
//
//  Created by Michael Jones on 12/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//

#ifndef __CocoaCurl__MyCurlCppImpl__
#define __CocoaCurl__MyCurlCppImpl__

#include "MyPutBufferStream.h"
#include <curl/curl.h>
#include <stdio.h>
#include <array>
#include <string>

namespace MyCurlCpp {
    
    class MyCurlCppImpl final {
        CURL* _conn;
        std::array<char, CURL_ERROR_SIZE> _errorBuffer;
        std::string _contentBuffer;
        struct curl_slist* _headerList;
        std::string _postData;
        std::string _dump;
        MyPutBufferStream _putBufferStream;
        
    public:
        MyCurlCppImpl();
        ~MyCurlCppImpl();
        void HelloCurl() const;
        
        void InitConnection();
        
        void SetGetMethod();
        
        void SetPostMethod();
        
        void SetPuttMethod();
        
        void SetDeleteMethod();

        void SetPostData(std::string const& data);

        void SetPutData(std::string const& data);
        
        void SetJsonContent();
        
        void SetPlainTextContent();
        
        void SetDebugOn();

        void Run(char const* url);
        
        std::string GetContent() const;
        
        std::string const& GetDump() const;
        
        std::string GetError() const;
        
    private:
        void InitErrorBuffer();
        void InitWriter();
    };
}

#endif /* defined(__CocoaCurl__MyCurlCppImpl__) */
