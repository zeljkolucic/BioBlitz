//
//  BacteriaView.swift
//  BioBlitz
//
//  Created by Zeljko Lucic on 21.10.23..
//

import SwiftUI

struct BacteriaView: View {
    var bacteria: Bacteria
    var rotationAction: () -> Void
    
    var imageName: String {
        switch bacteria.color {
        case .red:
            return "chevron.up.square.fill"
        case .green:
            return "chevron.up.circle.fill"
        default:
            return "chevron.up.circle"
        }
    }
    
    var body: some View {
        ZStack {
            Button(action: rotationAction) {
                Image(systemName: imageName)
                    .resizable() // Normally, you wouldn't use .resizable() modifier with SFSymbols becase it warps them
                    .foregroundColor(bacteria.color)
            }
            .buttonStyle(.plain)
            .frame(width: 32, height: 32)
            Rectangle()
                .fill(bacteria.color)
                .frame(width: 3, height: 8)
                .offset(y: -20)
        }
        .rotationEffect(.degrees(bacteria.direction.rotation))
    }
}

#Preview {
    BacteriaView(bacteria: Bacteria(row: 0, column: 0), rotationAction: { })
}
