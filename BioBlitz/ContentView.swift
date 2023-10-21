//
//  ContentView.swift
//  BioBlitz
//
//  Created by Zeljko Lucic on 21.10.23..
//

import SwiftUI

struct ContentView: View {
    @StateObject private var board = GameBoard()
    
    var body: some View {
        VStack {
            HStack {
                Text("GREEN: 0")
                Spacer()
                Text("BIOBLITZ")
                Spacer()
                Text("RED: 0")
            }
            .font(.system(size: 36, weight: .black))
            VStack {
                ForEach(0..<11, id: \.self) { row in
                    HStack {
                        ForEach(0..<22, id: \.self) { column in
                            let bacteria = board.grid[row][column]
                            BacteriaView(bacteria: bacteria) {
                                board.rotate(bacteria: bacteria)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .fixedSize()
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
