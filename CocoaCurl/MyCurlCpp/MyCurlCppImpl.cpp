//
//  MyCurlCppImpl.cpp
//  CocoaCurl
//
//  Created by Michael Jones on 12/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//

#include "MyCurlCppImpl.h"
#include <iostream>
#include <sstream>

using namespace std;

namespace  {
    int write_callback(char *data, size_t size, size_t nmemb,
               std::string *writerData) {
        if (writerData == NULL)
            return 0;
        
        writerData->append(data, size*nmemb);
        
        return static_cast<int>(size * nmemb);
    }
    
    size_t read_callback(char *buffer, size_t size, size_t nitems, void *instream) {
        // Cast to generic put stream.
        auto bufferStream = static_cast<MyCurlCpp::MyPutStream*>(instream);
        auto bytesRead = bufferStream->Read(buffer, size, nitems);

        return bytesRead;
    }
    
    int trace_callback(CURL *handle, curl_infotype type,
                 char *data, size_t length,
                       void *userp) {
        
        auto dumpStr = static_cast<string*>(userp);
        
        if (type == CURLINFO_HEADER_OUT) {
            dumpStr->append(data, length);
            dumpStr->append("\n");
        }
        
        return 0;
    }
}

namespace MyCurlCpp {
    MyCurlCppImpl::MyCurlCppImpl() :
    _conn{},
    _contentBuffer{},
    _errorBuffer{},
    _headerList{},
    _postData{},
    _dump{},
    _putBufferStream{} {
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
    
    void MyCurlCppImpl::InitConnection() {
        _conn = curl_easy_init();
        if(_conn == nullptr) {
            throw runtime_error("Failed to easy init");
        }
        
        InitErrorBuffer();
        InitWriter();
    }
    
    void MyCurlCppImpl::SetGetMethod() {
        CURLcode res = curl_easy_setopt(_conn, CURLOPT_HTTPGET, 1L);
        if(res != CURLE_OK) {
            string errStr = "curl_setopt(HTTPGET) failed: ";
            errStr += curl_easy_strerror(res);
            throw runtime_error(errStr);
        }
    }
    
    void MyCurlCppImpl::SetPostMethod() {
        CURLcode res = curl_easy_setopt(_conn, CURLOPT_HTTPPOST, 1L);
        if(res != CURLE_OK) {
            string errStr = "curl_setopt(HTTPPOST) failed: ";
            errStr += curl_easy_strerror(res);
            throw runtime_error(errStr);
        }
    }
    
    void MyCurlCppImpl::SetPuttMethod() {
        CURLcode res = curl_easy_setopt(_conn, CURLOPT_PUT, 1L);
        if(res != CURLE_OK) {
            string errStr = "curl_setopt(HTTPPUT) failed: ";
            errStr += curl_easy_strerror(res);
            throw runtime_error(errStr);
        }
    }
    
    void MyCurlCppImpl::SetDeleteMethod() {
        CURLcode res = curl_easy_setopt(_conn, CURLOPT_CUSTOMREQUEST,"DELETE");
        if(res != CURLE_OK) {
            string errStr = "curl_setopt(HTTPDELETE) failed: ";
            errStr += curl_easy_strerror(res);
            throw runtime_error(errStr);
        }
    }
    
    void MyCurlCppImpl::SetPostData(string const& data) {
        _postData = data;
        
        CURLcode res = curl_easy_setopt(_conn, CURLOPT_POSTFIELDSIZE, _postData.length());
        if(res != CURLE_OK) {
            string errStr = "curl_setopt(HTTPPOST size) failed: ";
            errStr += curl_easy_strerror(res);
            throw runtime_error(errStr);
        }
        
        
        /* pass in a pointer to the data - libcurl will not copy */
        res = curl_easy_setopt(_conn, CURLOPT_POSTFIELDS, _postData.data());
        if(res != CURLE_OK) {
            string errStr = "curl_setopt(HTTPPOST data) failed: ";
            errStr += curl_easy_strerror(res);
            throw runtime_error(errStr);
        }
    }
    
    void MyCurlCppImpl::SetPutData(std::string const& data) {
        _putBufferStream.Load(data);
        
        CURLcode res = curl_easy_setopt(_conn, CURLOPT_READDATA, &_putBufferStream);
        if(res != CURLE_OK) {
            string errStr = "curl_setopt(HTTPPPUT read data) failed: ";
            errStr += curl_easy_strerror(res);
            throw runtime_error(errStr);
        }
        
        
        /* pass in a pointer to the data - libcurl will not copy */
        res = curl_easy_setopt(_conn, CURLOPT_READFUNCTION, read_callback);
        if(res != CURLE_OK) {
            string errStr = "curl_setopt(HTTPPUT read function) failed: ";
            errStr += curl_easy_strerror(res);
            throw runtime_error(errStr);
        }
    }
    
    void MyCurlCppImpl::SetJsonContent() {
        SetContentType("application/json");
    }

    void MyCurlCppImpl::SetPlainTextContent() {
        SetContentType("text/plain");
    }

    void MyCurlCppImpl::SetJpegContent() {
        SetContentType("image/jpg");
    }
    
    void MyCurlCppImpl::SetDebugOn() {
        if(_conn == nullptr) {
            throw runtime_error("No CURL connection for set debug on");
        }
        
        CURLcode code = curl_easy_setopt(_conn, CURLOPT_DEBUGDATA, &_dump);
        
        code = curl_easy_setopt(_conn, CURLOPT_DEBUGFUNCTION, trace_callback);
        if (code != CURLE_OK)
        {
            string errStr = "Failed to debug function: ";
            errStr += _errorBuffer.data();
            
            throw runtime_error(errStr);
        }
        
        /* the DEBUGFUNCTION has no effect until we enable VERBOSE */
        code = curl_easy_setopt(_conn, CURLOPT_VERBOSE, 1L);
        if (code != CURLE_OK)
        {
            string errStr = "Failed to debug verbose on: ";
            errStr += _errorBuffer.data();
            
            throw runtime_error(errStr);
        }
    }
    
    void MyCurlCppImpl::Run(char const* url) {
        CURLcode res;        
        
        curl_easy_setopt(_conn, CURLOPT_URL, url);
        
        // Not sure what effect this has on non directed locations - I guess nothing.
        curl_easy_setopt(_conn, CURLOPT_FOLLOWLOCATION, 1L);
        
        _contentBuffer.clear();
        _dump.clear();
        
        /* Perform the request, res will get the return code */
        res = curl_easy_perform(_conn);
        /* Check for errors */
        if(res != CURLE_OK) {
            string errStr = "curl_easy_perform() failed: ";
            errStr += curl_easy_strerror(res);
            throw runtime_error(errStr);
        }
        
        if (_headerList != nullptr) {
            curl_slist_free_all(_headerList);
            _headerList = nullptr;
        }        
        
        /* always cleanup */
        curl_easy_cleanup(_conn);
        _conn = nullptr;
    }
    
    string MyCurlCppImpl::GetContent() const {
        return _contentBuffer;
    }
    
    string const& MyCurlCppImpl::GetDump() const {
        return _dump;
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
        CURLcode code = curl_easy_setopt(_conn, CURLOPT_WRITEFUNCTION, write_callback);
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
    
    void MyCurlCppImpl::SetContentType(std::string const& contentType) {
        auto contentHeader = string{"Content-Type: "};
        contentHeader.append(contentType);
        
        _headerList = nullptr;
        if(_conn == nullptr) {
            throw runtime_error("No CURL connection for set header" + contentType);
        }
        
        _headerList = curl_slist_append(_headerList, contentHeader.c_str());
        CURLcode code = curl_easy_setopt(_conn, CURLOPT_HTTPHEADER, _headerList);
        if (code != CURLE_OK)
        {
            string errStr = "Failed to set: " + contentHeader;
            errStr += _errorBuffer.data();
            
            throw runtime_error(errStr);
        }
    }

    
}
