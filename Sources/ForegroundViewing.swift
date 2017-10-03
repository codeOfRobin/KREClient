//
//  ForegroundViewing.swift
//  KREClient-iOS
//
//  Created by Robin Malhotra on 03/10/17.
//  Copyright © 2017 Kayako. All rights reserved.
//

import Foundation

public struct ForegroundViewing {
	let isViewing: Bool
	let isForeground: Bool
	let lastActiveAt: Date
	
	public init(isViewing: Bool, isForeground: Bool, lastActiveAt: Date) {
		self.isViewing = isViewing
		self.isForeground = isForeground
		self.lastActiveAt = lastActiveAt
	}
}
