//
//  SetGame.swift
//  Set
//
//  Created by Rhett Hanscom on 6/2/19.
//  Copyright © 2019 Ariadne Project. All rights reserved.
//

import Foundation

typealias SetDeck = [SetCard]
typealias SetTrio = [SetCard]

class SetGame {
    //PROPERTIES
    
    //ALL REMAINING AVAILIBLE CARDS
    private(set) var deck = SetDeck()
    //PREVIOUSLY MATCHED TRIOS
    private(set) var matchedDeck = [SetTrio]()
    //CURRENTLY DISPLAYED CARDS - OPTIONAL AS CARDS WILL BE REMOVED FROM TABLE DURING GAMEPLAY
    private(set) var cardsOnTable = [SetCard?]()
    //CURRENTLY SELECTED
    private(set) var selectedCards = [SetCard]()
    //CURRENTLY MATCHED CARDS
    private(set) var matchedCards = [SetCard]() {
        didSet {
            if matchedCards.count == 3 {
                matchedDeck.append(matchedCards)
            }
        }
    }
    //SET PLAYER SCORE, ENSURE CANNOT BE LESS THAN ZERO
    private(set) var score = 0 {
        didSet {
            if score < 0 {
                score = 0
            }
        }
    }
    
    //INITIALIZERS
    init() {
        deck = makeDeck()
    }
    
    //IMPERATIVES
    func selectCard(at index: Int) {
        guard let card = cardsOnTable[index] else { return }
        guard !matchedCards.contains(card) else { return }
        
        if matchedCards.count > 0 {
            removeMatchedCardsFromTable()
            _ = dealCards()
        }

        if selectedCards.count == 3 {
            guard !selectedCards.contains(card) else { return }
            if !currentSelectionMatches() {
                score -= 2
            }
            selectedCards = []
        }
        
        if let index = selectedCards.firstIndex(of: card) {
            selectedCards.remove(at: index)
        } else {
            selectedCards.append(card)
        }
        
        if selectedCards.count == 3, currentSelectionMatches() {
            matchedCards = selectedCards
            selectedCards = []
            score += 4
        }
    }
    
    func removeMatchedCardsFromTable() {
        guard matchedCards.count == 3 else { return }
        for index in cardsOnTable.indices {
            if let card = cardsOnTable[index], matchedCards.contains(card) {
                cardsOnTable[index] = nil
            }
        }
        matchedCards = []
    }
    
    private func currentSelectionMatches() -> Bool {
        guard selectedCards.count == 3 else { return false }
        return matches(selectedCards)
    }
    
    private func matches(_ cards: SetTrio) -> Bool {
        let first = cards[0]
        let second = cards[1]
        let third = cards[2]
        
        let numbersFeatures = Set([first.combination.number, second.combination.number, third.combination.number])
        let colorsFeatures = Set([first.combination.color, second.combination.color, third.combination.color])
        let symbolsFeatures = Set([first.combination.symbol, second.combination.symbol, third.combination.symbol])
        let shadingsFeatures = Set([first.combination.shading, second.combination.shading, third.combination.shading])
        
        return (numbersFeatures.count == 1 || numbersFeatures.count == 3) &&
            (colorsFeatures.count == 1 || colorsFeatures.count == 3) &&
            (symbolsFeatures.count == 1 || symbolsFeatures.count == 3) &&
            (shadingsFeatures.count == 1 || shadingsFeatures.count == 3)
    }
    
    func dealCards(forAmount amount: Int = 3) -> [SetCard] {
        guard amount > 0 else { return [] }
        guard deck.count >= amount else { return [] }
        
        var cardsToDeal = [SetCard]()
        
        for _ in 0..<amount {
            cardsToDeal.append(deck.removeFirst())

        }
        
        for (index, card) in cardsOnTable.enumerated() {
            if card == nil {
                cardsOnTable[index] = cardsToDeal.removeFirst()
            }
        }
        
        if !cardsToDeal.isEmpty {
            cardsOnTable += cardsToDeal as [SetCard?]
        }
        
        return cardsToDeal
    }
    
    func reset() {
        deck = makeDeck()
        matchedCards = []
        selectedCards = []
        matchedDeck = []
        cardsOnTable = []
        score = 0
    }
    
    private func makeDeck(features: [Feature] = Number.values,
                          currentCombination: FeatureCombination = FeatureCombination(),
                          deck: SetDeck = SetDeck()) -> SetDeck {
        var deck = deck
        var currentCombination = currentCombination
        
        let nextFeatures = type(of: features[0]).getNextFeatures()
        
        for feature in features {
            currentCombination.add(feature: feature)
            
            if let nextFeatures = nextFeatures {
                deck = makeDeck(features: nextFeatures, currentCombination: currentCombination, deck: deck)
            } else {
                deck.append(SetCard(combination: currentCombination))
            }
        }
        
        return deck.shuffled()
    }
}

import GameKit

extension Array {
    func shuffled() -> [Element] {
        return GKRandomSource.sharedRandom().arrayByShufflingObjects(in: self) as! [Element]
    }
}
