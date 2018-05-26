//
//  Networking.swift
//  VirtualToursit(V1)
//
//  Created by Guneet Garg on 09/05/18.
//  Copyright © 2018 Guneet Garg. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class Networking {
    
    var pins : Pin!
    var dataController : DataController!
    var longitude : Double
    var latitude : Double
    
    init (incomingPins : Pin , incomingDataController : DataController) {
        pins = incomingPins
        dataController = incomingDataController
        longitude = pins.long
        latitude = pins.lat
        print(latitude)
        print(longitude)
    }
    
    func getURL () -> URL {
        let maxlong = max(longitude-1.0,-180.0)
        let maxlat = max(latitude-1.0,-90.0)
        let minlong = min(longitude+1.0,180.0)
        let minlat = min(latitude+1.0,90.0)
        let boxString : String = "\(maxlong),\(maxlat),\(minlong),\(minlat)"
        print(boxString)
        var url = URLComponents()
        url.scheme = Constants.Flickr.scheme
        url.host = Constants.Flickr.host
        url.path = Constants.Flickr.path
        url.queryItems = [URLQueryItem] ()
        let parameters = [ Constants.ParameterKeys.ApiKey : "9709edd7a91a2980a940eeccfd0672fb",
                           Constants.ParameterKeys.Method : "flickr.photos.search",
                           Constants.ParameterKeys.Extras : "url_m",
                           Constants.ParameterKeys.Format : "json",
                           Constants.ParameterKeys.SafeSearch : "1",
                           Constants.ParameterKeys.NoJSONCallback : "1",
                           Constants.ParameterKeys.BoundingBox : boxString
        ]
        for (key,values) in parameters {
            let queryItem = URLQueryItem (name : key, value : values)
            url.queryItems?.append(queryItem)
        }
        return url.url!
    }
    
    func fetchPhotos (completitionHandle : @escaping() -> ()?) {
        print("Photos being fetched from Flickr")
        URLSession.shared.dataTask (with : getURL()) { (data , response, error) in
            print(data!)
            print(response!)
        if error != nil && data != nil{
            print ("There was an error fetching!!!")
        } else {
            print("There was no error")
            let result : [String : AnyObject]!
            do {
                try result = JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : AnyObject]
                print (data!)
                print (result)
                if let dictionary = result["photos"] as? [String : AnyObject] , let array = dictionary["photo"] as? [[String : AnyObject]] {
                    print(dictionary)
                    print(array)
                    
                    for _ in 0...9 {
                        let number = Int(arc4random_uniform(UInt32((array.count)+7)))
                        print(number)
                        let imageURL = array[number]["url_m"] as! String
                        self.saveImageToContext(urlString : imageURL)
                    }
                    completitionHandle()
                } else {
                    print ("Couldnt get photos")
                }
            }
            catch {
                print ("There was an error parsing the data!!!")
            }
            }}.resume ()
    }
    
    func saveImageToContext(urlString : String) {
        let photo = Photo (context : dataController.viewContext)
        photo.pin = pins
        photo.url = urlString
        try? dataController.viewContext.save ()
    }
    
}
