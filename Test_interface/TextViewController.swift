//
//  TextViewController.swift
//  Test_interface
//
//  Created by Pasquale Nardiello on 14/07/21.
//

import UIKit
import Reductio
import Foundation
import SystemConfiguration

class TextViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sumButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var compButton: UIToolbar!
    @IBOutlet weak var toolbar: UIToolbar!
    
    var txt: String?
    var summarisedContent: [String] = []
    var ttl: String?
    
    func isInternetAvailable() -> Bool
        {
            var zeroAddress = sockaddr_in()
            zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
            zeroAddress.sin_family = sa_family_t(AF_INET)

            let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                    SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
                }
            }

            var flags = SCNetworkReachabilityFlags()
            if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
                return false
            }
            let isReachable = flags.contains(.reachable)
            let needsConnection = flags.contains(.connectionRequired)
            return (isReachable && !needsConnection)
        }
    
    @IBAction func compAction(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "ComprehensionSegue", sender: self)
    }
    
    @IBAction func sumAction(_ sender: UIBarButtonItem) {
        summarisedContent = []
        if dosave {
            let altitle = NSLocalizedString("Saving", comment: "text alertController title")
            let almessage = NSLocalizedString("Enter PDF name:", comment: "text alertController message")
            let alert = UIAlertController(title: altitle, message: almessage, preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { alertaction -> Void in
                self.ttl = alert.textFields![0].text!
                if(self.ttl!.isEmpty || self.ttl == nil){
                    self.ttl = "FILE"
                }
                if(!sumai){
                    Reductio.summarize(text: self.textView.text, compression: sumperc) { phrases in
                        self.summarisedContent = phrases
                    }
                    self.performSegue(withIdentifier: "SumSegue", sender: self)
                }
                else {
                    if self.isInternetAvailable(){
                        let semaphore = DispatchSemaphore(value: 0)
                        let headers : [String : String]? = ["api_token" : "2ad29ee6-0c09-4a81-be99-d092dfe6f8b7" , "Content-type" : "charset=UTF-8"]
                        let url = URL(string: "https://private-api.smrzr.io/v1/summarize?ratio=\(1 - sumperc)&algorithm=kmeans&min_length=40&max_length=500")
                        guard let requestUrl = url else { fatalError() }
                        // Prepare URL Request Object
                        var request = URLRequest(url: requestUrl)
                        request.httpMethod = "POST"
                        request.allHTTPHeaderFields = headers
                        request.httpBody = self.textView.text.data(using: String.Encoding.utf8)!
                        //request.httpBody = postData as Data
                        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                                if let error = error {
                                    print("Error took place \(error)")
                                    return
                                }
                                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                                    print("Response data string:\n \(dataString)")
                                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                                    if let responseJSON = responseJSON as? [String: Any] {
                                        if let resp = responseJSON["summary"] as? String{
                                            self.summarisedContent.append(resp)
                                            semaphore.signal()
                                        }
                                    }
                                }
                        }
                        task.resume()
                        semaphore.wait()
                        self.performSegue(withIdentifier: "SumSegue", sender: self)
                    }
                    else {
                        let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Internet alert"), message: NSLocalizedString("Internet unavailable.\nPlease connect to the network.", comment: "Internet alert"), preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "cancel alertController title"), style: .destructive, handler: { alertaction -> Void in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            if(!sumai){
                Reductio.summarize(text: self.textView.text, compression: sumperc) { phrases in
                    self.summarisedContent = phrases
                }
                self.performSegue(withIdentifier: "SumSegue", sender: self)
            }
            else {
                if self.isInternetAvailable(){
                    let semaphore = DispatchSemaphore(value: 0)
                    let headers : [String : String]? = ["api_token" : "2ad29ee6-0c09-4a81-be99-d092dfe6f8b7" , "Content-type" : "charset=UTF-8"]
                    let url = URL(string: "https://private-api.smrzr.io/v1/summarize?ratio=\(1 - sumperc)&algorithm=kmeans&min_length=40&max_length=500")
                    guard let requestUrl = url else { fatalError() }
                    // Prepare URL Request Object
                    var request = URLRequest(url: requestUrl)
                    request.httpMethod = "POST"
                    request.allHTTPHeaderFields = headers
                    request.httpBody = self.textView.text.data(using: String.Encoding.utf8)!
                    //request.httpBody = postData as Data
                    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                            if let error = error {
                                print("Error took place \(error)")
                                return
                            }
                            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                                print("Response data string:\n \(dataString)")
                                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                                if let responseJSON = responseJSON as? [String: Any] {
                                    if let resp = responseJSON["summary"] as? String{
                                        self.summarisedContent.append(resp)
                                        semaphore.signal()
                                    }
                                }
                            }
                    }
                    task.resume()
                    semaphore.wait()
                    self.performSegue(withIdentifier: "SumSegue", sender: self)
                }
                else {
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Internet alert"), message: NSLocalizedString("Internet unavailable.\nPlease connect to the network.", comment: "Internet alert"), preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        summarisedContent = []
        textView.text = ""
        textView.text = txt
        if (textView.text.isEmpty){
            sumButton.isEnabled = false
        }
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        if (!stc){
            toolbar.isHidden = true
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "SumSegue"){
            let sumseg = segue.destination as! SumViewController
            sumseg.txt = summarisedContent
            sumseg.ttl = ttl
        }
        else if(segue.identifier == "ComprehensionSegue"){
            let compsegue = segue.destination as! ComprehensionViewController
            compsegue.txt = textView.text
        }
    }
    

}
