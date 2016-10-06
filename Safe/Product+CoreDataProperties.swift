//
//  Product+CoreDataProperties.swift
//  Safe
//
//  Created by 許佳航 on 2016/10/6.
//  Copyright © 2016年 許佳航. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Product {

    @NSManaged var address: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?

}
