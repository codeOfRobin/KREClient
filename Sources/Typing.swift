//
//  ClientTyping.swift
//  KREClient-iOS
//
//  Created by Robin Malhotra on 03/10/17.
//  Copyright © 2017 Kayako. All rights reserved.
//

import Foundation

public struct Typing {
	let isTyping: Bool
	let lastActiveAt: Date
	
	public init(isTyping: Bool, lastActiveAt: Date) {
		self.isTyping = isTyping
		self.lastActiveAt = lastActiveAt
	}
}
