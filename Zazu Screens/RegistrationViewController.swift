//
//  RegistrationViewController.swift
//  Zazu Screens
//
//  Created by song on 4/19/15.
//  Copyright (c) 2015 Zazu Labs. All rights reserved.
//

import UIKit
import SwiftHTTP

class RegistrationViewController: UIViewController {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
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
    
    @IBAction func CancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func RegisterButton(sender: AnyObject) {
        if firstName.text == "" {
            alertView("first name")
        } else if lastName.text == "" {
            alertView("last name")
        } else if userName.text == "" {
            alertView("user name")
        } else if email.text == "" {
            alertView("email")
        } else if password.text == "" {
            alertView("password")
        } else {
            let fn = firstName.text
            let ln = lastName.text
            let un = userName.text
            let e = email.text
            let p = password.text
            
            let params:Dictionary<String, AnyObject> = [
            "first_name": "\(fn)",
            "last_name": "\(ln)",
            "username": "\(un)",
            "email": "\(e)",
            "password": "\(p)"
            ]
            
            
            request.POST("\(apiURL)/registration/", parameters: params, success: {(response: HTTPResponse) in
                self.dismissViewControllerAnimated(true, completion: nil)
                }, failure: {(error: NSError, response: HTTPResponse? ) in self.registrationFail()
            })
        }
        
    }
    
    func registrationFail()
    {
        let alertController = UIAlertController(title: "User registration", message:
            "User Email exists!", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func alertView(msg: String) {
        let alertController = UIAlertController(title: "Incorrect information", message:
            "\(msg) is missing!", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
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
