//
//  LocalCoreDataService.swift
//  EMDb
//
//  Created by Eugenio Barquín on 12/6/17.
//  Copyright © 2017 Eugenio Barquín. All rights reserved.
//

import Foundation
import CoreData

class LocalCoredataService {
    
    let remoteMovieService = RemoteiTunesMovieService()
    let stack = CoreDataStack.sharedInstance
    
    func searchMovies(byTerm: String, remoteHandler: @escaping ([Movie]?) -> Void) {
        
        remoteMovieService.searchMovies(byTerm: byTerm) { movies in
            
            if let movies = movies {
                
                var modelMovies = [Movie]()
                for movie in movies {
                    let modelMovie = Movie(id: movie["id"], title: movie["title"], order: nil, summary: movie["summary"], image: movie["image"], category: movie["category"], director: movie["director"])
                    modelMovies.append(modelMovie)
                }
                remoteHandler(modelMovies)
                
                
            } else {
                print("Error while calling REST services")
                remoteHandler(nil)
            }
        }
    }
    //Initially when someone calls to getTopMovies will receibe the answer from CoreData (localHandler) and a few seconds after will reload with remote data (remoteHandler)
    func getTopMovies(localHandler:([Movie]?) -> Void, remoteHandler:@escaping ([Movie]?) -> Void) {
        
        //get the local data
        localHandler(self.queryTopMovies())
        
        //get the remote data
        remoteMovieService.getTopMovies() { movies in
            
            if let movies = movies {
                
                self.markAllMoviesAsUnsync()
                
                //we don't receive the order from remote data so in each iteration
                var order = 1
                
                for movieDictionary in movies {
                    
                    if let movie = self.getMovieById(id: movieDictionary["id"]!, favorite: false) {
                        //updateMovie
                        self.updateMovie(moviDictionary: movieDictionary, movie: movie, order: order)
                    } else {
                        //insertMovie
                        self.insertMovie(movieDictionary: movieDictionary, order: order)
                    }
                    order += 1
                }
                
                //Remove all not favorites and old movies
                self.removeOldNotFavoritedMovies()
                
                remoteHandler(self.queryTopMovies())
                
            } else {
                remoteHandler(nil)
            }
            
        }
        
        
    }
    
    func queryTopMovies() -> [Movie]? {
        
        let context = stack.persistentContainer.viewContext
        let request : NSFetchRequest<MovieManaged> = MovieManaged.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        let predicate = NSPredicate(format: "favorite = \(false)")
        request.predicate = predicate
        
        do {
            
            let fetchedMovies = try context.fetch(request)
            
            var movies = [Movie]()
            for managedMovie in fetchedMovies {
                movies.append(managedMovie.mappedObject())
            }
            return movies
            
            
        } catch {
            print("Error while getting movies from Core Data")
            return nil
        }
        
        
    }
    
    func markAllMoviesAsUnsync() {
        let context = stack.persistentContainer.viewContext
        let request : NSFetchRequest<MovieManaged> = MovieManaged.fetchRequest()
        
        
        //let predicate = NSPredicate(format: "favorite = \(false)")
        //request.predicate = predicate
        
        do {
            let fetchedMovies = try context.fetch(request)
            
            for managedMovie in fetchedMovies {
                managedMovie.sync = false
               
            }
            try context.save()
            
            
        } catch {
            print("Error while updating movies from Core Data")

        }

    }
    
    func getMovieById(id: String, favorite: Bool) -> MovieManaged? {
        
        let context = stack.persistentContainer.viewContext
        let request : NSFetchRequest<MovieManaged> = MovieManaged.fetchRequest()
        
        let predicate = NSPredicate(format:"id = \(id) and favorite = \(favorite)")
        request.predicate = predicate
        
        do {
            let fetchedMovies = try context.fetch(request)
            if fetchedMovies.count > 0 {
                return fetchedMovies.last
            } else {
                return nil
            }
            
        } catch {
            print("Error while getting movie from Core Data")
            return nil
            
        }
    }
    func insertMovie(movieDictionary: [String:String], order: Int) {
        
        let context = stack.persistentContainer.viewContext
        let movie = MovieManaged(context: context)
        
        movie.id = movieDictionary["id"]
        
        updateMovie(moviDictionary: movieDictionary, movie: movie, order: order)
    }
    
    func updateMovie(moviDictionary: [String:String], movie: MovieManaged, order: Int) {
        
        let context = stack.persistentContainer.viewContext
        
        movie.order = Int16(order)
        movie.title = moviDictionary["title"]
        movie.summary = moviDictionary["summary"]
        movie.category = moviDictionary["category"]
        movie.director = moviDictionary["director"]
        movie.image = moviDictionary["image"]
        movie.sync = true
        
        do {
            try context.save()
        } catch {
            print("Error while updating Core Data")
        }
       
    }
    func removeOldNotFavoritedMovies() {
        
        let context = stack.persistentContainer.viewContext
        let request : NSFetchRequest<MovieManaged> = MovieManaged.fetchRequest()
        
        let predicate = NSPredicate(format: "favorite = \(false)")
        request.predicate = predicate
        
        do {
            let fetchedMovies = try context.fetch(request)
            for managedMovie in fetchedMovies {
                if !managedMovie.sync {
                    context.delete(managedMovie)
                }
            }
            try context.save()
            
        } catch {
            print("Error while deleting from Core Data")
        }
        
    }
}
