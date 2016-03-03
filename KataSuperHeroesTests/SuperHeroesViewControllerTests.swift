//
//  SuperHeroesViewControllerTests.swift
//  KataSuperHeroes
//
//  Created by Pedro Vicente Gomez on 13/01/16.
//  Copyright © 2016 GoKarumi. All rights reserved.
//

import Foundation
import KIF
import Nimble
import UIKit
@testable import KataSuperHeroes

class SuperHeroesViewControllerTests: AcceptanceTestCase {

    private let repository = MockSuperHeroesRepository()

    func testShowsEmptyCaseIfThereAreNoSuperHeroes() {
        givenThereAreNoSuperHeroes()

        openSuperHeroesViewController()

        let emptyCaseText = tester().waitForViewWithAccessibilityLabel("¯\\_(ツ)_/¯")
            as! UILabel
        expect(emptyCaseText.text).to(equal("¯\\_(ツ)_/¯"))
    }

    private func givenThereAreNoSuperHeroes() {
        givenThereAreSomeSuperHeroes(0)
    }

    private func givenThereAreSomeSuperHeroes(numberOfSuperHeroes: Int = 10,
        avengers: Bool = false) -> [SuperHero] {
        var superHeroes = [SuperHero]()
        for i in 0..<numberOfSuperHeroes {
            let superHero = SuperHero(name: "SuperHero - \(i)",
                photo: NSURL(string: "https://i.annihil.us/u/prod/marvel/i/mg/c/60/55b6a28ef24fa.jpg"),
                isAvenger: avengers, description: "Description - \(i)")
            superHeroes.append(superHero)
        }
        repository.superHeroes = superHeroes
        return superHeroes
    }

    private func openSuperHeroesViewController() {
        let superHeroesViewController = ServiceLocator()
            .provideSuperHeroesViewController() as! SuperHeroesViewController
        superHeroesViewController.presenter = SuperHeroesPresenter(ui: superHeroesViewController,
                getSuperHeroes: GetSuperHeroes(repository: repository))
        let rootViewController = UINavigationController()
        rootViewController.viewControllers = [superHeroesViewController]
        presentViewController(rootViewController)
    }
    
    func testShowsNoEmptyCaseIfThereAreSuperHeroes() {
        let superHeroes = givenThereAreSomeSuperHeroes()
        
        openSuperHeroesViewController()
        
        let tableView = tester().waitForViewWithAccessibilityLabel("SuperHeroesTableView") as! UITableView
        
        expect(tableView.numberOfRowsInSection(0)).to(equal(superHeroes.count))
    }
    
    func testShowsCorrectOneSuperHeroe() {
        let superHeroes = givenThereAreSomeSuperHeroes(1, avengers: false)
        let superHeroe = superHeroes[0] 
        
        openSuperHeroesViewController()
        
        let tableView = tester().waitForViewWithAccessibilityLabel("SuperHeroesTableView") as! UITableView
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath.init(forRow: 0, inSection: 0)) as! SuperHeroTableViewCell
        
        expect(cell.nameLabel.text).to(equal(superHeroe.name))
        expect(cell.avengersBadgeImageView.hidden).to(equal(!superHeroe.isAvenger))
    }
    
    func testShowsCorrectSuperHeroes() {
        let superHeroes = givenThereAreSomeSuperHeroes(10, avengers: false)

        openSuperHeroesViewController()
        
        for superHeroe in superHeroes {
            let cell = tester().waitForViewWithAccessibilityLabel("\(superHeroe.name)") as! SuperHeroTableViewCell
            expect(cell.nameLabel.text).to(equal(superHeroe.name))
        }
    }
    
    func testSuperHeroeTappedGoesToCorrectDetail() {
        let superHeroes = givenThereAreSomeSuperHeroes(10, avengers: false)
        let i = 2
        let superHeroe = superHeroes[i]
        openSuperHeroesViewController()

        tester().tapRowAtIndexPath(NSIndexPath.init(forRow: i, inSection: 0), inTableViewWithAccessibilityIdentifier: "SuperHeroesTableView")
        
        let item = tester().waitForViewWithAccessibilityLabel(superHeroe.name, traits: UIAccessibilityTraitHeader)
        
        expect(item).toNot(beNil())
    }
    

}