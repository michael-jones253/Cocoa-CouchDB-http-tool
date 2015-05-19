//
//  MyPutBufferStream.h
//  CocoaCurl
//
//  Created by Michael Jones on 14/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//

#ifndef __CocoaCurl__MyPutBufferStream__
#define __CocoaCurl__MyPutBufferStream__

#include "MyPutStream.h"
#include <string>

namespace MyCurlCpp {
    
    class MyPutBufferStream final : public MyPutStream {
        std::string _buffer;
    public:
        void Load(std::string const& putString);
    private:
        char const* Data() const override;
        size_t Length() const override;
    };
}

#endif /* defined(__CocoaCurl__MyPutBufferStream__) */
