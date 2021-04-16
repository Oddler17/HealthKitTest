//
//  ExampleTable.swift
//  HealthKitTest
//
//  Created by Arseniy Khaladok on 4/15/21.
//

import SwiftUI

struct ExampleTable: View {
    
    @ObservedObject private var viewModel: ExampleTableViewModel = ExampleTableViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(0..<viewModel.incomeArray.count, id: \.self) { item -> SampleRow in
                    let row = SampleRow(id: viewModel.incomeArray[item]) {
                        viewModel.removeItem(index: item)
                    }
                    return row
                }
            }
        }
        .frame(height: 300)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("+") {
                    viewModel.addItem()
                }
            }
        }
    }
}

struct SampleRow: View {
    let id: String
    var buttonAction: () -> Void

    var body: some View {
        Text("Row " + id)
        Button(action: buttonAction) {
            Text("delete")
        }
    }

    init(id: String, buttonAction: @escaping () -> Void) {
        self.id = id
        self.buttonAction = buttonAction
    }
}
