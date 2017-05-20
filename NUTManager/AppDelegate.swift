//
//  AppDelegate.swift
//  NUTManager
//
//  Created by Ricardo Chavarria on 5/13/17.
//  Copyright © 2017 Ricardo Chavarria. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    enum NotifyEvent: String {
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
    
    @IBOutlet var appMenu: NSMenu!
    @IBOutlet weak var statusMenu: NSMenuItem!
    @IBOutlet weak var configureMenu: NSMenuItem!
    @IBOutlet weak var quitMenu: NSMenuItem!
    private let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    private var taskPID: Int32?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        statusItem.menu = appMenu
        statusItem.image = #imageLiteral(resourceName: "iconmonstr-battery-configure")
        statusItem.alternateImage = #imageLiteral(resourceName: "iconmonstr-battery-configure-white")
        
        NSWorkspace.shared().runningApplications.forEach {
            print("Name \($0.localizedName!)")
        }
        
        // 1. Check if upsmon is running and kill it
        // 2. Check for /opt/local/etc/upsmon.conf
        // 3. Add at least one MONITOR entry
        // # MONITOR <system> <powervalue> <username> <password> ("master"|"slave")
        
        let taskQueue = DispatchQueue.global(qos: .background)
        taskQueue.async { [weak self] in
            
            Thread.sleep(forTimeInterval: 2.0)
            
            let outputPipe = Pipe()
            
            let task = Process()
            task.launchPath = "/opt/local/sbin/upsmon"
            task.terminationHandler = { task in
                
                print("Terminated PID \(task.processIdentifier) - Reason: \(task.terminationReason) - Status: \(task.terminationStatus)")
                
                DispatchQueue.main.async {
                    self?.statusMenu.title = "Not Running"
                }
            }
            task.standardOutput = outputPipe
            
            outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            
            // 4. Monitor upsmon output
            NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading, queue: nil) { _ in
                
                guard let output = String(data: outputPipe.fileHandleForReading.availableData, encoding: String.Encoding.utf8) else { return }
                
                print("Output \(output)")
                
                outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
                
                guard let status = NotifyEvent(rawValue: output) else { return }
                
                DispatchQueue.main.async {
                    // Update menu status
                    self?.statusMenu.title = "Running: \(status)"
                }
            }
            
            // 5. Launch upsmon
            task.launch()
            
            self?.taskPID = task.processIdentifier
            
            print("Running with PID: \(task.processIdentifier) - Running: \(task.isRunning)")
            
            DispatchQueue.main.async {
                self?.statusMenu.title = "Running"
            }
            
            task.waitUntilExit()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


    @IBAction func quitClicked(_ sender: Any) {
        NSApplication.shared().terminate(self)
    }
}

