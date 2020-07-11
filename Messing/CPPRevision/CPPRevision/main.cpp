//
//  main.cpp
//  CPPRevision
//
//  Created by Richard Henry on 19/06/2020.
//  Copyright © 2020 Dogstar Industries Ltd. All rights reserved.
//

#include <iostream>
#include <functional>

#include "cfuncs.h"

static void np_example();
static void iter_example();

constexpr int fibonacci(const int);

int main(int argc, const char ** argv) {

    const auto arg = argv[1];
    const char *helloWorld = "Hello, World!";
    
    if (arg) std::cout << helloWorld << " arg = " << arg << std::endl;
    
    [out = std::ref(std::cout << "Result from C func : " << add(1, 2))]() { out.get() << "." << std::endl; }();
    
    // nullptr
    np_example();
    
    // const_expr
    std::cout << fibonacci(10) << std::endl;

    // iterator
    iter_example();
    
    return 0;
}

// MARK: iterator example

#include <vector>

static void iter_example() {
   
    std::vector<int> vec = { 1, 2, 3, 4 };
    
    auto itr = std::find(vec.begin(), vec.end(), 2);

    if (itr != vec.end()) { *itr = 3; }
    
    // The previous can be condensed as like:
    if (auto itr = std::find(vec.begin(), vec.end(), 3); itr != vec.end()) { *itr = 4; }
    
    for (auto itr = vec.begin(); itr != vec.end(); itr++) { std::cout << *itr << ", "; }
    std::cout << std::endl;
}

// MARK: constexpr example

constexpr int fibonacci(const int n) { return n == 1 || n == 2 ? 1 : fibonacci(n - 1) + fibonacci(n - 2); }

// MARK: nullptr example

#include <type_traits>

void foo(char *) { std::cout << "foo(char *) is called" << std::endl; }
void foo(int i)  { std::cout << "foo(int) is called" << std::endl; }

void np_example() {
    
    if (std::is_same<decltype(NULL), decltype(0)>::value) std::cout << "NULL == 0" << std::endl;
    if (std::is_same<decltype(NULL), decltype((void*)0)>::value) std::cout << "NULL == (void *)0" << std::endl;
    if (std::is_same<decltype(NULL), std::nullptr_t>::value) std::cout << "NULL == nullptr" << std::endl;

    foo(0);          // will call foo(int)
    // foo(NULL);    // doesn't compile - call is ambiguous
    foo(nullptr);    // will call foo(char*)
}
