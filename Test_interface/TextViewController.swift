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
    
    var txt: String?
    var summarisedContent: [String] = []
    
    @IBAction func compAction(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "ComprehensionSegue", sender: self)
    }
    
    @IBAction func sumAction(_ sender: UIBarButtonItem) {
        summarisedContent = []
        Reductio.summarize(text: textView.text, compression: sumperc) { phrases in
            summarisedContent = phrases
        }
        self.performSegue(withIdentifier: "SumSegue", sender: self)
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
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "SumSegue"){
            let sumseg = segue.destination as! SumViewController
            sumseg.txt = summarisedContent
        }
        else if(segue.identifier == "ComprehensionSegue"){
            let compsegue = segue.destination as! ComprehensionViewController
            compsegue.txt = textView.text
        }
    }
    

}
