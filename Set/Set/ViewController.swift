//
//  ViewController.swift
//  Set
//
//  Created by Rhett Hanscom on 6/2/19.
//  Copyright © 2019 Ariadne Project. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var setGame = SetGame()
    
    @IBOutlet var cardButtons: [UIButton]! {
        didSet {
            _ = setGame.dealCards(forAmount: 12)
        }
    }
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var matchedTriosLabel: UILabel!
    
    @IBOutlet weak var dealMoreButton: UIButton!
    
    private let symbolToText: [Symbol : String] = [
        .squiggle : "◼︎",
        .diamond : "▲",
        .oval : "●"
    ]
    
    private let colorFeatureToColor: [Color: UIColor] = [
        .red : #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1),
        .green : #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1),
        .purple : #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayCards()
    }
    
    private func displayCards() {
        for cardButton in cardButtons {
            cardButton.alpha = 0
            cardButton.setAttributedTitle(nil, for: .normal)
            cardButton.setTitle(nil, for: .normal)
        }
        
        setGame.cardsOnTable.enumerated().forEach { [unowned self] (index, card) in let cardButton = self.cardButtons[index]
            
            if let card = card {
                cardButton.alpha = 1
                cardButton.setAttributedTitle(self.getAttributedText(forCard: card)!, for: .normal)
                
                if self.setGame.selectedCards.contains(card) {
                    cardButton.layer.borderWidth = 3
                    cardButton.layer.borderColor = UIColor.blue.cgColor
                    cardButton.layer.cornerRadius = 8
                } else {
                    cardButton.layer.borderWidth = 0
                    cardButton.layer.cornerRadius = 0
                }
                
                if self.setGame.matchedCards.contains(card) {
                    cardButton.backgroundColor = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1)
                } else {
                    cardButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                }
            } else {
                cardButton.alpha = 0
            }
        }
        scoreLabel.text = "Score: \(setGame.score)"
        matchedTriosLabel.text = "Matches \(setGame.matchedDeck.count)"
        handleDealMoreButton()
    }
    
    private func getAttributedText(forCard card: SetCard) -> NSAttributedString? {
        guard card.combination.number != .none else { return nil }
        guard card.combination.symbol != .none else { return nil }
        guard card.combination.color != .none else { return nil }
        guard card.combination.shading != .none else { return nil }
        
        let number = card.combination.number
        let symbol = card.combination.symbol
        let color = card.combination.color
        let shading = card.combination.shading
        
        if let symbolChar = symbolToText[symbol] {
            let cardText = String(repeating: symbolChar, count: number.rawValue + 1)
            var attributes = [NSAttributedString.Key : Any]()
            let cardColor = colorFeatureToColor[color]!
            
            switch shading {
            case .outlined:
                attributes[NSAttributedString.Key.strokeWidth] = 10
                fallthrough
            case .solid:
                attributes[NSAttributedString.Key.foregroundColor] = cardColor
            case .striped:
                attributes[NSAttributedString.Key.foregroundColor] = cardColor.withAlphaComponent(0.3)
            default:
                break
            }
            
            let attributedText = NSAttributedString(string: cardText, attributes: attributes)
            
            return attributedText
        } else {
            return nil
        }
    }
    
    private func handleDealMoreButton() {
        if setGame.deck.count > 3, setGame.cardsOnTable.count < cardButtons.count || setGame.matchedCards.count > 0 {
            dealMoreButton.isEnabled = true
        } else {
            dealMoreButton.isEnabled = false
        }
    }
    
    @IBAction func didTapCard(_ sender: UIButton) {
        guard let index = cardButtons.firstIndex(of: sender) else { return }
        guard let _ = setGame.cardsOnTable[index] else { return }
        
        setGame.selectCard(at: index)
        
        displayCards()
    }
    
    
    @IBAction func didTapMoreDeal(_ sender: UIButton) {
        if setGame.matchedCards.count > 0 {
            setGame.removeMatchedCardsFromTable()
        }
        _ = setGame.dealCards()
        displayCards()
    }
    
    
    @IBAction func didTapNewGame(_ sender: UIButton) {
        setGame.reset()
        _ = setGame.dealCards(forAmount: 12)
        displayCards()
    }
}

