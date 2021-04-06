//
//  ViewModel.swift
//  HealthKitTest
//
//  Created by Arseniy  Oddler on 4/5/21.
//

import Foundation
import Combine
import SwiftUI

class ViewModel: ObservableObject { // Gives opportunity to react on changes of @Published property of this object
    @Published private(set) var customers: [ZCustomer] = []

    var cancellables = [AnyCancellable]()

    @Environment(\.managedObjectContext) var context
    
    init() {
        CoreDataFetchResultsPublisher(request: Customer.fetchRequest(), context: context)
            .receive(on: DispatchQueue.main)
            .replaceError(with: [])
            .map { $0.map { ZCustomer(id: $0.id!, name: $0.name!, phone: $0.phone!)} }
            .sink { [weak self] newCustomers in
                self?.customers = newCustomers
            }
            .store(in: &cancellables)
        
        
        
//        CDPublisher(request: Customer.fetchRequest(), context: context)
//            .map { $0.map { ZCustomer(id: $0.id!, name: $0.name!, phone: $0.phone!)} }
//            .receive(on: DispatchQueue.main)
//            .replaceError(with: [])
//            .sink { [weak self] newCustomers in
//                self?.customers = newCustomers // binding of @published property to the publisher - publisher updates it
//            }
//            .store(in: &cancellables)
    }
}
