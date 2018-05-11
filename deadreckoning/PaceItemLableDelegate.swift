//
//  PaceItemLableDelegate.swift
//  DeadReckoning
//
//  Created by Amandeep Singh on 5/10/18.
//  Copyright © 2018 Echelon Front. All rights reserved.
//

import Foundation
protocol PaceItemLableDelegate: class {
    func itemPrint(by controller: PaceVC, with pace: String)
}
