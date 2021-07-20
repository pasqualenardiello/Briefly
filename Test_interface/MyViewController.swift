//
//  MyViewController.swift
//  Test_interface
//
//  Created by Pasquale Nardiello on 13/07/21.
//

import UIKit
import Vision
import VisionKit

var sumperc : Float = 0.5
var dosave : Bool = true
let defaults = UserDefaults.standard

class MyViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pageControl = UIPageControl()
    
    func configurePageControl() {
            // The total number of pages that are available is based on how many available colors we have.
            pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 20))
            self.pageControl.numberOfPages = orderedViewControllers.count
            self.pageControl.currentPage = 1
            self.pageControl.tintColor = UIColor.white
            self.pageControl.pageIndicatorTintColor = UIColor.white
            self.pageControl.currentPageIndicatorTintColor = UIColor.black
            self.pageControl.backgroundStyle = .prominent
            self.pageControl.isUserInteractionEnabled = false
            self.view.addSubview(pageControl)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        delegate = self
        dataSource = self
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let dataPath = docURL.appendingPathComponent("Briefly")
        if !FileManager.default.fileExists(atPath: dataPath.path) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        if (defaults.value(forKey: "dosave") != nil){
            dosave = defaults.bool(forKey: "dosave")
        }
        if let firstViewController = orderedViewControllers.first {
                setViewControllers([firstViewController],
                    direction: .forward,
                    animated: true,
                    completion: nil)
            }
        configurePageControl()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ButtonSelectView"),
                UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecentsView")]
    }()

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
           // Returns the view controller after the given view controller.
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of:viewController) else {
                    return nil
                }
                
                let previousIndex = viewControllerIndex - 1
                
                guard previousIndex >= 0 else {
                    return nil
                }
                
                guard orderedViewControllers.count > previousIndex else {
                    return nil
                }
                
                return orderedViewControllers[previousIndex]
       }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
           // Returns the view controller before the given view controller.
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of:viewController) else {
                    return nil
                }
                
                let nextIndex = viewControllerIndex + 1
                let orderedViewControllersCount = orderedViewControllers.count

                guard orderedViewControllersCount != nextIndex else {
                    return nil
                }
                
                guard orderedViewControllersCount > nextIndex else {
                    return nil
                }
                
                return orderedViewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        /*let pageContentViewController = pageViewController.viewControllers![0]
            self.pageControl.currentPage = orderedViewControllers.firstIndex(of: pageContentViewController)!*/
        if(completed){
            if(self.pageControl.currentPage == 0){
                self.pageControl.currentPage = 1
            }
            else{
                self.pageControl.currentPage = 0
            }
        }
    }
}


