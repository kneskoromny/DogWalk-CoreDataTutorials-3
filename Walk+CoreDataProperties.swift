//
//  Walk+CoreDataProperties.swift
//  DogWalk
//
//  Created by Кирилл Нескоромный on 14.08.2021.
//  Copyright © 2021 Razeware. All rights reserved.
//
//

import Foundation
import CoreData


extension Walk {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Walk> {
        return NSFetchRequest<Walk>(entityName: "Walk")
    }

    @NSManaged public var date: Date?
    @NSManaged public var dog: Dog?

}

extension Walk : Identifiable {

}
