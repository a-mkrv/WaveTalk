//
//  PageContentViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 19.11.16.
//  Copyright © 2016 Anton Makarov. All rights reserved.
//

import UIKit

class PageContentViewController: UIViewController {

    @IBOutlet weak var imageName: UIImageView!
    @IBOutlet weak var headerName: UILabel!
    @IBOutlet weak var descriptionName: UILabel!
    
    var pageIndex: Int?
    var headerTxt: String?
    var descriptionTxt: String?
    var imageTxt: String?
    var pageControl: UIPageControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageName.image = UIImage(named: imageTxt!)!
        headerName.text = headerTxt
        descriptionName.text = descriptionTxt
        
        self.parent!.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 200)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pageControl!.currentPage = pageIndex!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
