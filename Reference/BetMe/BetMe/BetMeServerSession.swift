//
//  BetMeServerSession.swift
//  BetMe
//
//  Created by Rich Henry on 28/04/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import Foundation

class BetMeServerSession : ServerSession {

    class var sharedInstance : ServerSession {

        struct Static { static let instance: ServerSession = ServerSession() }

        return Static.instance
    }
}
