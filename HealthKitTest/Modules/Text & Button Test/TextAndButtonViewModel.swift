//
//  TextAndButtonViewModel.swift
//  HealthKitTest
//
//  Created by Arseniy Khaladok on 4/15/21.
//

import Foundation

class TextAndButtonViewModel: ObservableObject {
    
    @Published var textToChange: String = ""
    
    func changeText(length: Int) {
        let letters = "abcdefghijklmnopqrstuvwxyz"
        let randomString = String((0..<length)
                                    .map{ _ in
                                        letters.randomElement()!
                                    })
        textToChange = randomString
    }
}
