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
				
				print(payload)
			}
		}
		
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

