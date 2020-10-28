//
//  stack.hpp
//  CPP14Messing
//
//  Created by Richard Henry on 01/02/2019.
//  Copyright © 2019 Dogstar Industries Ltd. All rights reserved.
//

#ifndef stack_hpp
#define stack_hpp

#include <iostream>
#include <vector>

#include "local.hpp"

namespace DataStructures {
    
    template <typename T> class Stack : Local::Printable {
        
        std::vector<T>  stack;
        
    public:
        ~Stack();
        
        void push(const T value);
        const T pop();
        
        void sort();
        
        inline void print() { std::cout << "Stack placeholder" << std::endl; }
    };
    
    template <typename T> Stack<T>::~Stack() {
        
        // Create an empty vector with no memory allocated and swap it with stack, effectively
        // deallocating the memory used.
        std::vector<T>().swap(stack);
    }

    template <typename T> void Stack<T>::push(const T value) { stack.push_back(value); }
    
    template <typename T> const T Stack<T>::pop() {
        
        assert(!stack.empty());
        
        T val = stack.back();
        stack.pop_back();
        
        return val;
    }
    
    template <typename T> void Stack<T>::sort() {
        
        std::sort(stack.begin(), stack.end(), [](const T &a, const T &b) -> bool { return a > b; });
    }
}


#endif /* stack_hpp */
