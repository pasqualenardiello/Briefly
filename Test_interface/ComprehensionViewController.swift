//
//  ComprehensionViewController.swift
//  Test_Interface
//
//  Created by Pasquale Nardiello on 19/07/21.
//

import UIKit
import AVFoundation

class ComprehensionViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var answerButton: UIButton!
    
    var txt : String?
    let m = BertForQuestionAnswering(.distilled)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textView.text=""
        textField.text=""
        textView.text=txt
        textView.isEditable=false
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func answerAction(_ sender: UIButton) {
        let altitle = NSLocalizedString("Answer", comment: "alertController title")
        let question = textField.text ?? ""
        let context = textView.text ?? ""
        DispatchQueue.global(qos: .userInitiated).async {
            let prediction = self.m.predict(question: question, context: context)
            print("🎉", prediction)
            DispatchQueue.main.async {
                let alert = UIAlertController(title: altitle, message: prediction.answer, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
