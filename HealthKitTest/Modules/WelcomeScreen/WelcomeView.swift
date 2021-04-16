//
//  WelcomeView.swift
//  HealthKitTest
//
//  Created by Arseniy Khaladok on 4/13/21.
//

import SwiftUI
import HealthKit

fileprivate struct Constants {
    static var localNotificationsAcceptedKey = "LocalNotificationsAcceptedKey"
}

struct WelcomeView: View {
    @State private var needToShowLocalNotificationsAlert = false
    
    private let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        } else {
            return nil
        }
    }()
    
    var body: some View {
        NavigationView {
        VStack {
            Text("Welcome")
                .fontWeight(.heavy)
                .font(.system(size: 40))
                .frame(width: 300, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 0) {
                NewDetail(image: "heart.fill", imageColor: .pink, title: "Local Notifications", description: "Show local notifications dialogue. Alrert if it was setup.",
                          buttonAction: {
                            showLocalNotificationsDialogIfNeeded()
                          }).alert(isPresented: $needToShowLocalNotificationsAlert) {
                            Alert(title: Text("Local notifications already accepted"), message: Text(""), dismissButton: .default(Text("Got it!")))
                        }
                NewDetail(image: "paperclip", imageColor: .green, title: "HealthKit", description: "Shows HealthKit authorization dialogue.",
                          buttonAction: {
                            showHealthKitAccessDialog()
                          })
                ZStack(alignment: .leading) {
                    NewDetail(image: "play.rectangle.fill", imageColor: .blue, title: "HealthKit Test", description: "Testing of the HealthKit. And CoreData. Change it.", buttonAction: {})
                    NavigationLink(destination: ContentView()) {
                        Text("")
                            .frame(minWidth: 340)
                            .frame(minHeight: 100)
                    }
                    .background(Color.clear)
                }
                
                ZStack(alignment: .leading) {
                    NewDetail(image: "paperclip", imageColor: .red, title: "VStack Test", description: "Combine - LazyVStack with adding and deleting elements.",
                              buttonAction: {})
                    NavigationLink(destination: ExampleTable()) {
                        Text("")
                            .frame(minWidth: 340)
                            .frame(minHeight: 100)
                    }
                }
                ZStack(alignment: .leading) {
                    NewDetail(image: "play.rectangle.fill", imageColor: .yellow, title: "Text & Button", description: "Combine - Different ways to bind text and button.",
                              buttonAction: {})
                    NavigationLink(destination: TextAndButton()) {
                        Text("")
                            .frame(minWidth: 340)
                            .frame(minHeight: 100)
                    }
                }
            }
            Spacer()
        }
        }
    }
    
    private func showLocalNotificationsDialogIfNeeded() {
        if UserDefaults.standard.bool(forKey: Constants.localNotificationsAcceptedKey) {
            needToShowLocalNotificationsAlert = true
            return
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
            success, _ in
            if success {
                UserDefaults.standard.set(true, forKey: Constants.localNotificationsAcceptedKey)
            } else {
                UserDefaults.standard.set(false, forKey: Constants.localNotificationsAcceptedKey)
            }
        }
    }
    
    private func showHealthKitAccessDialog() {
        let allTypes = Set([HKObjectType.workoutType(),
                            HKObjectType.quantityType(forIdentifier: .stepCount)!,
                            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                            HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
                            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                            HKObjectType.quantityType(forIdentifier: .heartRate)!])

        healthStore?.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
            if !success {
                // Handle the error here.
            }
        }
    }

    struct NewDetail: View {
        var image: String
        var imageColor: Color
        var title: String
        var description: String
        var buttonAction: () -> Void

        var body: some View {
            ZStack(alignment: .leading) {
                HStack(alignment: .center) {
                    HStack {
                        Image(systemName: image)
                            .font(.system(size: 50))
                            .frame(width: 50)
                            .foregroundColor(imageColor)
                            .padding()

                        VStack(alignment: .leading) {
                            Text(title).bold()
                        
                            Text(description)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(2)
                        }
                    }.frame(width: 340, height: 100)
                    
                }
                Button(action: buttonAction) {
                    Text("")
                        .frame(minWidth: 340)
                        .frame(minHeight: 100)
                }
                .background(Color.clear)
            }
        }
    }
}


// MARK: - Previews
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
