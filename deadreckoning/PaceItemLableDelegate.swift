//
//  PaceItemLableDelegate.swift
//  DeadReckoning
//
//  Created by Yost Group LLC on 5/10/18.
//  Copyright © 2018-2026 Yost Group LLC. All rights reserved.
//

import Foundation
protocol PaceItemLableDelegate: AnyObject {
    func itemPrint(by controller: PaceVC, with pace: String)
}
