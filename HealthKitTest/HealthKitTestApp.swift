//
//  HealthKitTestApp.swift
//  HealthKitTest
//
//  Created by Arseniy Oddler on 4/5/21.
//

import SwiftUI

@main
struct HealthKitTestApp: App {
    let persistenceController = PersistenceController.shared
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }.onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}
