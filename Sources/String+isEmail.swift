//
//  String+isEmail.swift
//  KREClient-iOS
//
//  Created by Robin Malhotra on 25/08/17.
//  Copyright © 2017 Kayako. All rights reserved.
//

import Foundation

extension String {
	
	var isEmail: Bool {
		let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
	}
}

