//
//  ViewController.swift
//  EMDb
//
//  Created by Eugenio Barquín on 12/6/17.
//  Copyright © 2017 Eugenio Barquín. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let remote = RemoteiTunesMovieService()
        remote.getTopMovies { (result) in
            if let result = result {
                print(result)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

