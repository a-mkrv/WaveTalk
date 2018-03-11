//
//  ViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 13.11.16.
//  Copyright © 2016 Anton Makarov. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    
    let pageHeaders = ["Fastest!", "Reliable!", "Secure!", "Congratulation!"]
    let pageImages = ["Fastest","Reliable","Secure","Congratulation"]
    let pageDescriptions = [
    "Welcome!\nThis is the fastest messenger in the history of technology!",
    "You can be sure that your recipients receive messages such what you were sent!",
    "Secure data encryption to protect your messages from being read by third parties!",
    "We hope that you well never regret choosing WHISPER as his friend and partner. \nWe will not fail you!"
    ]
    
    @IBOutlet weak var pageDotsControl: UIPageControl!
    var viewControllers: [PageContentViewController]?
    var pageViewController: UIPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [viewControllerAtIndex(0)]
        
        /* Getting the page View controller */
        pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as? UIPageViewController
        self.pageViewController!.dataSource = self
        
        
        let pageContentViewController = self.viewControllerAtIndex(0)
        self.pageViewController!.setViewControllers([pageContentViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        
        addChildViewController(pageViewController!)
        view.addSubview(pageViewController!.view)
        pageViewController!.didMove(toParentViewController: self)

        
    }
    
    func viewControllerAtIndex(_ index: Int) -> PageContentViewController {
        
        if (self.pageImages.count == 0 || index >= self.pageImages.count) {
            return PageContentViewController()
        }
        
        let pageContentViewController = self.storyboard!.instantiateViewController(withIdentifier: "Walkthrough") as! PageContentViewController
        
        pageContentViewController.imageTxt = pageImages[index]
        pageContentViewController.headerTxt = pageHeaders[index]
        pageContentViewController.descriptionTxt = pageDescriptions[index]
        pageContentViewController.pageControl = pageDotsControl
        pageContentViewController.pageIndex = index
        
        return pageContentViewController
    }
    
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let VC = viewController as! PageContentViewController
        var index = VC.pageIndex! as Int
        
        if (index == NSNotFound || index == 0) {
            return nil
        }
        
        index -= 1
        
        return self.viewControllerAtIndex(index)
    }
   
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let VC = viewController as! PageContentViewController
        var index = VC.pageIndex! as Int
        
        if (index == NSNotFound) {
            return nil
        }
        
        index += 1
        
        if (index == self.pageHeaders.count) {
            return nil
        }
        
        return self.viewControllerAtIndex(index)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

