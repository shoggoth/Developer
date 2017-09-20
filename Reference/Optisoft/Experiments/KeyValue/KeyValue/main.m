//
//  main.m
//  KeyValue
//
//  Created by Richard Henry on 26/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//


@interface KVCoder : NSObject

@property(nonatomic, assign) NSNumber *identifier;

@end

@implementation KVCoder

- (NSString *)description { return [NSString stringWithFormat:@"KVT object (%@)", self.identifier]; }

@end


@interface KVObserver : NSObject

@end

@implementation KVObserver

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    NSLog(@"%@'s %@ changed to %@", object, keyPath, [object valueForKey:keyPath]);
}

@end

int main(int argc, const char *argv[]) {

    @autoreleasepool {

        KVCoder *observed = [KVCoder new];
        KVCoder *observed2 = [KVCoder new];
        KVObserver *observer = [KVObserver new];

        [observed addObserver:observer forKeyPath:@"identifier" options:0 context:0];
        [observed2 addObserver:observer forKeyPath:@"identifier" options:0 context:0];

        observed.identifier = @31337;

        [observed2 setValue:@9001 forKey:@"identifier"];

        // insert code here...
        NSLog(@"KVT = %@", observed);

        [observed removeObserver:observer forKeyPath:@"identifier"];
        [observed2 removeObserver:observer forKeyPath:@"identifier"];
    }

    return 0;
}

