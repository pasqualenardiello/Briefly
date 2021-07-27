//
//  TextViewController.swift
//  Test_interface
//
//  Created by Pasquale Nardiello on 14/07/21.
//

import UIKit
import Reductio

class TextViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sumButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var compButton: UIToolbar!
    @IBOutlet weak var toolbar: UIToolbar!
    
    var txt: String?
    var summarisedContent: [String] = []
    var ttl: String?
    
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
                Reductio.summarize(text: self.textView.text, compression: sumperc) { phrases in
                    self.summarisedContent = phrases
                }
                self.performSegue(withIdentifier: "SumSegue", sender: self)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "cancel alertController title"), style: .destructive, handler: { alertaction -> Void in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            Reductio.summarize(text: textView.text, compression: sumperc) { phrases in
                summarisedContent = phrases
            }
            self.performSegue(withIdentifier: "SumSegue", sender: self)
        }
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
