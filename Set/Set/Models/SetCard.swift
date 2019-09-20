//
//  File.swift
//  Set
//
//  Created by Rhett Hanscom on 6/2/19.
//  Copyright © 2019 Ariadne Project. All rights reserved.
//

import Foundation

struct SetCard: Hashable {

//    var hashValue: Int {
//        return Int("\(combination.number.rawValue)\(combination.color.rawValue)\(combination.symbol.rawValue)\(combination.shading.rawValue)")!
//    }
//
    //MORE MODERN HASH FUNC
    func hash(into hasher: inout Hasher){
        hasher.combine(combination.number.rawValue)
        hasher.combine(combination.color.rawValue)
        hasher.combine(combination.symbol.rawValue)
        hasher.combine(combination.shading.rawValue)
    }
    
    //EQUATABLE PROTOCOL
    static func == (lhs: SetCard, rhs: SetCard) -> Bool {
        return lhs.combination == rhs.combination
    }
    
    
    private(set) var combination: FeatureCombination
    
    init(combination: FeatureCombination){
        self.combination = combination
    }
    
}

struct FeatureCombination: Equatable {
    static func == (lhs: FeatureCombination, rhs: FeatureCombination) -> Bool {
        return rhs.color == lhs.color
            && rhs.number == lhs.number
            && rhs.symbol == lhs.symbol
            && rhs.shading == lhs.shading
    }
    
    var number: Number = .none
    var color: Color = .none
    var symbol: Symbol = .none
    var shading: Shading = .none
    
    mutating func add(feature: Feature) {
        if feature is Number {
            number = feature as! Number
        }else if feature is Color {
            color = feature as! Color
        }else if feature is Symbol {
            symbol = feature as! Symbol
        }else if feature is Shading {
            shading = feature as! Shading
        }
    }
}

//CARDS INHERITE FEATURES
protocol Feature {
    //POSSIBLE VALUES OF THE CURRENT FEATURE
    static var values: [Feature] { get }
    //GETS NEXT FEATURE IN ORDER, FOR CREATION OF CARDS
    static func getNextFeatures() -> [Feature]?
}

//ENUMS FOR EACH OF THE CARDS' POSSIBLE FEATURES
enum Number: Int, Feature {
    case one
    case two
    case three
    case none
    
    static var values: [Feature] {
        return [Number.one, Number.two, Number.three]
    }
    
    static func getNextFeatures() -> [Feature]? {
        return Color.values
    }
}

enum Color: Int, Feature {
    case red
    case green
    case purple
    case none
    
    static var values: [Feature] {
        return [Color.red, Color.green, Color.purple]
    }
    
    static func getNextFeatures() -> [Feature]? {
        return Symbol.values
    }
}

enum Symbol: Int, Feature {
    case squiggle
    case diamond
    case oval
    case none
    
    static var values: [Feature] {
        return [Symbol.squiggle, Symbol.diamond, Symbol.oval]
    }
    
    static func getNextFeatures() -> [Feature]? {
        return Shading.values
    }
}

enum Shading: Int, Feature {
    case solid
    case striped
    case outlined
    case none
    
    static var values: [Feature] {
        return [Shading.solid, Shading.striped, Shading.outlined]
    }
    
    static func getNextFeatures() -> [Feature]? {
        return nil
    }
}
