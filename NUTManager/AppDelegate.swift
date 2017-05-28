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
    
    @IBOutlet var appMenu: NSMenu!
    @IBOutlet weak var statusMenu: NSMenuItem!
    @IBOutlet weak var configureMenu: NSMenuItem!
    @IBOutlet weak var quitMenu: NSMenuItem!
    private let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        statusItem.menu = appMenu
        statusItem.image = #imageLiteral(resourceName: "iconmonstr-battery-configure")
        statusItem.alternateImage = #imageLiteral(resourceName: "iconmonstr-battery-configure-white")
        
        // 1. Check if upsmon is running
        let result = runCommand(cmd: "/usr/bin/top", args: "-l", "1", "-ncols", "2")
        if result.output.contains(where: ({ $0.contains("upsmon") }) ) == false {
            
            // 1.a. Check for /opt/local/etc/upsmon.conf, add at least one MONITOR entry
            // # MONITOR <system> <powervalue> <username> <password> ("master"|"slave")
            
            // 1.b. Run upsmon
            let task = Process()
            task.launchPath = "/opt/local/sbin/upsmon"
            task.launch()
        }
    
        let center = CFNotificationCenterGetDistributedCenter()
        let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        let callback: CoreFoundation.CFNotificationCallback = { (center, observer, notificationName, _, info) in
            
            guard let observer = observer, let info = info, let notificationName = notificationName?.rawValue else { return }
            if notificationName as String == "nutmanager.notification" {
            
                guard let info = info as? [String: [String]], let notifications: [String] = info["notifications"] else { return }
                
                    let strongSelf = Unmanaged<AppDelegate>.fromOpaque(observer).takeUnretainedValue()
                    notifications.forEach { name in
                        guard let event = UPSEvent(rawValue: name) else { return }
                        strongSelf.updateStatus(with: event)
                    }
            }
        }
        
        let notificationName: CFString = NSString(string: "nutmanager.notification")
        CFNotificationCenterAddObserver(center, observer, callback, notificationName, nil, .deliverImmediately)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func quitClicked(_ sender: Any) {
        NSApplication.shared().terminate(self)
    }
    
    func updateStatus(with event: UPSEvent) {
        DispatchQueue.main.async { [weak self] in
            self?.statusMenu.title = event.description
        }
    }
    
    func runCommand(cmd : String, args : String...) -> (exitCode: Int32, output: [String], error: [String]) {
        
        let task = Process()
        task.launchPath = cmd
        task.arguments = args
        
        let outpipe = Pipe()
        task.standardOutput = outpipe
        let errpipe = Pipe()
        task.standardError = errpipe
        
        task.launch()
        
        let outputString = String(data: outpipe.fileHandleForReading.readDataToEndOfFile(), encoding: String.Encoding.utf8)
        let output = (outputString != nil) ? outputString!.components(separatedBy: "\n") : [String]()
        
        let errorString = String(data: errpipe.fileHandleForReading.readDataToEndOfFile(), encoding: String.Encoding.utf8)
        let error = (errorString != nil) ? errorString!.components(separatedBy: "\n") : [String]()
        
        let status = task.terminationStatus
        
        return (status, output, error)
    }
}

