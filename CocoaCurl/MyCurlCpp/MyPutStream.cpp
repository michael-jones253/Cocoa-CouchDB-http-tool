//
//  MyPutStream.cpp
//  CocoaCurl
//
//  Created by Michael Jones on 19/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//

#include "MyPutStream.h"
#include <string.h>
#include <assert.h>
#include <algorithm>

using namespace std;

namespace MyCurlCpp {
    
    ssize_t MyPutStream::Read(void* dest, size_t size, size_t nitems) {
        auto requestedSize = size * nitems;
        auto remaining = Length() - _position;
        auto amountToCopy = min(requestedSize, remaining);
        
        memcpy(dest, Data(), amountToCopy);
        _position += amountToCopy;
        
        assert(_position <= Length());
        assert(amountToCopy >= 0);
        
        return amountToCopy;
    }
}
