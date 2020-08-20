//
//  AppDelegate.swift
//  YuweeSDKDemo
//
//  Created by Arijit Das on 20/08/20.
//  Copyright © 2020 yuwee. All rights reserved.
//

import UIKit
import YuWeeSDK
import PushKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, YuWeePushManagerDelegate, UNUserNotificationCenterDelegate, YuWeeIncomingCallEventDelegate, PKPushRegistryDelegate, CXProviderDelegate {
    
    typealias TokenCompletionBlock = ([String : Any]) -> Void
    
    var isAnyCallIsOngoing = false
    var currentCallUUID = UUID()
    var dictCall = NSDictionary()
    var window: UIWindow?
    var center: UNUserNotificationCenter?
    var block_Token: TokenCompletionBlock!
    var nav = UINavigationController()
    var voipRegistry: PKPushRegistry?
    var voipRegistry_Token: String?
    var apnsRegistry_Token: String?
    
    static func sharedInstance() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        Yuwee.sharedInstance().initWithAppId("", appSecret: "", clientId: "")
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        Yuwee.sharedInstance().getCallManager().setIncomingCallEventDelegate(self)
        application.registerForRemoteNotifications()
        
        voipRegistration()
        
        window = UIWindow(frame:UIScreen.main.bounds)
        let vc: LoginViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        nav = UINavigationController(rootViewController: vc)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
         Yuwee.sharedInstance().getCallManager().setIncomingCallEventDelegate(self)
        Yuwee.sharedInstance().restartAppConnection()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        Yuwee.sharedInstance().getCallManager().setIncomingCallEventDelegate(self)
        Yuwee.sharedInstance().dismissAppConnection()
    }
 
    func applicationWillEnterForeground(_ application: UIApplication) {
        Yuwee.sharedInstance().getCallManager().setIncomingCallEventDelegate(self)
        Yuwee.sharedInstance().restartAppConnection()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        Yuwee.sharedInstance().dismissAppConnection()
    }
    
    func voipRegistration() {
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
        voipRegistry.delegate = self;
    }
    
    
    //MARK: YuWeePushManagerDelegate}
    
    func onReceiveCall(fromPush dictResponse: [AnyHashable : Any]!) {
        
    }
    
    func onNewScheduleMeeting(fromPush dictResponse: [AnyHashable : Any]!) {
        
    }
    
    func onScheduleMeetingJoin(fromPush dictResponse: [AnyHashable : Any]!) {
        
    }
    
    func onChatMessageReceived(fromPush dictResponse: [AnyHashable : Any]!) {
        
    }
    
    
    //MARK: YuWeePushManagerDelegate
    
    func onIncomingCall(_ callData: [AnyHashable : Any]!) {
        
    }
    
    func onIncomingCallAcceptSuccess(_ callData: [AnyHashable : Any]!) {
        
    }
    
    func onIncomingCallRejectSuccess(_ callData: [AnyHashable : Any]!) {
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("didRegisterForRemoteNotificationsWithDeviceToken \(deviceToken)")

        apnsRegistry_Token = deviceToken.map{ String(format: "%02x", $0) }.joined()

        if (voipRegistry_Token != nil) {

            let dictTokens = ["voip" : voipRegistry_Token!, "apns" : apnsRegistry_Token!]

            print("\(dictTokens)")
            
            UserDefaults.standard.set(dictTokens, forKey: "token")

            //block_Token!(dictTokens)
        }
    }
    
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {

        print("\(#function)")
        
        print("voip token: \(pushCredentials.token)")

        //give that to users that want to call this user.
        if pushCredentials.token.count == 0 {
            print("voip token NULL")
            return
        }
        
        voipRegistry_Token = pushCredentials.token.map{ String(format: "%02x", $0) }.joined()
        print("PushCredentials: \(String(describing: voipRegistry_Token))")

        if (apnsRegistry_Token != nil) {

            let dictTokens = ["voip" : voipRegistry_Token!, "apns" : apnsRegistry_Token!]

            print("\(dictTokens)")
            
            UserDefaults.standard.set(dictTokens, forKey: "token")

            //block_Token!(dictTokens)
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        
        print("<<<<<<<<<<<<<<************* \(#function)")
        print("payload.dictionaryPayload = \(payload.dictionaryPayload)")
        print("UTC payload.dictionaryPayload = \(Date().timeIntervalSince1970)")
        
        if type == .voIP {
            
            let applicationState = UIApplication.shared.applicationState
            
            if applicationState == .inactive || applicationState == .background {
                
                let dict = payload.dictionaryPayload
                
                Yuwee.sharedInstance().getConnectionManager().forceReconnect()
                
                dictCall = dict["data"] as! NSDictionary
                print(dictCall)
                //Call kit configration
                let providerConfig = CXProviderConfiguration(localizedName: "my app Call")
                providerConfig.supportsVideo = false
                providerConfig.supportedHandleTypes = [CXHandle.HandleType.emailAddress]

                let callUpdate = CXCallUpdate()

                let uniqueIdentifier = "Max test"
                let update = CXCallUpdate()
                update.remoteHandle = CXHandle(type: .emailAddress, value: uniqueIdentifier)
                update.localizedCallerName = uniqueIdentifier
                update.hasVideo = false

                currentCallUUID = UUID()
                
                let provider = CXProvider(configuration: providerConfig)
                provider.setDelegate(self, queue: nil)

                provider.reportNewIncomingCall(with: currentCallUUID, update: callUpdate) { error in
                    if let error = error {
                        print("reportNewIncomingCallWithUUID error: \(error)")
                    }

                    //completion();
                }
                
                configureAudioSession(forCallKit: true)

                completion()
            }
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("token invalidated")
    }
    
    func providerDidReset(_ provider: CXProvider) {
        provider.invalidate()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
        let now = Date()
        provider.reportCall(with: currentCallUUID, endedAt: now, reason: .remoteEnded)
        Yuwee.sharedInstance().getCallManager().acceptIncomingCall(dictCall as! [AnyHashable : Any])
        let calVC = CallViewController(nibName: "CallViewController", bundle: nil)
        //calVC.isIncomingCall = true
        nav = UINavigationController(rootViewController: calVC)
        window!.rootViewController?.present(nav, animated: false)
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        print("call ended")
        provider.reportCall(with: currentCallUUID, endedAt: nil, reason: .remoteEnded)
        provider.invalidate()
        DispatchQueue.main.async {
            print("action fulfill")
            action.fulfill()
        }
    }
    
    func configureAudioSession(forCallKit hasVideo: Bool) {
        
        print("\(#function)")
        let audioSession = AVAudioSession.sharedInstance()
        let _: Error?
        print("configuring audio session..")

        if hasVideo {
            do {
                try audioSession.setCategory(
                    .playAndRecord,
                    mode: .videoChat,
                    options: .mixWithOthers)
            } catch _ {
            }
            
        } else {
            do {
                try audioSession.setCategory(
                    .playAndRecord,
                    mode: .voiceChat,
                    options: .mixWithOthers)
            } catch _ {
            }
        }

        do {
            try audioSession.overrideOutputAudioPort(.speaker)
        } catch _ {
        }
        
        let sampleRate = 44100.0
        do {
            try audioSession.setPreferredSampleRate(sampleRate)
        } catch _ {
        }

        let bufferDuration: TimeInterval = 0.005
        do {
            try audioSession.setPreferredIOBufferDuration(bufferDuration)
        } catch _{
        }
    }
    
    func callKitEndCall() {
        let endCallAction = CXEndCallAction(call: currentCallUUID)
        let transaction = CXTransaction(action: endCallAction)
        let callController = CXCallController(queue: DispatchQueue.main)
        callController.request(transaction) { error in
            if error != nil {
                print("EndCallAction transaction request failed: \(error?.localizedDescription ?? "")")
            } else {
                print("EndCallAction transaction request successful")
            }
        }
    }
}

