//
//  LogInViewController.swift
//  Zazu Screens
//
//  Created by song on 4/5/15.
//  Copyright (c) 2015 Zazu Labs. All rights reserved.
//

import UIKit
import SwiftHTTP
import JSONJoy

class LogInViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var status: UILabel!
    var isLogedIn = false
    override func viewDidLoad() {
        super.viewDidLoad()
        var tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func loginButton(sender: AnyObject) {
        let username = self.username.text
        let password = self.password.text
        let params:Dictionary<String, AnyObject> = [
            "username": "\(username)",
            "password": "\(password)"
        ]
        request.POST("\(apiURL)/login/", parameters: params, success: {(response: HTTPResponse) in
            if response.responseObject != nil {
                user = User(JSONDecoder(response.responseObject!))
                println("login successfully")
                println(user.currentUser!.email!)
                println(user.currentUser!.firstName!)
                println(user.currentUser!.lastName!)
                println(user.token)
            }
            self.isLogedIn = true
            }, failure: {(error: NSError, response: HTTPResponse? ) in
                println("fail")
                self.status.text = "wrong password or username"
        })
        sleep(1)
        if self.isLogedIn == true {
            self.performSegueWithIdentifier("Main", sender: self)
        }
    }
    //Dismiss keyboard if screen tapped
    func dismissKeyboard()
    {
        view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
