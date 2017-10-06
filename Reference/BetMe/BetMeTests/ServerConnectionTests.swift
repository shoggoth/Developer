//
//  ServerConnectionTests.swift
//  BetMe
//
//  Created by Rich Henry on 24/05/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import XCTest
import Starscream

@testable import BetMe

class ServerConnectionTests: XCTestCase {
    
    override func setUp() {

        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {

        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testConnect() {

        let connection = ServerConnection()

        // Expectations for connect and disconnect
        let c = expectation(description: "connect")
        let d = expectation(description: "disconnect")

        connection.connect {

            XCTAssert(connection.connected)

            c.fulfill()

            connection.disconnect {

                XCTAssert(!connection.connected)
                
                d.fulfill()
            }
        }

        waitForExpectations(timeout: 1) { error in

            if let err = error { print("Error in testConnect : \(err.localizedDescription)") }
        }
    }

    func testPingWrite() {

        let connection = ServerConnection()

        // Expectations for connect and disconnect
        let c = expectation(description: "connect")
        let d = expectation(description: "disconnect")
        let p = expectation(description: "pingReply")

        connection.connect {

            c.fulfill()

            let pingObject = makeJSONQueryDict(withMethod: "ping", id: "PING 0")

            connection.writeRequest(jsonObject: pingObject) { reply in

                p.fulfill()
            }

            connection.disconnect {

                XCTAssert(!connection.connected)

                d.fulfill()
            }
        }

        waitForExpectations(timeout: 1) { error in

            if let err = error { print("Error in testWrite : \(err.localizedDescription)") }
        }
    }
}
