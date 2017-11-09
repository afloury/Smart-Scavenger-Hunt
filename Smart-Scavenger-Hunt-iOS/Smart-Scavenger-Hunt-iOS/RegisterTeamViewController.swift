//
//  RegisterTeamViewController.swift
//  Smart-Scavenger-Hunt-iOS
//
//  Created by student on 09/11/2017.
//  Copyright © 2017 student. All rights reserved.
//

import UIKit

class RegisterTeamViewController: UIViewController {

    @IBOutlet weak var startSession: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startSession.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startSession(_ sender: Any) {
    }
    
    @IBAction func cancelView(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
