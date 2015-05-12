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