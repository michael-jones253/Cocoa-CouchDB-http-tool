//
//  MyCurlCppImpl.cpp
//  CocoaCurl
//
//  Created by Michael Jones on 12/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//

#include "MyCurlCppImpl.h"
#include <iostream>

using namespace std;

namespace  {
    int writer(char *data, size_t size, size_t nmemb,
               std::string *writerData)
    {
        if (writerData == NULL)
            return 0;
        
        writerData->append(data, size*nmemb);
        
        return static_cast<int>(size * nmemb);
    }
}

namespace MyCurlCpp {
    MyCurlCppImpl::MyCurlCppImpl() :
    _conn{},
    _contentBuffer{},
    _errorBuffer{} {
        // Not thread safe
        curl_global_init(CURL_GLOBAL_DEFAULT);
    }
    
    MyCurlCppImpl::~MyCurlCppImpl() {
        cout << "MyCurlCppImpl destructing" << endl;
    }
    
    void MyCurlCppImpl::HelloCurl() const {
        cout << "hello world" << endl;
        CURL *curl;
        CURLcode res;
        
        curl = curl_easy_init();
        if(curl) {
            curl_easy_setopt(curl, CURLOPT_URL, "http://example.com");
            /* example.com is redirected, so we tell libcurl to follow redirection */
            curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
            
            /* Perform the request, res will get the return code */
            res = curl_easy_perform(curl);
            /* Check for errors */
            if(res != CURLE_OK)
                fprintf(stderr, "curl_easy_perform() failed: %s\n",
                        curl_easy_strerror(res));
            
            /* always cleanup */
            curl_easy_cleanup(curl);
        }
    }
    
    void MyCurlCppImpl::Run(char const* url) {
        CURLcode res;
        
        _conn = curl_easy_init();
        if(!_conn) {
            throw runtime_error("Failed to easy init");
        }
        
        InitErrorBuffer();
        InitWriter();
        
        curl_easy_setopt(_conn, CURLOPT_URL, url);
        
        // Not sure what effect this has on non directed locations - I guess nothing.
        curl_easy_setopt(_conn, CURLOPT_FOLLOWLOCATION, 1L);
        
        _contentBuffer.clear();
        
        /* Perform the request, res will get the return code */
        res = curl_easy_perform(_conn);
        /* Check for errors */
        if(res != CURLE_OK) {
            string errStr = "curl_easy_perform() failed: ";
            errStr += curl_easy_strerror(res);
            throw runtime_error(errStr);
        }
        
        /* always cleanup */
        curl_easy_cleanup(_conn);
    }
    
    string MyCurlCppImpl::GetContent() const {
        return _contentBuffer;
    }
    
    string MyCurlCppImpl::GetError() const {
        return _errorBuffer.data();
    }
    
    void MyCurlCppImpl::InitErrorBuffer() {
        memset(_errorBuffer.data(), 0, _errorBuffer.size());
        
        auto res = curl_easy_setopt(_conn, CURLOPT_ERRORBUFFER, _errorBuffer.data());
        if(res != CURLE_OK) {
            string errStr = "curl_easy_setopt( error buffer ) failed: ";
            errStr += curl_easy_strerror(res);
            throw runtime_error(errStr);
        }
    }
    
    void MyCurlCppImpl::InitWriter() {
        CURLcode code = curl_easy_setopt(_conn, CURLOPT_WRITEFUNCTION, writer);
        if (code != CURLE_OK)
        {
            string errStr = "Failed to set writer: ";
            errStr += _errorBuffer.data();
            
            throw runtime_error(errStr);
        }
        
        code = curl_easy_setopt(_conn, CURLOPT_WRITEDATA, &_contentBuffer);
        if (code != CURLE_OK)
        {
            string errStr = "Failed to set write buffer: ";
            errStr += _errorBuffer.data();
            
            throw runtime_error(errStr);
        }
    }
}
