//
//  SumViewController.swift
//  Test_interface
//
//  Created by Pasquale Nardiello on 14/07/21.
//

import UIKit

class SumViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var txt: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textView.text = ""
        for i in txt{
            textView.text += i
            textView.text += "\n"
        }
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func shareAction(_ sender: Any) {
        let activityViewController = UIActivityViewController(activityItems: [textView.text!],
                                     applicationActivities: nil)

        present(activityViewController, animated: true)
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        if (dosave){
            let date = Date()
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd_HH:mm:ss"
            let timestamp = format.string(from: date)
            pdfUtil.textToPDF(textContent: textView.text, fileName: timestamp)
        }
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
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
