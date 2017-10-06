//
//  main.m
//  lensSupplierConvert
//
//  Created by Richard Henry on 29/10/2014.
//  Copyright (c) 2014 Dogstar Industries. All rights reserved.
//

@import Foundation;

@interface Parser : NSObject <NSXMLParserDelegate>

@end

@implementation Parser

#pragma mark Document

- (void)parserDidStartDocument:(NSXMLParser *)parser {

    NSLog(@"Started parsing %@", parser);
}

#pragma mark Element

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

    NSLog(@"Found element %@ %@", elementName, attributeDict);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {

    NSLog(@"Found characters %@", string);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {

    NSLog(@"Ended element %@", elementName);
}

@end

int main(int argc, const char * argv[]) {

    @autoreleasepool {

        NSArray     *arguments = [[NSProcessInfo processInfo] arguments];
        NSString    *suppliersFile = arguments[1];
        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:[[NSURL alloc] initFileURLWithPath:suppliersFile]];
        Parser      *parser = [Parser new];

        NSLog(@"Parsing %@…", suppliersFile);

        xmlParser.delegate = parser;

        [xmlParser parse];
    }

    return 0;
}
