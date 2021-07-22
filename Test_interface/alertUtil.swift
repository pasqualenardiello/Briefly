//
//  alertUtil.swift
//  Test_interface
//
//  Created by Pasquale Rendina on 20/07/21.
//

import UIKit

class alertUtil{
    private var remainingTime=0.0;
    private var alertTimer:Timer
    private var alertController:UIAlertController?
    private var originalMessage:String
    private var backgroundTask:UIBackgroundTaskIdentifier = .invalid;
    init() {
        alertTimer=Timer()
        alertController=nil
        originalMessage=""
        remainingTime=0.0
        backgroundTask = .invalid;
        NotificationCenter.default.addObserver(self, selector: #selector(reinstateBackgroundTask), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    static func displayAlert(title:String,message:String){
        let alert=UIAlertController(title: title, message: title, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {(UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }))
        let key=UIApplication.shared.windows.first{$0.isKeyWindow}
        key?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    func displayAlert(title:String,message:String,time:Double){
        let alert=UIAlertController(title: title, message: message, preferredStyle: .alert)
        let controller=UIApplication.shared.windows.first{$0.isKeyWindow}?.rootViewController
        alertController=alert
        remainingTime=time
        originalMessage=alertController?.message ?? ""
        alertTimer=Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        alertTimer.tolerance=0.0;
        controller?.present(alert, animated: true, completion: nil)
    }
    func displayAlert(title:String,message:String,time:Double,actions:[UIAlertAction]){
        let alert=UIAlertController(title: title, message: message, preferredStyle: .alert)
        for i in 0..<actions.count {
            alert.addAction(actions[i])
        }
        let controller=UIApplication.shared.windows.first{$0.isKeyWindow}?.rootViewController
        alertController=alert
        remainingTime=time
        originalMessage=alertController?.message ?? ""
        alertTimer=Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        alertTimer.tolerance=0.0
        controller?.present(alert, animated: true, completion: nil)
    }
    
    @objc private func countDown(){
        remainingTime-=1
        if remainingTime<0{
            alertTimer.invalidate()
            alertController!.dismiss(animated: false, completion: nil)
        } else{
            alertController!.message=originalMessage+"\n"+alertMessage()
        }
    }
    private func alertMessage()->String{
        let base = NSLocalizedString("This will disappear in ", comment: "")
        let s1 = NSLocalizedString(" second", comment: "")
        let s2 = NSLocalizedString(" seconds", comment: "")
        let messageFix=base+"\(Int(remainingTime+1))"
        if remainingTime<1{
            return messageFix + s1
        } else {
            return messageFix + s2
        }
    }
    private func updateTimer()->Bool{
        return alertTimer.isValid;
    }
    @objc private func reinstateBackgroundTask() {
        if self.updateTimer() && self.backgroundTask ==  .invalid {
        registerBackgroundTask()
      }
    }
    private func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
      }
      assert(backgroundTask != .invalid)
    }
    
    private func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        NotificationCenter.default.removeObserver(self)
        backgroundTask = .invalid
    }
}
