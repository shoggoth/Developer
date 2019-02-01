//
//  stack.hpp
//  CPP14Messing
//
//  Created by Richard Henry on 01/02/2019.
//  Copyright © 2019 Dogstar Industries Ltd. All rights reserved.
//

#ifndef stack_hpp
#define stack_hpp

#include <vector>

namespace DataStructures {
    
    template <class T>
    
    class Stack {
        
        T value;
        
    public:
        void push(const T value);
        const T pop();
    };
}


#endif /* stack_hpp */
