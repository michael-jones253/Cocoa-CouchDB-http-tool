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
    MyCurl::MyCurl() {
        _impl = make_unique<MyCurlCppImpl>();
    }
    
    MyCurl::~MyCurl() {
        
    }
    
    bool MyCurl::HelloCurl() const {
        bool ok{};
        
        try {
            _impl->HelloCurl();
            ok = true;
        } catch (exception const& ex) {
            cerr << "HelloCurl exception: " << ex.what() << endl;
        }
        
        return ok;
    }
    
    bool MyCurl::InitConnection() {
        bool ok{};
        try {
            _impl->InitConnection();
            ok = true;
        } catch (exception const& ex) {
            cerr << "HelloCurl exception: " << ex.what() << endl;
        }
        
        return ok;
    }
    
    bool MyCurl::SetGetMethod() {
        bool ok{};
        try {
            _impl->SetGetMethod();
            ok = true;
        } catch (exception const& ex) {
            cerr << "HelloCurl exception: " << ex.what() << endl;
        }
        
        return ok;
    }
    
    bool MyCurl::SetPostMethod() {
        bool ok{};
        try {
            _impl->SetPostMethod();
            ok = true;
        } catch (exception const& ex) {
            cerr << "HelloCurl exception: " << ex.what() << endl;
        }
        
        return ok;
    }
    
    bool MyCurl::SetPutMethod() {
        bool ok{};
        try {
            _impl->SetPuttMethod();
            ok = true;
        } catch (exception const& ex) {
            cerr << "HelloCurl exception: " << ex.what() << endl;
        }
        
        return ok;
    }
    
    
    bool MyCurl::SetDeleteMethod() {
        bool ok{};
        try {
            _impl->SetDeleteMethod();
            ok = true;
        } catch (exception const& ex) {
            cerr << "HelloCurl exception: " << ex.what() << endl;
        }
        
        return ok;
    }

    
    bool MyCurl::SetPostData(char const* postData) {
        bool ok{};
        try {
            _impl->SetPostData(postData);
            ok = true;
        } catch (exception const& ex) {
            cerr << "HelloCurl exception: " << ex.what() << endl;
        }
        
        return ok;
    }
    
    bool MyCurl::SetPutData(char const* postData) {
        bool ok{};
        try {
            _impl->SetPutData(postData);
            ok = true;
        } catch (exception const& ex) {
            cerr << "HelloCurl exception: " << ex.what() << endl;
        }
        
        return ok;
    }

    
    bool MyCurl::SetJsonContent() {
        bool ok{};
        try {
            _impl->SetJsonContent();
            ok = true;
        } catch (exception const& ex) {
            cerr << "HelloCurl exception: " << ex.what() << endl;
        }
        
        return ok;
    }
    
    bool MyCurl::Run(char const* url) {
        bool ok{};
        try {
            _impl->Run(url);
            ok = true;
        } catch (exception const& ex) {
            cerr << "HelloCurl exception: " << ex.what() << endl;
        }
        
        return ok;
    }
    
    string MyCurl::GetError() const {
        return _impl->GetError();
    }
    
    string MyCurl::GetContent() const {
        return _impl->GetContent();
    }
}