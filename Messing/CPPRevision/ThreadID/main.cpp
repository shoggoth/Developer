//
//  main.cpp
//  ThreadID
//
//  Created by Richard Henry on 19/06/2020.
//  Copyright © 2020 Dogstar Industries Ltd. All rights reserved.
//

#include <iostream>
#include <thread>

int main(int argc, const char ** argv) {

    const auto main_thread_id = std::this_thread::get_id();
    
    std::cout << "Hello, World! main thread = " << main_thread_id << std::endl;
    
    auto lambda = [main_thread_id](int n) {
        
        const auto this_thread_id = std::this_thread::get_id();
        
        std::cout << "n is " << n << ", t is "<< this_thread_id << std::endl;
        
        std::cout << ((this_thread_id == main_thread_id) ? "On main thread" : "On Spawned thread") << std::endl;
    };
    
    // Start a thread going.
    std::thread thread(lambda, 23);
    thread.join();

    // On the main thread
    lambda(42);
    
    return 0;
}
