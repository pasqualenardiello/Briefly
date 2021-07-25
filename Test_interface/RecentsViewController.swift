//
//  RecentsViewController.swift
//  Test_Interface
//
//  Created by Pasquale Nardiello on 17/07/21.
//

import UIKit
import QuickLook
import PDFKit

//let refreshControl = UIRefreshControl()

class RecentsViewController: UITableViewController, QLPreviewControllerDataSource, UIGestureRecognizerDelegate {
    
    var urls : [URL] = []
    var previews: [Preview] = []
    let previewVC = QLPreviewController()
    let thumbnailSize = CGSize(width: 60, height: 90)
    let scale = UIScreen.main.scale
    var refControl = UIRefreshControl()
    
    @objc func refresh(_ sender: AnyObject) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let dataPath = docURL.appendingPathComponent("Briefly")
        do {
            self.urls = try FileManager.default.contentsOfDirectory(at: dataPath, includingPropertiesForKeys: nil, options: .producesRelativePathURLs).sorted(by: {$0.path < $1.path})
        } catch {
            print("ERRORE")
        }
        self.previews.removeAll()
        for f in self.urls{
            self.previews.append(Preview(displayName: f.lastPathComponent.components(separatedBy: ".")[0], fileName: f.lastPathComponent.components(separatedBy: ".")[0], fileExtension: "pdf"))
        }
        previewVC.reloadData()
        self.generatePreviews()
        refControl.endRefreshing()
    }
    
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(longPressGesture)
    }

    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let altitle = NSLocalizedString("Delete", comment: "alertController title")
                let altitle2 = NSLocalizedString("Cancel", comment: "alertController title")
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: altitle, style: .destructive, handler: { action in
                    if FileManager.default.fileExists(atPath: self.urls[indexPath.row].path) {
                        do {
                            try FileManager.default.removeItem(at: self.urls[indexPath.row])
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    self.urls.remove(at: indexPath.row)
                    self.previews.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                    self.tableView.reloadData()
                    self.previewVC.reloadData()
                }))
                alert.addAction(UIAlertAction(title: altitle2, style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return urls.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return urls[index] as QLPreviewItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let dataPath = docURL.appendingPathComponent("Briefly")
        do {
            urls = try FileManager.default.contentsOfDirectory(at: dataPath, includingPropertiesForKeys: nil, options: .producesRelativePathURLs).sorted(by: {$0.path < $1.path})
        } catch {
            print("ERRORE")
        }
        for f in urls{
            previews.append(Preview(displayName: f.lastPathComponent.components(separatedBy: ".")[0], fileName: f.lastPathComponent.components(separatedBy: ".")[0], fileExtension: "pdf"))
        }
        previewVC.dataSource = self
        generatePreviews()
        setupLongPressGesture()
        refControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refControl
    }
    
    func generatePreviews() {
        for preview in previews{
            preview.thumbnail = pdfUtil.imagePDF(url: urls[previews.firstIndex(of: preview)!], ofPageNum: 0, cgSize: thumbnailSize)
        }
        self.tableView.reloadData()
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        cell.alpha = 0

        UIView.animate(
            withDuration: 0.5,
            delay: 0.05 * Double(indexPath.row),
            animations: {
                cell.alpha = 1
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return urls.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? PreviewCell else {
            preconditionFailure()
        }
        let preview = previews[indexPath.row]
        cell.configure(with: preview)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        previewVC.currentPreviewItemIndex = indexPath.row
        present(previewVC, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
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

class Preview: NSObject, QLPreviewItem {
    let displayName: String
    let fileName: String
    let fileExtension: String
    var thumbnail: UIImage?
    
    init(displayName: String, fileName: String, fileExtension: String) {
        self.displayName = displayName
        self.fileName = fileName
        self.fileExtension = fileExtension
        super.init()
    }
    
    var previewItemTitle: String? {
        return displayName
    }
    
    var formattedFileName: String {
        return "\(fileName).\(fileExtension)"
    }
    
    var previewItemURL: URL? {
        return Bundle.main.url(forResource: fileName, withExtension: fileExtension)
    }
}

