//
//  Silk.swift
//  BetMe
//
//  Created by Rich Henry on 07/07/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import Foundation

struct Silk {

    static func imageURL(fromEntryData entryData: [String : Any]) -> NSURL? {

        // Get meta data dictionary
        if let metaData = entryData["meta_data"] as? [String : Any] {

            // Load silk "silk_url":"m:/silks/60038.png"
            if let silkURLArray = (metaData["silk_url"] as? String)?.components(separatedBy: ":") {

                if silkURLArray.count == 2 && silkURLArray[0] == "m" {

                    return NSURL(string: "http://loki.easysoft.local:82\(silkURLArray[1])")
                }
            }
        }
        
        return nil
    }

}
