//
//  ViewController.swift
//  TestKREClient
//
//  Created by Robin Malhotra on 25/08/17.
//  Copyright © 2017 Kayako. All rights reserved.
//

import UIKit
import KREClient
import Unbox

class ViewController: UIViewController {

	static let kreClient = KREClient(instance: testCreds.url, auth: .session(sessionID: testCreds.sessionID, userAgent: testCreds.userAgent, email: testCreds.email))
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		ViewController.kreClient.connect(onConnect: { [weak self] in
			print("connected")
			ViewController.kreClient.channel(topic: testCreds.presenceChannel, deviceID: nil) {
				payload in
			}
			
			
			let sampleCase = "presence-61485139915436ab6fc57ca6b1e0bc87f58649bc427077133b6e71a278c3e8a2@v1_cases_560"
			
			ViewController.kreClient.channel(topic: sampleCase, deviceID: nil, onJoin: { (payload) in
				
				ViewController.kreClient.addPresenceStateCallback(topic: sampleCase) { (state) in
					let users = state.map{ $0.value }
					let metas = users.flatMap{ $0.first }
					let viewingUsers = metas.filter{ $0["is_viewing"] as? Int == 1 }
					let avatarURLs: [URL] = try! viewingUsers.map {
						dict -> URL in
						let unboxer = Unboxer.init(dictionary: dict)
						let avatarURL: String = try unboxer.unbox(keyPath: "user.avatar")
						return URL(string: avatarURL)!
					}
					print(avatarURLs)
				}
				
				ViewController.kreClient.addChangeCallback(topic: sampleCase) { (payload) in
				}
				
				ViewController.kreClient.send(ForegroundViewing(isViewing: true, isForeground: true, lastActiveAt: Date()), to: sampleCase)
				
				ViewController.kreClient.send(Typing.init(isTyping: true, lastActiveAt: Date()), to: sampleCase)
				
				ViewController.kreClient.send(Updating.init(isUpdating: true, lastActiveAt: Date()), to: sampleCase)
			})
		}) { (error) in
			print(error)
		}
		
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

