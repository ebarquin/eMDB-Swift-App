//
//  MovieManaged+Mapping.swift
//  EMDb
//
//  Created by Eugenio Barquín on 12/6/17.
//  Copyright © 2017 Eugenio Barquín. All rights reserved.
//

import Foundation

extension MovieManaged {
    
    func mappedObject() -> Movie {
        return Movie(id: self.id, title: self.title, order: Int(self.order), summary: self.summary, image: self.image, category: self.category, director: self.director)
        
    }
}
