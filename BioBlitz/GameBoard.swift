//
//  GameBoard.swift
//  BioBlitz
//
//  Created by Zeljko Lucic on 21.10.23..
//

import SwiftUI

class GameBoard: ObservableObject {
    let rowCount: Int = 11
    let columnCount: Int = 22
    
    @Published var grid = [[Bacteria]]()
    
    @Published var currentPlayer: Color = .green
    @Published var greenScore: Int = 1
    @Published var redScore: Int = 1
    
    @Published var winner: String? = nil
    
    private var bacteriaBeingInfected: Int = 0
    
    init() {
        reset()
    }
    
    func reset() {
        winner = nil
        currentPlayer = .green
        greenScore = 1
        redScore = 1
        
        grid.removeAll()
        
        for row in 0..<rowCount {
            var newRow = [Bacteria]()
            for column in 0..<columnCount {
                let bacteria = Bacteria(row: row, column: column)
                
                if row <= rowCount / 2 {
                    if row == 0 && column == 0 {
                        // Make sure the player starts pointing away from anything
                        bacteria.direction = .north
                    } else if row == 0 && column == 1 {
                        // Make sure nothing points to the player
                        bacteria.direction = .east
                    } else if row == 1 && column == 0 {
                        // Make sure nothing points to the player
                        bacteria.direction = .south
                    } else {
                        // All others are random
                        bacteria.direction = Bacteria.Direction.allCases.randomElement()!
                    }
                } else {
                    // Mirror the counterpart
                    if let counterpartBacteria = getBacteria(atRow: rowCount - 1 - row, column: columnCount - 1 - column) {
                        bacteria.direction = counterpartBacteria.direction.opposite
                    }
                }
                
                newRow.append(bacteria)
            }
            grid.append(newRow)
        }
        
        grid[0][0].color = .green
        grid[rowCount - 1][columnCount - 1].color = .red
    }
    
    private func getBacteria(atRow row: Int, column: Int) -> Bacteria? {
        guard row >= 0 && row < grid.count && column >= 0 && column < grid[0].count else { return nil }
        
        return grid[row][column]
    }
    
    private func infect(from: Bacteria) {
        objectWillChange.send()
        
        // Direct
        var bacteriaToInfect = [Bacteria?]()
        switch from.direction {
        case .north:
            bacteriaToInfect.append(getBacteria(atRow: from.row - 1, column: from.column))
        case .south:
            bacteriaToInfect.append(getBacteria(atRow: from.row + 1, column: from.column))
        case .east:
            bacteriaToInfect.append(getBacteria(atRow: from.row, column: from.column + 1))
        case .west:
            bacteriaToInfect.append(getBacteria(atRow: from.row, column: from.column - 1))
        }
        
        // Indirect
        if let indirectBacteria = getBacteria(atRow: from.row - 1, column: from.column), indirectBacteria.direction == .south {
            bacteriaToInfect.append(indirectBacteria)
        }
        
        if let indirectBacteria = getBacteria(atRow: from.row + 1, column: from.column), indirectBacteria.direction == .north {
            bacteriaToInfect.append(indirectBacteria)
        }
        
        if let indirectBacteria = getBacteria(atRow: from.row, column: from.column - 1), indirectBacteria.direction == .east {
            bacteriaToInfect.append(indirectBacteria)
        }
        
        if let indirectBacteria = getBacteria(atRow: from.row, column: from.column + 1), indirectBacteria.direction == .west {
            bacteriaToInfect.append(indirectBacteria)
        }
        
        for case let bacteria? in bacteriaToInfect {
            if bacteria.color != from.color {
                bacteria.color = from.color
                bacteriaBeingInfected += 1
                
                Task { @MainActor in
                    try await Task.sleep(for: .milliseconds(50))
                    bacteriaBeingInfected -= 1
                    infect(from: bacteria)
                }
            }
        }
        
        updateScores() 
    }
    
    func rotate(bacteria: Bacteria) {
        guard bacteria.color == currentPlayer else { return }
        guard bacteriaBeingInfected == 0 else { return }
        guard winner == nil else { return }
        
        objectWillChange.send()
        
        bacteria.direction = bacteria.direction.next
        infect(from: bacteria)
        
    }
    
    private func changePlayer() {
        if currentPlayer == .green {
            currentPlayer = .red
        } else {
            currentPlayer = .green
        }
    }
    
    private func updateScores() {
        var newGreenScore = 0
        var newRedScore = 0
        
        for row in grid {
            for bacteria in row {
                if bacteria.color == .green {
                    newGreenScore += 1
                } else if bacteria.color == .red {
                    newRedScore += 1
                }
            }
        }
        
        greenScore = newGreenScore
        redScore = newRedScore
        
        if bacteriaBeingInfected == 0 {
            withAnimation(.spring()) {
                if redScore == 0 {
                    winner = "Green"
                } else if greenScore == 0 {
                    winner = "Red"
                } else {
                    changePlayer()
                }
            }
        }
    }
}
