//
//  main.swift
//  lensconvert
//
//  Created by Richard Henry on 30/10/2014.
//  Copyright (c) 2014 Dogstar Industries. All rights reserved.
//

import Foundation

// MARK: Parser

class SupplierParser : NSObject, XMLParserDelegate {

    class Supplier {

        var name : String = ""
    }

    var suppliers : [Supplier] = []

    // MARK: Document Parsing

    func parserDidStartDocument(_ parser: XMLParser) {

        print("Started parsing \(parser)")
    }

    func parserDidEndDocument(_ parser: XMLParser) {

        print("Finished parsing \(suppliers)")
    }

    // MARK: Element Parsing

    func parser(_ parser: XMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [AnyHashable: Any]!) {

        if (elementName == "Supplier") {

            suppliers.append(Supplier())
        }

        print("Start element \(elementName) attr \(attributeDict)")
    }

    func parser(_ parser: XMLParser, foundCharacters string: String!) {

        if (!string.hasPrefix("\n")) { print("Element >\(string)<") }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {

        if (elementName == "Supplier") {}
        
        print("End element \(elementName)")
    }
}

// MARK: - Main

let arg = ProcessInfo.processInfo.arguments
if let xml = XMLParser(contentsOf:URL(fileURLWithPath:arg[1] as String)) {

    // Set up the parse object
    let p = SupplierParser()

    // Set up the xml parser
    xml.delegate = p

    // Start parsing
    xml.parse()
}

/*

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

*/
