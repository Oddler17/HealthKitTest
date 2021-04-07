//
//  ViewModel.swift
//  HealthKitTest
//
//  Created by Arseniy Oddler on 4/5/21.
//

import Foundation
import Combine
import SwiftUI
import HealthKit

class ViewModel: ObservableObject { // Gives opportunity to react on changes of @Published property of this object

//    @Published private(set) var customers: [ZCustomer] = []
    //TEST
    @Published var customers: [ZCustomer] = [ZCustomer(id: UUID(), name: "Alex", phone: "234111"),
                                             ZCustomer(id: UUID(), name: "Andrew", phone: "2342324"),
                                             ZCustomer(id: UUID(), name: "John", phone: "76575") ]

    var cancellables = [AnyCancellable]()

    @Environment(\.managedObjectContext) var context
    
    init() {
        getTodaysSteps { steps in
            print(steps)
        }
        
        getHeartRateFromTomorrowMorning { heartRateArray in
            print(heartRateArray)
        }

        getStepsPerDayForMonth { stepsArray in
            print(stepsArray)
        }
        
        print("Blood type: \(getBloodType())")
        print("Age: \(getAge())")
    }
    
    func fetchData() {
        CoreDataFetchResultsPublisher(request: Customer.fetchRequest(), context: context)
            .receive(on: DispatchQueue.main)
            .replaceError(with: [])
            .map { $0.map { ZCustomer(id: $0.id!, name: $0.name!, phone: $0.phone!)} }
            .sink { [weak self] newCustomers in
                self?.customers = newCustomers
            }
            .store(in: &cancellables)
    }
    
    //MARK: - Health Kit (TODO: - Create Helper for it)
    private let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        } else {
            return nil
        }
    }()
    
    func getTodaysSteps(completion: @escaping (Double) -> Void) {
        guard let healthStore = self.healthStore else {
            return
        }
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        healthStore.requestAuthorization(toShare: Set([stepsQuantityType]), read: Set([stepsQuantityType])) { success, error in
            if success {
                let now = Date()
                let startOfDay = Calendar.current.startOfDay(for: now)
                let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
                let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, result, error in
                    guard let result = result, let sum = result.sumQuantity() else {
                        completion(0.0)
                        return
                    }
                    completion(sum.doubleValue(for: HKUnit.count()))
                }
                healthStore.execute(query)
            }
        }
    }
    
    func getStepsPerDayForMonth(completion: @escaping ([Double]) -> Void) {
        guard let healthStore = self.healthStore else {
            return
        }
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        healthStore.requestAuthorization(toShare: Set([stepsQuantityType]), read: Set([stepsQuantityType])) { success, error in
            if success {
                // Time interval
                let calendar = NSCalendar.current
                let interval = NSDateComponents()
                interval.day = 1
                
                // Start and end dates
                let endDate = Date()
                let startDay = calendar.date(byAdding: .month, value: -1, to: endDate)
                guard let start = startDay, let startDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: start) else { // Start at midnight
                    fatalError("Unable to calculate the start date")
                }
                
                // Type
                guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
                    fatalError("Unable to create a step count type")
                }
                
                let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: nil, options: .cumulativeSum, anchorDate: startDate, intervalComponents: interval as DateComponents)
                
                query.initialResultsHandler = { query, results, error in
                    guard let results = results else {
                        fatalError("An error occurred while calculating the statistics: \(String(describing: error?.localizedDescription))")
                    }
                    
                    var arrayOfDays: [Double] = []
                    results.enumerateStatistics(from: startDate, to: endDate, with: { result, stop in
                        let totalStepForADay = result.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                        arrayOfDays.append(totalStepForADay)
                    })
                    completion(arrayOfDays)
                }
                healthStore.execute(query)
            }
        }
    }
    
    func getHeartRateFromTomorrowMorning(completion: @escaping ([Double]) -> Void) {
        guard let healthStore = self.healthStore else {
            return
        }
        let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate)!
        healthStore.requestAuthorization(toShare: Set([heartRate]), read: Set([heartRate])) { success, error in
            if success {
                // Time interval
                let calendar = NSCalendar.current
                let interval = NSDateComponents()
                interval.minute = 30
                
                // Start and end dates
                let endDate = Date()
                let startDay = calendar.date(byAdding: .day, value: -1, to: endDate)
                guard let start = startDay, let startDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: start) else { // Start at midnight
                    fatalError("Unable to calculate the start date")
                }
                
                guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
                    fatalError("Unable to create a step count type")
                }
                
                let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: nil, options: .discreteAverage, anchorDate: startDate, intervalComponents: interval as DateComponents)
                
                query.initialResultsHandler = { query, results, error in
                    guard let statsCollection = results else {
                        fatalError("An error occurred while calculating the statistics: \(String(describing: error?.localizedDescription))")
                    }
                    if statsCollection.statistics().isEmpty {
                        print("No Heart data found")
                    }
                    var arrayOfHours: [Double] = []
                    statsCollection.enumerateStatistics(from: startDate, to: endDate) { results, stop in
                        let quantity = results.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())) ?? 0
                        arrayOfHours.append(quantity)
                    }
                    completion(arrayOfHours)
                }
                healthStore.execute(query)
            }
        }
    }
    
    private func getAge() -> Int {
        let defaultAge = 0
        guard let healthStore = self.healthStore else {
            return defaultAge
        }
        var birthComponents = DateComponents()
        do {
            birthComponents = try healthStore.dateOfBirthComponents()
        } catch {
            print("ERROR: Can't get birth date")
        }
        let now = Date()
        let birthdayDate = birthComponents.date ?? Date()
        
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthdayDate, to: now)
        return ageComponents.year ?? defaultAge
    }
    
    private func getBloodType() -> String {
        var bloodType = "N/A"
        guard let healthStore = self.healthStore else {
            return bloodType
        }
        do {
            bloodType = try healthStore.bloodType().string()
        } catch {
            print("ERROR: Can't get bloodType")
        }
        return bloodType
    }
}

extension HKBloodTypeObject {
    func string() -> String {
        switch self.bloodType {
        case .abNegative:
            return "AB-"
        case .abPositive:
            return "AB+"
        case .aNegative:
            return "A-"
        case .aPositive:
            return "A+"
        case .bNegative:
            return "B-"
        case .bPositive:
            return "B+"
        case .oNegative:
            return "O-"
        case .oPositive:
            return "O+"
        default:
            return "Not Set"
        }
    }
}

//let energyBurned = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
//let distanceCycling = HKObjectType.quantityType(forIdentifier: .distanceCycling)
//let distanceWalking = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)
//let workout = HKObjectType.workoutType()
