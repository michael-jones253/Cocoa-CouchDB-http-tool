//
//  MyPutBufferStream.h
//  CocoaCurl
//
//  Created by Michael Jones on 14/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//

#ifndef __CocoaCurl__MyPutBufferStream__
#define __CocoaCurl__MyPutBufferStream__

#include <string>

namespace MyCurlCpp {
    
    class MyPutBufferStream final {
        std::string _buffer;
        ssize_t _position;
    public:
        void Load(std::string const& putString);
        ssize_t Read(void* dest, size_t size, size_t nitems);
    };
}

#endif /* defined(__CocoaCurl__MyPutBufferStream__) */
