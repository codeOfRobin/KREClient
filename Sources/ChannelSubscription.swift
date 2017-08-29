//
//  ChannelSubscription.swift
//  KREClient-iOS
//
//  Created by Robin Malhotra on 25/08/17.
//  Copyright © 2017 Kayako. All rights reserved.
//

import Foundation
import Birdsong

public struct ChannelSubscription {
	
	let channelName: String
	
	var onNewPost: ((Int) -> Void)?
	var onChange: ((Response) -> Void)?
	var onPresenceStateChange: ((Presence) -> Void)?
}
