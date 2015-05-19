//
//  MyPutStream.h
//  CocoaCurl
//
//  Created by Michael Jones on 19/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//

#ifndef __CocoaCurl__MyPutStream__
#define __CocoaCurl__MyPutStream__

#include <stdio.h>
namespace MyCurlCpp {
    
    class MyPutStream {
        ssize_t _position;
    public:
        ssize_t Read(void* dest, size_t size, size_t nitems);
    private:
        virtual char const* Data() const = 0;
        virtual size_t Length() const = 0;
    };
}

#endif /* defined(__CocoaCurl__MyPutStream__) */
