//
//  CountStepper.swift
//  InventoryDemo
//
//  Created by Andrew Morgan on 21/04/2021.
//

import SwiftUI

struct CountStepper: View {
    let label: String
    @Binding var value: Int
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("\(label): \(value)")
                    .foregroundColor(.secondary)
            }
            Stepper(value: $value, in: 0...10000) {}
        }
    }
}

struct BindingView: View {
    @State var value: Int
    
    var body: some View {
        CountStepper(label: "Qty", value: $value)
    }
}

struct CountStepper_Previews: PreviewProvider {
    static var previews: some View {
        BindingView(value: 7)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
