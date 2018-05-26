//
//  DataController.swift
//  VirtualToursit(V1)
//
//  Created by Guneet Garg on 09/05/18.
//  Copyright © 2018 Guneet Garg. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataController {
    
    let persistantContainer : NSPersistentContainer
    
    init (modelName : String) {
        persistantContainer = NSPersistentContainer(name : modelName)
    }
    
    var viewContext : NSManagedObjectContext {
        return persistantContainer.viewContext
    }
    
    func load (completion : (() -> Void)? = nil) {
        persistantContainer.loadPersistentStores { (storeDescription , error) in
            if error !=  nil {
                print (error!.localizedDescription)
            }
            completion? ()
        }
    }
}
