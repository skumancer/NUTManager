//
//  main.swift
//  NUTManagerNotifier
//
//  Created by Ricardo Chavarria on 5/28/17.
//  Copyright © 2017 Ricardo Chavarria. All rights reserved.
//

import Foundation

//class NUTManagerNotifier {

//    func main() -> Void {
let arguments = CommandLine.arguments
    .filter({
        guard let event = UPSEvent(rawValue:$0) else { return false }
        return true
    })
    .map { return UPSEvent(rawValue:$0)! }

if arguments.count > 0 {
    let center = CFNotificationCenterGetDistributedCenter()
    let notificationName = CFNotificationName(rawValue: "nutmanager.notification" as CFString)
    let info = NSDictionary(dictionary: ["notifications": CommandLine.arguments])
    
    CFNotificationCenterPostNotification(center, notificationName, nil, info as CFDictionary, true)
    
    exit(EXIT_SUCCESS)
}
else {
    print("Please include notification names as arguments")
}

exit(EXIT_FAILURE)
//    }
//}

