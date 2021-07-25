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
            /*let date = Date()
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd_HH:mm:ss"
            let timestamp = format.string(from: date)
            */
            let altitle = NSLocalizedString("Saving", comment: "text alertController title")
            let almessage = NSLocalizedString("Enter PDF name:", comment: "text alertController message")
            let alert = UIAlertController(title: altitle, message: almessage, preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { alertaction -> Void in
                var t = alert.textFields![0].text
                if(t!.isEmpty || t == nil){
                    t = "FILE"
                }
                let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                let documentsDirectory = paths[0]
                let docURL = URL(string: documentsDirectory)!
                let dataPath = docURL.appendingPathComponent("Briefly").appendingPathComponent(t!+".pdf")
                if !FileManager.default.fileExists(atPath: dataPath.path) {
                    print(pdfUtil.textToPDF(textContent: self.textView.text, fileName: t!)!)
                }
                else {
                    var files : [String] = []
                    do {
                        try files = FileManager.default.contentsOfDirectory(atPath: docURL.appendingPathComponent("Briefly").path)
                    } catch {
                        print(error.localizedDescription)
                    }
                    var c = 1
                    for i in files{
                        let j = i.components(separatedBy: "/")
                        let sz = j.count
                        if j[sz-1].contains(t!){
                            c += 1
                        }
                    }
                    print(pdfUtil.textToPDF(textContent: self.textView.text, fileName: t! + "(\(c))")!)
                    alert.dismiss(animated: true, completion: nil)
                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "cancel alertController title"), style: .destructive, handler: { alertaction -> Void in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
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
