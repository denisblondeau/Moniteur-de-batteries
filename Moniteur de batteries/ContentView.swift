//
//  ContentView.swift
//  Moniteur de batteries
//
//  Created by Denis Blondeau on 2022-10-26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("keyboardThreshold") private var keyboardPercentageThreshold = 10.0
    @AppStorage("keyboardEnabled") private var keyboardNotificationEnabled = false
    @AppStorage("mouseThreshold") private var mousePercentageThreshold = 10.0
    @AppStorage("mouseEnabled") private var mouseNotificationEnabled = false
    @EnvironmentObject private var model: BattteryMonitorModel
    
    var body: some View {
        
        VStack {
            if !model.localNotifications.authorized {
                Text("Les notifications ne sont pas autorisées.")
            } else {
                Text("Notifications")
                    .font(.title)
                Text("Niveau de batterie sous le % indiqué")
                    .italic()
                
                Toggle("Clavier", isOn: $keyboardNotificationEnabled)
                
                Slider(
                    value: $keyboardPercentageThreshold,
                    in: 1...20,
                    step: 1
                ) {
                    
                } minimumValueLabel: {
                    Text("1%")
                } maximumValueLabel: {
                    Text("20%")
                } onEditingChanged: { editing in
                    // keyboardIsEditing = editing
                }
                .disabled(!keyboardNotificationEnabled)
                
                Text("\(String(format: "%.f", keyboardPercentageThreshold))%")
                    .foregroundColor(keyboardNotificationEnabled ? .green : .gray)
                
                Divider()
                
                Toggle("Souris", isOn: $mouseNotificationEnabled)
                
                Slider(
                    value: $mousePercentageThreshold,
                    in: 1...20,
                    step: 1
                ) {
                    
                } minimumValueLabel: {
                    Text("1%")
                } maximumValueLabel: {
                    Text("20%")
                }
                .disabled(!mouseNotificationEnabled)
                
                Text("\(String(format: "%.f", mousePercentageThreshold))%")
                    .foregroundColor(mouseNotificationEnabled ? .green : .gray)
                
            }
        }
        .padding()
        .onChange(of: model.localNotifications.authorized) { authorized in
            if !authorized {
                keyboardNotificationEnabled = false
                mouseNotificationEnabled = false
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
