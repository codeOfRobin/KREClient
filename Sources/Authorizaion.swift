//
//  Authorizaion.swift
//  KREClient-iOS
//
//  Created by Robin Malhotra on 25/08/17.
//  Copyright © 2017 Kayako. All rights reserved.
//

import Foundation

public enum Authorization {
	case session(sessionID:String, userAgent: String, email: String?)
	case fingerprints(fingerprintID: String, userInfo: UserLoginInfo?)
}

public struct UserLoginInfo {
	
	enum EmailError: Error {
		case emailNotValid
	}
	
	public struct Email {
		public let rawValue: String
		init(string: String) throws {
			if string.isEmail {
				self.rawValue = string
			} else {
				throw EmailError.emailNotValid
			}
		}
	}
	
	public let name: String
	public let email: Email
	
	public init(email: String, name: String? = nil) throws {
		self.email = try Email(string: email)
		if let name = name {
			self.name = name
		} else {
			guard let name = email.components(separatedBy: "@").first else {
				throw EmailError.emailNotValid
			}
			self.name = name
		}
	}
}
