//
//  Updating.swift
//  KREClient-iOS
//
//  Created by Robin Malhotra on 03/10/17.
//  Copyright © 2017 Kayako. All rights reserved.
//

import Foundation

public struct Updating {
	let isUpdating: Bool
	let lastActiveAt: Date
	
	public init(isUpdating: Bool, lastActiveAt: Date) {
		self.isUpdating = isUpdating
		self.lastActiveAt = lastActiveAt
	}

}
