//
//  MyPutNoCacheStream.cpp
//  CocoaCurl
//
//  Created by Michael Jones on 20/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//

#include "MyPutNoCacheStream.h"

namespace MyCurlCpp {
    void MyPutNoCacheStream::Load(char const* buffer, size_t length) {
        Reset();
        _bufferPtr = buffer;
        _length = length;
    }
    
    char const* MyPutNoCacheStream::Data() const {
        return _bufferPtr;
    }
    
    size_t MyPutNoCacheStream::Length() const {
        return _length;
    }
}