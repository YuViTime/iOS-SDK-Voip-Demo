//
//  LoginViewController.swift
//  YuweeSDKDemo
//
//  Created by Arijit Das on 20/08/20.
//  Copyright © 2020 yuwee. All rights reserved.
//

import UIKit
import YuWeeSDK

class LoginViewController: UIViewController, YuWeeConnectionDelegate, YuWeeIncomingCallEventDelegate {
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.isNavigationBarHidden = true

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        view.addGestureRecognizer(gestureRecognizer)
        view.isUserInteractionEnabled = true
        gestureRecognizer.cancelsTouchesInView = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
        login()
    }
    
    func showToast(controller: UIViewController, message : String, seconds: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.black
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 15
        
        controller.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }

    @objc func hideKeyboard(_ recognizer: UITapGestureRecognizer?) {
        view.endEditing(true)
    }

    func openDashboardController() {

        performSegue(withIdentifier: "dashboardSegue", sender: self)
    }
    

    @IBAction func onRegistrationPressed(_ sender: Any) {
        print("On Registration Pressed")

    }
    
    @IBAction func onLoginPressed(_ sender: Any) {
        
        print("On Login Pressed")

        //login()
    }
        
    func login() {
        Yuwee.sharedInstance().getUserManager().createSessionViaCredentials(withEmail: "a@a.com", password: "123456", expiryTime: "200000") { (isSessionCreateSuccess, dictSessionCreateResponse) in
            
            if isSessionCreateSuccess {
                
                let dict = UserDefaults.standard.value(forKey: "token") as? [String : Any]
                
                if (dict != nil) {
                    let pushToken: String = dict!["apns"] as! String
                    
                    print(pushToken)
                    
                    let voipToken: String = dict!["voip"] as! String
                    
                    print(voipToken)
                    
                    let dict = dictSessionCreateResponse!["result"] as! [AnyHashable : Any]
                    
                    let param = InitParam()
                    
                    param.accessToken = dictSessionCreateResponse!["access_token"] as! String
                    param.userInfo = dict["user"] as! [AnyHashable : Any]
                    
//                    Yuwee.sharedInstance().getUserManager().createSession(viaToken: param) { (isSessionSuccess, responseStr) in
//
//                        if (isSessionSuccess) {
                            Yuwee.sharedInstance().getUserManager().registerPushTokenAPNS(pushToken, voip: voipToken) { (success, message) in
                                if success{
                                    Yuwee.sharedInstance().getConnectionManager().setConnectionDelegate(self)
                                    Yuwee.sharedInstance().restartAppConnection()
                                    print("success")
                                    Yuwee.sharedInstance().getCallManager().setIncomingCallEventDelegate(self)
                                }else{
                                    self.showToast(controller: self, message: "Something went wrong", seconds: 2.0)
                                }
                            }
//                        }
//                    }
                }
            } else {
                Yuwee.sharedInstance().getConnectionManager().forceReconnect()
            }
        }
    }
    
    func onIncomingCall(_ callData: [AnyHashable : Any]!) {
        print("\(String(describing: callData))")
    }
    
    func onIncomingCallAcceptSuccess(_ callData: [AnyHashable : Any]!) {
        print("\(String(describing: callData))")
    }
    
    func onIncomingCallRejectSuccess(_ callData: [AnyHashable : Any]!) {
        print("\(String(describing: callData))")
    }
    
    func onConnected() {
        print("connected")
    }
    
    func onDisconnected() {
        print("disconnected")
    }
    
    func onReconnection() {
        print("reconnecting")
    }
    
    func onReconnected() {
        print("reconnected")
    }
    
    func onReconnectionFailed() {
        print("reconnection failed")
    }
    
    func onClose() {
        print("close")
    }

}
