//
//  BattteryMonitorModel.swift
//  Moniteur de batteries
//
//  Created by Denis Blondeau on 2022-10-27.
//

import Foundation

final class BattteryMonitorModel: ObservableObject {
    
    @Published private(set) var currentLevels = ""
    
    private var mouseBatteryLevel = 0 {
        didSet {
            updateMenuBarExtraTitle()
        }
    }
    private var keyboardBatteryLevel = 0 {
        didSet {
            updateMenuBarExtraTitle()
        }
    }
    
    private var eventDetector = IOEventDetector()
    
    init() {
        eventDetector?.callbackQueue = DispatchQueue.global()
        handleEventCallback()
    }
    
    private func handleEventCallback() {
        
        eventDetector?.callback = {(detector, event, service) in
            print("Event \(event)")
            
            //TODO: Handle disconnected device
            if event == .Terminated {
                print("HANDLE DISCONNECTED DEVICE")
            }
            
            if event == .Matched {
                let productProperty = IORegistryEntryCreateCFProperty(service, "Product" as CFString, kCFAllocatorDefault, 0)
                if (productProperty != nil) {
                    let  productName = (productProperty?.takeRetainedValue() as? String)!
                    let   percent = (IORegistryEntryCreateCFProperty(service, "BatteryPercent" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Int)!
                    
                    if (productName == "Magic Mouse") {
                        if percent != self.mouseBatteryLevel {
                            DispatchQueue.main.async {
                                self.mouseBatteryLevel = percent
                            }
                        }
                    }
                    
                    if (productName == "Magic Keyboard with Touch ID and Numeric Keypad") {
                        if percent != self.keyboardBatteryLevel {
                            DispatchQueue.main.async {
                                self.keyboardBatteryLevel = percent
                            }
                        }
                    }
                    
                    print("\(productName): \(percent)")
                }
            }
        }
        
        _ = eventDetector?.startDetection()
    }
    
    private func updateMenuBarExtraTitle() {
        
        var keyboardBatterySymbol = ""
        var mouseBatterySymbol = ""
     
        
        switch keyboardBatteryLevel {
        case 0:
            keyboardBatterySymbol = SFSymbol.batteryLevel0.rawValue
        case 1...25:
            keyboardBatterySymbol = SFSymbol.batteryLevel25.rawValue
        case 26...50:
            keyboardBatterySymbol = SFSymbol.batteryLevel50.rawValue
        case 51...75:
            keyboardBatterySymbol = SFSymbol.batteryLevel75.rawValue
        default:
            keyboardBatterySymbol = SFSymbol.batteryLevel100.rawValue
        }
        
        switch mouseBatteryLevel {
        case 0:
            mouseBatterySymbol = SFSymbol.batteryLevel0.rawValue
        case 1...25:
            mouseBatterySymbol = SFSymbol.batteryLevel25.rawValue
        case 26...50:
            mouseBatterySymbol = SFSymbol.batteryLevel50.rawValue
        case 51...75:
            mouseBatterySymbol = SFSymbol.batteryLevel75.rawValue
        default:
            mouseBatterySymbol = SFSymbol.batteryLevel100.rawValue
        }
        
        currentLevels = "\(SFSymbol.keyboard.rawValue) \(keyboardBatteryLevel)% \(keyboardBatterySymbol)   \(SFSymbol.magicmouse.rawValue) \(mouseBatteryLevel)% \(mouseBatterySymbol)"
        
    }
    
    func invalidate() {
        eventDetector = nil
    }
}
