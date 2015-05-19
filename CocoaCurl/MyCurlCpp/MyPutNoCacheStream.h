//
//  MyPutNoCacheStream.h
//  CocoaCurl
//
//  Created by Michael Jones on 20/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//

#ifndef __CocoaCurl__MyPutNoCacheStream__
#define __CocoaCurl__MyPutNoCacheStream__

#include <stdio.h>
#include "MyPutStream.h"

namespace MyCurlCpp {
    
    class MyPutNoCacheStream final : public MyPutStream {
        char const* _bufferPtr;
        size_t _length;
    public:
        void Load(char const* buffer, size_t length);
    private:
        char const* Data() const override;
        size_t Length() const override;
    };
}

#endif /* defined(__CocoaCurl__MyPutNoCacheStream__) */
