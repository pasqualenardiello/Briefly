//
//  RecentsViewController.swift
//  Test_Interface
//
//  Created by Pasquale Nardiello on 17/07/21.
//

import UIKit
import QuickLook
import PDFKit
import NaturalLanguage
import CoreML
import SwiftGoogleTranslate

class RecentsViewController: UITableViewController, QLPreviewControllerDataSource, UIGestureRecognizerDelegate, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate{
    
    var flag = 0
    var trtxt : String = ""
    var urls : [URL] = []
    var previews: [Preview] = []
    let previewVC = QLPreviewController()
    let thumbnailSize = CGSize(width: 60, height: 90)
    let scale = UIScreen.main.scale
    var refControl = UIRefreshControl()
    var txt: String?
    var model : DocumentClassifier_1!
    let searchController = UISearchController(searchResultsController: nil)
    var filteredpreviews: [Preview] = []
    let scopes : [String] = [NSLocalizedString("All", comment: "category string"), NSLocalizedString("Business", comment: "category string"), NSLocalizedString("Food", comment: "category string"), NSLocalizedString("Medical", comment: "category string"), NSLocalizedString("Politics", comment: "category string"), NSLocalizedString("Sport", comment: "category string"), NSLocalizedString("Science", comment: "category string"), NSLocalizedString("Technology", comment: "category string")]
    
    func resizeTableViewHeaderHeight() {
        let headerView = self.tableView.tableHeaderView
        var frame = headerView?.frame
        frame!.size.height = 56
        headerView?.frame = frame!
        self.tableView.tableHeaderView = headerView
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        resizeTableViewHeaderHeight()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resizeTableViewHeaderHeight()
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        let headerView = self.tableView.tableHeaderView
        var frame = headerView?.frame
        frame!.size.height = 112
        headerView?.frame = frame!
        self.tableView.tableHeaderView = headerView
    }
    
