//
//  ContentView.swift
//  Moniteur de batteries
//
//  Created by Denis Blondeau on 2022-10-26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var keyboardPercentageThreshold = 5.0
    @State private var keyboardNotificationEnabled = false
    @State private var mousePercentageThreshold = 5.0
    @State private var mouseNotificationEnabled = false
    
    
    var body: some View {
        
        
        VStack {
            Text("Notifications")
                .font(.title)
            Text("Niveau de batterie sous le % indiqué")
                .italic()
            
            Toggle("Clavier", isOn: $keyboardNotificationEnabled)
            
            Slider(
                value: $keyboardPercentageThreshold,
                in: 1...10,
                step: 1
            ) {
             
            } minimumValueLabel: {
                Text("1%")
            } maximumValueLabel: {
                Text("10%")
            } onEditingChanged: { editing in
                // keyboardIsEditing = editing
            }
            .disabled(!keyboardNotificationEnabled)
            
            Text("\(String(format: "%.f", keyboardPercentageThreshold))%")
                .foregroundColor(keyboardNotificationEnabled ? .green : .gray)
            
            Toggle("Souris", isOn: $mouseNotificationEnabled)
            
            Slider(
                value: $mousePercentageThreshold,
                in: 1...10,
                step: 1
            ) {
              
            } minimumValueLabel: {
                Text("1%")
            } maximumValueLabel: {
                Text("10%")
            } onEditingChanged: { editing in
                // keyboardIsEditing = editing
            }
            .disabled(!mouseNotificationEnabled)
            
            Text("\(String(format: "%.f", mousePercentageThreshold))%")
                .foregroundColor(mouseNotificationEnabled ? .green : .gray)
    
    
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
