//
//  MyPutBufferStream.cpp
//  CocoaCurl
//
//  Created by Michael Jones on 14/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//

#include "MyPutBufferStream.h"
#include <string.h>
#include <assert.h>
#include <algorithm>

using namespace std;

namespace MyCurlCpp {
    void MyPutBufferStream::Load(std::string const& putString) {
        Reset();
        _buffer = putString;
    }

    char const* MyPutBufferStream::Data() const {
        return _buffer.data();
    }
    
    size_t MyPutBufferStream::Length() const {
        return _buffer.length();
    }
}
