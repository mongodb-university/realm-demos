//
//  CaptionLabel.swift
//  InventoryDemo
//
//  Created by Andrew Morgan on 21/04/2021.
//

import SwiftUI

struct CaptionLabel: View {
    let title: String
    
    private let lineLimit = 5

    var body: some View {
        HStack {
            Text(LocalizedStringKey(title))
                .font(.caption)
                .lineLimit(lineLimit)
                .multilineTextAlignment(.leading)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

struct CaptionLabel_Previews: PreviewProvider {
    static var previews: some View {
        CaptionLabel(title: "Title")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
