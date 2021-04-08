//
//  ContentView.swift
//  HealthKitTest
//
//  Created by Arseniy Oddler on 4/5/21.
//

import SwiftUI
import CoreData
import Combine

struct ContentView: View {
    
    @Environment(\.managedObjectContext) var context
    @ObservedObject private var viewModel: ViewModel = ViewModel() // @ObservedObject - we can react on it's changes
    private var cancellable: AnyCancellable?
    let dbManager = DataBaseManager()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.customers, id: \.self.id) { customer in
                    Text("\(customer.id): \(customer.name))")
                }
            }
            .onAppear {
                update()
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("ADD") {
                        addItem()
                    }
                    Button("UPD") {
                        update()
                    }
                }
            }
        }
    }
    
    private func addItem() {
        viewModel.addItem(context)
    }
    
    private func update() {
        viewModel.fetchData(context)
    }
}
