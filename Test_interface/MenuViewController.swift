//
//  MenuViewController.swift
//  Test_interface
//
//  Created by Pasquale Nardiello on 14/07/21.
//

import Foundation
import UIKit
import Vision
import VisionKit
import UniformTypeIdentifiers


class MenuViewController: UIViewController, UIDocumentPickerDelegate {

    @IBOutlet weak var ScanButton: UIButton!
    @IBOutlet weak var imgButton: UIButton!
    @IBOutlet weak var pdfButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    private var ocrRequest = VNRecognizeTextRequest(completionHandler: nil)
    var recText = ""
    
    @IBAction func settingsAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "settingsSegue", sender: self)
    }
    
    @IBAction func ScanAction(_ sender: UIButton) {
        let scanVC = VNDocumentCameraViewController()
        scanVC.delegate = self
        recText = ""
        present(scanVC, animated: true)
    }
    
    @IBAction func ImgAction(_ sender: UIButton) {
        let imgVC = UIImagePickerController()
        imgVC.modalPresentationStyle = .fullScreen
        imgVC.sourceType = .savedPhotosAlbum
        imgVC.delegate = self
        recText = ""
        present(imgVC, animated: true)
    }
    
    @IBAction func infoAction(_ sender: UIButton) {
        let altitle = NSLocalizedString("Info on Briefly", comment: "alertController title")
        let almessage = NSLocalizedString("\nThis is a test app.\nThis app is designed as POC.\n\nGroup 6 composition:\n\nFrancesco Landi\nGabriele Lodato\nAndrea Massinelli\nPasquale Nardiello\nPasquale Rendina\n", comment: "alertController message")
        let _: () = alertUtil.init().displayAlert(title: altitle, message: almessage, time: 8.0, actions: [UIAlertAction.init(title: "OK", style: .default, handler: nil)])
    }
    
    @IBAction func pdfAction(_ sender: Any) {
        let types = UTType.types(tag: "pdf", tagClass: UTTagClass.filenameExtension, conformingTo: nil);
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes:types,asCopy: true);
        documentPicker.delegate=self;
        recText = ""
        documentPicker.modalPresentationStyle = .pageSheet;
        documentPicker.allowsMultipleSelection=true;
        present(documentPicker, animated: true, completion: nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureOCR()
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "TextSegue"){
                    let txtseg = segue.destination as! TextViewController
                    txtseg.txt = recText
        }
    }
    
    private func processImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }

        ScanButton.isEnabled = false
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([self.ocrRequest])
        } catch {
            print(error)
        }
    }
    
    private func configureOCR() {
        ocrRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var ocrText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { return }
                
                ocrText += topCandidate.string
                if ocrText.last! == "."{
                    ocrText += "\n"
                }
                else if ocrText.last! != " "{
                    if ocrText.last! == "-"{
                        ocrText.remove(at: ocrText.index(before: ocrText.endIndex))
                    }
                    else{
                        ocrText += " "
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.recText += ocrText
                self.ScanButton.isEnabled = true
            }
        }
        
        ocrRequest.recognitionLevel = .accurate
        ocrRequest.recognitionLanguages = ["en-US", "en-GB", "it-IT"]
        ocrRequest.usesLanguageCorrection = true
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController,didPickDocumentsAt urls: [URL]){
        recText = pdfUtil.readPDFpages(url: urls[0], pages: .all);
        controller.dismiss(animated: true){
            self.performSegue(withIdentifier: "TextSegue", sender: self)
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController){
        print("User has cancelled file opening")
        controller.dismiss(animated: true, completion: nil);
    }
}

extension MenuViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        guard scan.pageCount >= 1 else {
            controller.dismiss(animated: true)
            return
        }
        
        for i in 0...scan.pageCount-1{
            processImage(scan.imageOfPage(at: i))
        }
        controller.dismiss(animated: true){
            self.performSegue(withIdentifier: "TextSegue", sender: self)
        }
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        //Handle properly error
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
}

extension MenuViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]) {
        let tempImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        processImage(tempImage)
        picker.dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "TextSegue", sender: self)
        })
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
