//
//  TargetsDetailsViewController.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 06.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class OptionalTasksViewController: UIViewController {
    @IBAction func handleDismissButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var label: UILabel!
    
    private lazy var collectionView:UICollectionView = {
        var flowLayout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.register(TrayMenuCollectionViewCell.self, forCellWithReuseIdentifier: "OptionalTaskCell")
        view.dataSource = self
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.alpha = 0
        
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        layoutViews()
    }
    
    deinit {
        print("💾 OptionalTasksViewController deinitialized...")
    }
    
    
    
    // ⚡️ FUNCTIONS
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func layoutViews() {
        
    }
    
    public func  makeViewsVisibleAgainstBackground(color:UIColor) {
        label.textColor = color.contrastColor()
    }

}


extension OptionalTasksViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OptionalTaskCell", for: indexPath)
        return cell
    }
}

extension OptionalTasksViewController: UICollectionViewDelegateFlowLayout {
    
}
