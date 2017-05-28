//
//  UPSEvent.swift
//  NUTManager
//
//  Created by Ricardo Chavarria on 5/28/17.
//  Copyright © 2017 Ricardo Chavarria. All rights reserved.
//

import Foundation

enum UPSEvent: String {
    case online = "ONLINE"                      // The UPS is back on line.
    case battery = "ONBATT"                     // The UPS is on battery.
    case batteryLow = "LOWBATT"                 // The UPS battery is low (as determined by the driver).
    case batteryReplacement = "REPLBATT"        // The UPS needs to have its battery replaced.
    case forcedShutdown = "FSD"                 // The UPS has been commanded into the "forced shutdown" mode.
    case communicationEstablished = "COMMOK"    // Communication with the UPS has been established.
    case communicationLost = "COMMBAD"          // Communication with the UPS was just lost.
    case communicationError = "NOCOMM"          // The UPS can’t be contacted for monitoring.
    case localshutdown = "SHUTDOWN"             // The local system is being shut down.
}

extension UPSEvent: CustomStringConvertible {
    var description: String {
        switch self {
        case .online:
            return "Online"
        
        case .battery:
            return "Battery Power"
            
        case .batteryLow:
            return "Low Battery"
            
        case .batteryReplacement:
            return "Replace Battery"
            
        case .forcedShutdown:
            return "Shut Down (Forced)"
            
        case .communicationEstablished:
            return "Communication OK"
            
        case .communicationLost:
            return "Communication Lost"
            
        case .communicationError:
            return "Communication Error"
            
        case .localshutdown:
            return "Shut Down"
        }
    }
}
