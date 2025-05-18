//
//  user+CoreDataProperties.swift
//  CUYPAY
//
//  Created by DAMII on 28/04/25.
//
//

import Foundation
import CoreData


extension user {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<user> {
        return NSFetchRequest<user>(entityName: "User")
    }

    @NSManaged public var id: Int16

}

extension user : Identifiable {

}