    func searchBar(_ searchBar: UISearchBar,
          selectedScopeButtonIndexDidChange selectedScope: Int) {
        let category = scopes[selectedScope]
        filterContentForSearchText(searchBar.text!, category: category)
      }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchController.isActive = false
    }
    
    var isFiltering: Bool {
        let searchBarScopeIsFiltering =
            searchController.searchBar.selectedScopeButtonIndex != 0
          return searchController.isActive &&
            (!isSearchBarEmpty || searchBarScopeIsFiltering)
    }
    
    func filterContentForSearchText(_ searchText: String,
                                    category: String = "All") {
      filteredpreviews = previews.filter { (preview: Preview) -> Bool in
        let doesCategoryMatch = /*(category == "All" || */preview.category == category
        if isSearchBarEmpty {
              return doesCategoryMatch
            } else {
                return doesCategoryMatch && preview.displayName.lowercased()
                .contains(searchText.lowercased())
            }
      }
      tableView.reloadData()
    }
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        if searchBar.selectedScopeButtonIndex == 0 {
            filteredpreviews = previews.filter { (preview: Preview) -> Bool in
                return preview.displayName.lowercased().contains(searchBar.text!.lowercased())
            }
            tableView.reloadData()
        } else {
            let category = scopes[searchBar.selectedScopeButtonIndex]
            filterContentForSearchText(searchBar.text!, category: category)
        }
      }
    
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
            let txtcont = pdfUtil.readPDF(url: f)
            let prediction=try? model.prediction(text: txtcont.lowercased().replacingOccurrences(of: "\n", with: " "))
            let predictionData=prediction!.label;
            previews.append(Preview(displayName: f.lastPathComponent.components(separatedBy: ".")[0], fileName: f.lastPathComponent.components(separatedBy: ".")[0], fileExtension: "pdf", category: predictionData, url: f))
        }
        updateSearchResults(for: searchController)
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
                let altitle3 = NSLocalizedString("Text Comprehension", comment: "alertController title")
                let altitle4 = NSLocalizedString("Translate", comment: "alertController title")
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: altitle, style: .destructive, handler: { action in
                    if FileManager.default.fileExists(atPath: self.urls[indexPath.row].path) {
                        do {
                            try FileManager.default.removeItem(at: self.urls[indexPath.row])
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    if self.isFiltering {
                        let o : Preview = self.filteredpreviews[indexPath.row]
                        self.filteredpreviews.remove(at: indexPath.row)
                        self.previews.remove(at: self.previews.firstIndex(of: o)!)
                    } else {
                        self.previews.remove(at: indexPath.row)
                    }
                    self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                    self.tableView.reloadData()
                    self.previewVC.reloadData()
                }))
                if stc {
                    alert.addAction(UIAlertAction(title: altitle3, style: .default, handler: { action in
                        self.txt = pdfUtil.readPDFpages(url: self.urls[indexPath.row], pages: .all)
                        self.performSegue(withIdentifier: "RecCompSegue", sender: self)
                    }))
                }
                alert.addAction(UIAlertAction(title: altitle4, style: .default, handler: { action in
                    let textScan = pdfUtil.readPDFpages(url: self.urls[indexPath.row], pages: .all)
                    let semaphore = DispatchSemaphore(value: 0)
                    //Google API key
                    SwiftGoogleTranslate.shared.start(with: "Google API key")
                    SwiftGoogleTranslate.shared.translate(textScan, "it", "en") { (text, error) in
                        if let t = text {
                            print(t)
                            self.trtxt = t
                            self.flag = 1
                            semaphore.signal()
                        }
                    }
                    semaphore.wait()
                    if self.flag == 1{
                        self.flag = 0
                        self.performSegue(withIdentifier: "TrSumSegue", sender: self)
                    }
                }))
                alert.addAction(UIAlertAction(title: altitle2, style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return previews.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previews[index].url as QLPreviewItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search...", comment: "search string")
        navigationItem.searchController = searchController
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = [NSLocalizedString("All", comment: "category string"), NSLocalizedString("Business", comment: "category string"), NSLocalizedString("Food", comment: "category string"), NSLocalizedString("Medical", comment: "category string"), NSLocalizedString("Politics", comment: "category string"), NSLocalizedString("Sport", comment: "category string"), NSLocalizedString("Science", comment: "category string"), NSLocalizedString("Technology", comment: "category string")]
        searchController.searchBar.delegate = self
        searchController.delegate = self
        do{
            let config=MLModelConfiguration();
            model=try DocumentClassifier_1(configuration: config);
        } catch{
        }
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
            let txtcont = pdfUtil.readPDF(url: f)
            let prediction=try? model.prediction(text: txtcont.lowercased().replacingOccurrences(of: "\n", with: " "))
            let predictionData=prediction!.label;
            previews.append(Preview(displayName: f.lastPathComponent.components(separatedBy: ".")[0], fileName: f.lastPathComponent.components(separatedBy: ".")[0], fileExtension: "pdf", category: predictionData, url: f))
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
        if isFiltering {
            return filteredpreviews.count
          }
        return previews.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? PreviewCell else {
            preconditionFailure()
        }
        let preview : Preview
        if isFiltering {
            preview = filteredpreviews[indexPath.row]
          } else {
            preview = previews[indexPath.row]
          }
        cell.configure(with: preview)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFiltering {
            let o = previews.firstIndex(of: filteredpreviews[indexPath.row])
            previewVC.currentPreviewItemIndex = o!
        } else {
            previewVC.currentPreviewItemIndex = indexPath.row
        }
        present(previewVC, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "RecCompSegue"){
            let txtseg = segue.destination as! ComprehensionViewController
            txtseg.txt = txt
        }
        if(segue.identifier == "TrSumSegue"){
            let sumseg = segue.destination as! SumViewController
            sumseg.txt = [trtxt]
            sumseg.ttl = ""
            buttonstatus = true
        }
    }

}

class Preview: NSObject, QLPreviewItem {
    let displayName: String
    let fileName: String
    let fileExtension: String
    var thumbnail: UIImage?
    var category: String?
    let url: URL
    
    init(displayName: String, fileName: String, fileExtension: String, url: URL) {
        self.displayName = displayName
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.category = NSLocalizedString("Uncategorized", comment: "category string")
        self.url = url
        super.init()
    }
    
    init(displayName: String, fileName: String, fileExtension: String, category: String, url: URL) {
        self.displayName = displayName
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.url = url
        if category == "Business"{
            self.category = NSLocalizedString("Business", comment: "category string")
        }
        else if category == "Food"{
            self.category = NSLocalizedString("Food", comment: "category string")
        }
        else if category == "Medical"{
            self.category = NSLocalizedString("Medical", comment: "category string")
        }
        else if category == "Politics"{
            self.category = NSLocalizedString("Politics", comment: "category string")
        }
        else if category == "Sport"{
            self.category = NSLocalizedString("Sport", comment: "category string")
        }
        else if category == "Science"{
            self.category = NSLocalizedString("Science", comment: "category string")
        }
        else if category == "Technology"{
            self.category = NSLocalizedString("Technology", comment: "category string")
        }
        else {
            self.category = NSLocalizedString("Uncategorized", comment: "category string")
        }
        super.init()
    }
    
    var previewItemTitle: String? {
        return displayName
    }
    
    var formattedFileName: String {
        return "\(fileName).\(fileExtension)"
    }
    
    var previewCategory: String? {
        return category
    }
    
    var previewItemURL: URL? {
        return Bundle.main.url(forResource: fileName, withExtension: fileExtension)
    }
}

