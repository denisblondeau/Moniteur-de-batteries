//
//  BattteryMonitorModel.swift
//  Moniteur de batteries
//
//  Created by Denis Blondeau on 2022-10-27.
//

import Combine
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
    
    private var refreshLevelsTimer: AnyCancellable?
    
    init() {
        retrieveData()
        
        // Refresh data every 15 mins.
        refreshLevelsTimer = Timer.publish(every: 900, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: {_ in
                self.retrieveData()
            })
    }
    
    func invalidate() {
        refreshLevelsTimer?.cancel()
    }
    
    private func retrieveData() {
        var serialPortIterator = io_iterator_t()
        var object: io_service_t = 99
        let masterPort: mach_port_t = kIOMainPortDefault
        let matchingDict : CFDictionary = IOServiceMatching("AppleDeviceManagementHIDEventService")
        let kernResult = IOServiceGetMatchingServices(masterPort, matchingDict, &serialPortIterator)
        
        if KERN_SUCCESS == kernResult {
           repeat {
                object = IOIteratorNext(serialPortIterator)
                
                if object != 0 {
                    
                    var percent = 0
                    var productName = ""
                    if let productProperty = IORegistryEntryCreateCFProperty(object, "Product" as CFString, kCFAllocatorDefault, 0) {
                        productName =  productProperty.takeRetainedValue() as! String
                        
                        if let percentProperty = IORegistryEntryCreateCFProperty(object, "BatteryPercent" as CFString, kCFAllocatorDefault, 0) {
                            percent = percentProperty.takeRetainedValue() as! Int
                            
                            if productName == "Magic Keyboard with Touch ID and Numeric Keypad" {
                                DispatchQueue.main.async {
                                    self.keyboardBatteryLevel = percent
                                }
                            }
                            
                            if (productName == "Magic Mouse") {
                                DispatchQueue.main.async {
                                    self.mouseBatteryLevel = percent
                                }
                            }
                        }
                    }
                    IOObjectRelease(object)
                } else {
                    break
                }
               
            } while true
         
        }
        IOObjectRelease(serialPortIterator)
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
    
}
