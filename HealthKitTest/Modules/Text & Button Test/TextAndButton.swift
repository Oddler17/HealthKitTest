//
//  TextAndButton.swift
//  HealthKitTest
//
//  Created by Arseniy Khaladok on 4/15/21.
//

import SwiftUI

struct TextAndButton: View {
    
    @State var name: String = ""
    @ObservedObject private var viewModel: TextAndButtonViewModel = TextAndButtonViewModel()
    
    var body: some View {
        Form {
            TextField("Name", text: $name)
            Button(action: {
                // Do nothing for now
            }, label: {
                Text("Save")
            }).disabled(name.isEmpty)
        }
        Spacer()
        Form {
            TextField("Name", text: $viewModel.textToChange)
            Button(action: {
                viewModel.changeText(length: 7)
            }, label: {
                Text("Change Text")
            })
        }
    }
}

struct TextAndButton_Previews: PreviewProvider {
    static var previews: some View {
        TextAndButton()
    }
}
