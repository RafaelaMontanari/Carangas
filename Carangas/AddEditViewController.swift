//
//  AddEditViewController.swift
//  Carangas
//
//  Created by Eric Brito.
//  Copyright © 2017 Eric Brito. All rights reserved.
//

import UIKit

class AddEditViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tfBrand: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var scGasType: UISegmentedControl!
    @IBOutlet weak var btAddEdit: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!

    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBActions
    @IBAction func addEdit(_ sender: UIButton) {
    }

}
