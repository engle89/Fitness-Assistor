//
//  ViewController.swift
//  Beat
//
//  Created by 霍晟悦 on 2/28/17.
//  Copyright © 2017 霍晟悦. All rights reserved.
//

import UIKit
var distance = 0.0


class ViewController: UIViewController, UITextFieldDelegate{

    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var ageField: UITextField!
    
    @IBOutlet weak var weightLabel: UILabel!
    
    @IBOutlet weak var weightField: UITextField!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var distanceField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.delegate = self
        ageField.delegate = self
        weightField.delegate = self
        distanceField.delegate = self
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func startButton(_ sender: Any) {
        let age = Double(ageField.text!)
        let weight = Double(weightField.text!)
        distance = Double(distanceField.text!)!
        // this is the distance that the user wants to run
        
    }
    
    func customer_distance() -> Double{
        return distance
    }
    
    //second view controller for our location tracker
    
    
    
}



