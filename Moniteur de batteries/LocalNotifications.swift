//
//  LocalNotifications.swift
//  Moniteur de batteries
//
//  Created by Denis Blondeau on 2022-10-28.
//


import UserNotifications

@MainActor
final class LocalNotifications: NSObject, ObservableObject {
    
    @Published var authorized = false
    
    private let center = UNUserNotificationCenter.current()
    
    func requestAuthorization() async throws {
      authorized = try await center.requestAuthorization(options: [.badge, .sound, .alert])
    }
}
