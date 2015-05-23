//
//  MyCurl.cpp
//  CocoaCurl
//
//  Created by Michael Jones on 12/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//

#include "MyCurl.h"
#include "MyCurlCppImpl.h"

#include <iostream>

using namespace std;

namespace MyCurlCpp {
    MyCurl::MyCurl():
    _impl{},
    _exceptionText{} {
        _impl = make_unique<MyCurlCppImpl>();
    }
    
    MyCurl::~MyCurl() {
        
    }
    
    bool MyCurl::HelloCurl() {
        bool ok{};
        
        try {
            _exceptionText.clear();
            _impl->HelloCurl();
            ok = true;
        } catch (exception const& ex) {
            _exceptionText = ex.what();
        }
        
        return ok;
    }
    
    bool MyCurl::InitConnection() {
        bool ok{};
        try {
            _exceptionText.clear();
            _impl->InitConnection();
            ok = true;
        } catch (exception const& ex) {
            _exceptionText = ex.what();
        }
        
        return ok;
    }
    
    bool MyCurl::SetGetMethod() {
        bool ok{};
        try {
            _exceptionText.clear();
            _impl->SetGetMethod();
            ok = true;
        } catch (exception const& ex) {
            _exceptionText = ex.what();
        }
        
        return ok;
    }
    
    bool MyCurl::SetPostMethod() {
        bool ok{};
        try {
            _exceptionText.clear();
            _impl->SetPostMethod();
            ok = true;
        } catch (exception const& ex) {
            _exceptionText = ex.what();
        }
        
        return ok;
    }
    
    bool MyCurl::SetPutMethod() {
        bool ok{};
        try {
            _exceptionText.clear();
            _impl->SetPuttMethod();
            ok = true;
        } catch (exception const& ex) {
            _exceptionText = ex.what();
        }
        
        return ok;
    }
    
    
    bool MyCurl::SetDeleteMethod() {
        bool ok{};
        try {
            _exceptionText.clear();
            _impl->SetDeleteMethod();
            ok = true;
        } catch (exception const& ex) {
            _exceptionText = ex.what();
        }
        
        return ok;
    }

    
    bool MyCurl::SetPostData(char const* postData) {
        bool ok{};
        try {
            _exceptionText.clear();
            _impl->SetPostData(postData);
            ok = true;
        } catch (exception const& ex) {
            _exceptionText = ex.what();
        }
        
        return ok;
    }
    
    bool MyCurl::SetPutData(char const* postData) {
        bool ok{};
        try {
            _exceptionText.clear();
            _impl->SetPutData(postData);
            ok = true;
        } catch (exception const& ex) {
            _exceptionText = ex.what();
        }
        
        return ok;
    }
    
    bool MyCurl::SetPutNoCacheData(char const* buffer, size_t length) {
        bool ok{};
        try {
            _exceptionText.clear();
            _impl->SetPutNoCacheData(buffer, length);
            ok = true;
        } catch (exception const& ex) {
            _exceptionText = ex.what();
        }
        
        return ok;
    }
    
    bool MyCurl::SetJsonContent() {
        bool ok{};
        try {
            _exceptionText.clear();
            _impl->SetJsonContent();
            ok = true;
        } catch (exception const& ex) {
            _exceptionText = ex.what();
        }
        
        return ok;
    }
    
    bool MyCurl::SetPlainTextContent() {
        bool ok{};
        try {
            _exceptionText.clear();
            _impl->SetPlainTextContent();
            ok = true;
        } catch (exception const& ex) {
            _exceptionText = ex.what();
        }
        
        return ok;
    }
    
    bool MyCurl::SetJpegContent() {
        bool ok{};
        try {
            _exceptionText.clear();
            _impl->SetJpegContent();
            ok = true;
        } catch (exception const& ex) {
            _exceptionText = ex.what();
        }
        
        return ok;
    }
    
    bool MyCurl::SetDebugOn() {
        bool ok{};
        try {
            _exceptionText.clear();
            _impl->SetDebugOn();
            ok = true;
        } catch (exception const& ex) {
            _exceptionText = ex.what();
        }
        
        return ok;
    }
    
    bool MyCurl::Run(char const* url) {
        bool ok{};
        try {
            _exceptionText.clear();
            _impl->Run(url);
            ok = true;
        } catch (exception const& ex) {
            _exceptionText = ex.what();
        }
        
        return ok;
    }
    
    string MyCurl::GetError() const {
        auto message = _exceptionText;
        if (message.length() > 0) {
            message += ": ";
        }
        
        message += _impl->GetErrorBuffer();
        
        return message;
    }
    
    string MyCurl::GetContent() const {
        return _impl->GetContent();
    }
    
    string const& MyCurl::GetDump() const {
        return _impl->GetDump();
    }
}