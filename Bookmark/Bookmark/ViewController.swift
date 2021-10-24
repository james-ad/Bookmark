//
//  ViewController.swift
//  Bookmark
//
//  Created by James Dunn on 10/19/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var captureButton: UIButton!
    @IBOutlet var bookmarkedQuote: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureButton.sizeToFit()
    }


}

