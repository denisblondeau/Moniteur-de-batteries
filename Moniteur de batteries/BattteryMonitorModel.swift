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
    private let defaults = UserDefaults.standard
    private var keyboardBatteryLevel = 0 {
        didSet {
            updateMenuBarExtraTitle()
        }
    }
    private(set) var localNotifications: LocalNotifications!
    private var mouseBatteryLevel = 0 {
        didSet {
            updateMenuBarExtraTitle()
        }
    }
  
    private var refreshLevelsTimer: AnyCancellable?
    
    init() {
        Task {
            await localNotifications = LocalNotifications()
            try? await localNotifications.requestAuthorization()
            await retrieveData()
            await setLocalNotifications()
        }
        
        // Refresh data every 15 mins.
        refreshLevelsTimer = Timer.publish(every: 900, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: {_ in
                Task {
                    await self.retrieveData()
                    await self.setLocalNotifications()
                }
            })
    }
    
    func invalidate() {
        refreshLevelsTimer?.cancel()
    }
    
    private func retrieveData() async {
        var serialPortIterator = io_iterator_t()
        var object: io_service_t = 0
        let matchingDict : CFDictionary = IOServiceMatching("AppleDeviceManagementHIDEventService")
        let kernResult = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict, &serialPortIterator)
        
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
                                keyboardBatteryLevel = percent
                            }
                            
                            if (productName == "Magic Mouse") {
                                mouseBatteryLevel = percent
                                
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
        
        DispatchQueue.main.async {
            self.currentLevels = "\(SFSymbol.keyboard.rawValue) \(self.keyboardBatteryLevel)% \(keyboardBatterySymbol)   \(SFSymbol.magicmouse.rawValue) \(self.mouseBatteryLevel)% \(mouseBatterySymbol)"
        }
    }
    
    private func setLocalNotifications() async {
        let keyboardPercentageThreshold = Int(defaults.double(forKey: "keyboardThreshold"))
        let keyboardNotificationEnabled = defaults.bool(forKey: "keyboardEnabled")
        let mousePercentageThreshold = Int(defaults.double(forKey: "mouseThreshold"))
        let mouseNotificationEnabled = defaults.bool(forKey: "mouseEnabled")
        let fields = CommonFieldsModel()
     
        if keyboardNotificationEnabled  {
            if keyboardBatteryLevel < keyboardPercentageThreshold {
                fields.title = "Le niveau de la batterie du clavier est sous \(keyboardPercentageThreshold)% - La notification pour le clavier est maintenant désactivée."
                defaults.set(false, forKey: "keyboardEnabled")
                Task {
                    do {
                        try await localNotifications.sendNotification(model: fields)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
        if mouseNotificationEnabled  {
            if mouseBatteryLevel < mousePercentageThreshold {
                fields.title = "Le niveau de la batterie de la souris est sous \(keyboardPercentageThreshold)% - La notification pour la souris est maintenant désactivée."
                defaults.set(false, forKey: "mouseEnabled")
                Task {
                    do {
                        try await localNotifications.sendNotification(model: fields)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
        if (keyboardBatteryLevel == 100) && !keyboardNotificationEnabled {
            fields.title = "Le niveau de la batterie du clavier est maintenant à 100% - Veuillez réactiver la notification pour le clavier."
            Task {
                do {
                    try await localNotifications.sendNotification(model: fields)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        if (mouseBatteryLevel == 100) && !mouseNotificationEnabled {
            fields.title = "Le niveau de la batterie de la souris est maintenant à 100% - Veuillez réactiver la notification pour la souris."
            Task {
                do {
                    try await localNotifications.sendNotification(model: fields)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        
        
        
        
    }
    
}
