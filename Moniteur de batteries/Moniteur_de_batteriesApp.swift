//
//  Moniteur_de_batteriesApp.swift
//  Moniteur de batteries
//
//  Created by Denis Blondeau on 2022-10-26.
//

import SwiftUI

@main
struct Moniteur_de_batteriesApp: App {
    
    @StateObject private var model = BattteryMonitorModel()
    
    var body: some Scene {
        
        MenuBarExtra(model.currentLevels) {
            
            ContentView()
            
            Divider()
            
            Button("Quitter") {
                model.invalidate()
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
            .padding()
            
          
        }
        .menuBarExtraStyle(.window)
    }
}
