//
//  ExampleTableViewModel.swift
//  HealthKitTest
//
//  Created by Arseniy Khaladok on 4/15/21.
//

import Foundation

class ExampleTableViewModel: ObservableObject {

    @Published private(set) var incomeArray = ["111", "222", "333", "444", "555", "666","777","888","999","000"]
    
    func addItem() {
        incomeArray.append("added test string")
    }
    
    func removeItem(index: Int) {
        incomeArray.remove(at: index)
    }
}
