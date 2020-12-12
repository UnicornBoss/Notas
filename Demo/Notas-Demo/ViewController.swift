//
//  ViewController.swift
//  Notas-Demo
//
//  Created by Archy on 2020/11/22.
//

import UIKit
import Notas

class ViewController: UIViewController {

    lazy var textView: Notas = {
        let textView = Notas(frame: CGRect(x: 15, y: 44, width: view.bounds.width - 30, height: 300), textContainer: NSTextContainer())
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(textView)
    }
    @IBAction func orderAction(_ sender: Any) {
        textView.convertToList(isOrdered: true, listPrefix: "1. ")
    }
    
    @IBAction func unorderAction(_ sender: Any) {
        textView.convertToList(isOrdered: false, listPrefix: "- ")
    }
        
}

