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
        _buffer = putString;
        _position = 0;
    }

    ssize_t MyPutBufferStream::Read(void* dest, size_t size, size_t nitems) {
        auto requestedSize = size * nitems;
        auto remaining = _buffer.length() - _position;
        auto amountToCopy = min(requestedSize, remaining);
        
        memcpy(dest, _buffer.data(), amountToCopy);
        _position += amountToCopy;
        
        assert(_position <= _buffer.length());
        assert(amountToCopy >= 0);
        
        return amountToCopy;
    }
}
