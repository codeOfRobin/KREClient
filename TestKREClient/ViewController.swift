//
//  ViewController.swift
//  TestKREClient
//
//  Created by Robin Malhotra on 25/08/17.
//  Copyright © 2017 Kayako. All rights reserved.
//

import UIKit
import KREClient

class ViewController: UIViewController {

	let kreClient = KREClient(instance: testCreds.url, auth: .session(sessionID: testCreds.sessionID, userAgent: testCreds.userAgent, email: testCreds.email))
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		kreClient.connect { [weak self] in
			print("connected")
			self?.kreClient.channel(topic: testCreds.presenceChannel, deviceID: nil) {
				payload in
			}
			
			
			let sampleCase = "presence-61485139915436ab6fc57ca6b1e0bc87f58649bc427077133b6e71a278c3e8a2@v1_cases_560"
			
			self?.kreClient.channel(topic: sampleCase, deviceID: nil, onJoin: { (payload) in
				
				self?.kreClient.addPresenceStateCallback(topic: sampleCase) { (state) in
					print(state)
				}
				
				self?.kreClient.addChangeCallback(topic: sampleCase) { (payload) in
				}
				
				self?.kreClient.send(ForegroundViewing(isViewing: true, isForeground: true, lastActiveAt: Date()), to: sampleCase)
				
				self?.kreClient.send(Typing.init(isTyping: true, lastActiveAt: Date()), to: sampleCase)
				
				self?.kreClient.send(Updating.init(isUpdating: true, lastActiveAt: Date()), to: sampleCase)
			})
		}
		
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

