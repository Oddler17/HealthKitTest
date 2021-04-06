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
    @Published private(set) var customers: [ZCustomer] = []

    var cancellables = [AnyCancellable]()

    @Environment(\.managedObjectContext) var context
    
    init() {
        fetchHealthData()
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
    
    //MARK: - Health Kit
    private let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        } else {
            return nil
        }
    }()
    
    func fetchHealthData() {
        guard let healthStore = self.healthStore else {
            return
        }
        
        let stepsCount = HKObjectType.quantityType(forIdentifier: .stepCount)
        let energyBurned = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
        let distanceCycling = HKObjectType.quantityType(forIdentifier: .distanceCycling)
        let distanceWalking = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)
        let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate)
        let workout = HKObjectType.workoutType()
        
        let healthKitTypes = Set([stepsCount!, energyBurned!, distanceCycling!, distanceWalking!, heartRate!, workout])
        
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { success, error in
            if success {
                let calendar = NSCalendar.current
                var anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: NSDate() as Date)
                let offset = (7 + anchorComponents.weekday! - 2) % 7
                anchorComponents.day! -= offset
                anchorComponents.hour = 2
                guard let anchorDate = Calendar.current.date(from: anchorComponents) else {
                    fatalError("Unable to create a valid date from the given components")
                }
                let interval = NSDateComponents()
                interval.minute = 30
                let endDate = Date()
                guard let startDate = calendar.date(byAdding: .month, value: -1, to: endDate) else {
                    fatalError("Unable to calculate the start date")
                }
                
                guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
                    fatalError("Unable to create a step count type")
                }
                
                let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                        quantitySamplePredicate: nil,
                                                        options: .discreteAverage,
                                                        anchorDate: anchorDate,
                                                        intervalComponents: interval as DateComponents)
                
                query.initialResultsHandler = { query, results, error in
                    guard let statsCollection = results else {
                        fatalError("An error occurred while calculating the statistics: \(String(describing: error?.localizedDescription))")
                    }
                    
                    statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                        if let quantity = statistics.averageQuantity() {
                            let date = statistics.startDate
                            // for steps it's HKUnit.count()
                            let value = quantity.doubleValue(for: HKUnit(from: "count/min"))
                            print("done")
                            print(value)
                            print(date)
                        }
                    }
                }
                healthStore.execute(query)
            } else {
                print("Authorization failed")
            }
        }
        
    }
    
}
