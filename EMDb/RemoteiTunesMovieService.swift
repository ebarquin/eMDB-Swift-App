//
//  RemoteiTunesMovieService.swift
//  EMDb
//
//  Created by Eugenio Barquín on 12/6/17.
//  Copyright © 2017 Eugenio Barquín. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class RemoteiTunesMovieService {
    
    func getTopMovies(completionHandler: @escaping ([[String:String]]?) -> Void) {
        
        let url = URL(string:"https://itunes.apple.com/es/rss/topmovies/limit=99/json")!
        
        //http request with Alamofire
        Alamofire.request(url, method: .get).validate().responseJSON() { response in
            
            switch response.result {
            case .success:
                if let value = response.result.value {
                    
                    let json = JSON(value)
                    
                    var result = [[String:String]]()
                    
                    let entries = json["feed"]["entry"].arrayValue
                    
                    for entry in entries {
                        
                        var movie = [String: String]()
                        movie["id"] = entry["id"]["attributes"]["im:id"].stringValue
                        movie["title"] = entry["im:name][label"].stringValue
                        movie["summary"] = entry["sumary"]["label"].stringValue
                        movie["image"] = entry["im:image"][0]["label"].stringValue.replacingOccurrences(of: "60x60", with: "500x500")
                        movie["category"] = entry["category"]["attributes"]["label"].stringValue
                        movie["director"] = entry["im:artist"]["label"].stringValue
                        result.append(movie)
                    }
                    
                    completionHandler(result)
                    
                }
            case .failure (let error):
                print(error)
                completionHandler(nil)
            }
        }
        
    }
}
