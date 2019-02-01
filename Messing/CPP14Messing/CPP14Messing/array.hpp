//
//  array.hpp
//  CPP14Messing
//
//  Created by Richard Henry on 01/02/2019.
//  Copyright © 2019 Dogstar Industries Ltd. All rights reserved.
//

#ifndef array_hpp
#define array_hpp

#include <stdio.h>

namespace DataStructures {
    
    template <typename T> class Array {
        
        T       *ptr;
        int     size;
        
    public:
        Array(T arr[], int s);
        ~Array();
        void print();
    };
    
    template <typename T> Array<T>::Array(T arr[], int size) {
        
        this->ptr = new T[size];
        this->size = size;
        
        { T *p, *a; for (p = ptr, a = arr; p < &ptr[size];) *p++ = *a++; }
    }
    
    template <typename T> void Array<T>::print() {
        
        for (T *p = ptr; p < &ptr[size]; p++) std::cout << p << " ";
        
        std::cout << std::endl;
    }
    
    template <typename T> Array<T>::~Array() {
        
        delete [] ptr;
    }
}

#endif /* array_hpp */
