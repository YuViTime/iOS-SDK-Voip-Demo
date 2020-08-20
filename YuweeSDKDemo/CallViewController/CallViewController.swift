//
//  CallViewController.swift
//  YuweeSDKDemo
//
//  Created by Arijit Das on 20/08/20.
//  Copyright © 2020 yuwee. All rights reserved.
//

import UIKit
import YuWeeSDK

class CallViewController: UIViewController, YuWeeCallSetUpDelegate, YuWeeCallManagerDelegate {
    
    var isIncomingCall = false
    
    @IBOutlet var remoteView: YuweeRemoteVideoView!
    @IBOutlet var localView: YuweeLocalVideoView!

    override func viewDidLoad() {
        super.viewDidLoad()

        AppDelegate.sharedInstance().isAnyCallIsOngoing = true

        navigationItem.rightBarButtonItem?.isEnabled = true
        Yuwee.sharedInstance().getCallManager().initCall(withLocalView: localView, withRemoteView: remoteView)
        Yuwee.sharedInstance().getCallManager().setCallManagerDelegate(self)
    }

    @IBAction func callEnd(_ sender: UIButton) {
        print("\(#function)")
        CallManager.sharedInstance().hangUpCall(completionBlockHandler: { isCallSuccess, dictCallResponse in
            DispatchQueue.main.async(execute: {
                AppDelegate.sharedInstance().callKitEndCall()
                AppDelegate.sharedInstance().window?.rootViewController!.dismiss(animated: true)
            })
        })
    }
    
    func onAllUsersOffline() {
        
    }
    
    func onAllUsersBusy() {
        
    }
    
    func setUpAditionalViewsOn(_ remoteView: YuweeRemoteVideoView!, with size: CGSize) {
        
    }
    
    func onRemoteCallHangUp(_ callData: [AnyHashable : Any]!) {
        CallManager.sharedInstance().hangUpCall(completionBlockHandler: { isCallSuccess, dictCallResponse in
            DispatchQueue.main.async(execute: {
                AppDelegate.sharedInstance().callKitEndCall()
                AppDelegate.sharedInstance().window?.rootViewController!.dismiss(animated: true)
            })
        })
    }
    
    func onReady(toInitiateCall callParams: CallParams!, withBusyUserList arrBusyUserList: [Any]!) {
        navigationItem.rightBarButtonItem?.isEnabled = true
        if !callParams.isGroup {
            Yuwee.sharedInstance().getCallManager().initCall(withLocalView: localView, withRemoteView: remoteView)
        }
    }
    
    func onError(_ callParams: CallParams!, withMessage strMessage: String!) {
        
    }
    
    func onCallConnected() {
        print("call connected")
    }
    
    func onCallDisconnected() {
        print("call disconnected")
    }
    
    
    func onCallReconnecting() {
        print("call reconnecting")
    }

    func onCallReconnected() {
        print("call reconnected")
    }

    func onCallEnd(_ callData: [AnyHashable : Any]!) {
        print("call end")
        CallManager.sharedInstance().hangUpCall(completionBlockHandler: { isCallSuccess, dictCallResponse in
            DispatchQueue.main.async(execute: {
                AppDelegate.sharedInstance().callKitEndCall()
                AppDelegate.sharedInstance().window?.rootViewController!.dismiss(animated: true)
            })
        })
    }
    
    func onCallTimeOut() {
        print("call timeout")
    }
    
    func onCallConnectionFailed() {
        print("call failed")
    }
    
    func onCallReject() {
        print("call reject")
    }
}
