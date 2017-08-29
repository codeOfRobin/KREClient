//
//  KREClient.swift
//  Kayako
//
//  Created by Robin Malhotra on {TODAY}.
//  Copyright © 2017 Kayako. All rights reserved.
//

import Foundation
import Birdsong
import Unbox



public class KREClient {
	
	let instance: String
	let auth: Authorization
	let vsn = "1.0.0"
	
	var socket: Socket?
	
	public init(instance: String, auth: Authorization) {
		self.auth = auth
		self.instance = instance
	
		guard case .session(let sessionID, let userAgent, _) = auth else {
			fatalError()
		}
		
		let instance = URLQueryItem(name: "instance", value: instance)
		let session = URLQueryItem(name: "session_id", value: sessionID)
		let userAgentQueryItem = URLQueryItem(name: "user_agent", value: userAgent)
		let vsn = URLQueryItem(name: "vsn", value: "1.0.0")
		
		var components = URLComponents(string: "wss://kre.kayako.net/socket/websocket")
		components?.queryItems = {
			return [session, userAgentQueryItem, vsn, instance]
		}()
		guard let url = components?.url else {
			return
		}
		
		socket = Socket(url: url)
		socket?.enableLogging = true
		
	}
	
	public func channel(topic: String, deviceID: Int?, onJoin: (@escaping (Socket.Payload) -> Void)) {
		let channel = self.socket?.channel(topic, payload: [:])
		channel?.join()?.receive("ok", callback: { (payload) in
			onJoin(payload)
		})
		
	}
	
	public func connect(onConnect: (@escaping () -> Void)) {
		socket?.onConnect = onConnect
		socket?.connect()
		socket?.onDisconnect = {
			[weak self] error in
			self?.socket?.connect()
		}
	}
	
	public func addCallback(topic: String, event: String, closure: @escaping (Response) -> Void) {
		
		var channel: Channel
		
		if let subscribedChannel = socket?.channels[topic] {
			channel = subscribedChannel
			channel.on(event, callback: closure)
		}
	}
	
	public func addPresenceStateCallback(topic: String, onStateChange: @escaping ((Presence.PresenceState) -> Void)) {
		guard let channel = socket?.channels[topic] else {
			return
		}
		// Presence support.
		channel.presence.onStateChange = onStateChange
		
		
		channel.onPresenceUpdate { (presence) in
			print(presence.firstMetas())
		}
		
		channel.presence.onJoin = { id, meta in
			//			print("Join: user with id \(id) with meta entry: \(meta)")
		}
		
		channel.presence.onLeave = { id, meta in
			//			print("Leave: user with id \(id) with meta entry: \(meta)")
		}
	}
	
	public func addNewPostCallback(topic: String, closure: @escaping (_ postID: Int) -> Void) {
		self.addCallback(topic: topic, event: "NEW_POST") { (response) in
			do {
				let unboxer = Unboxer(dictionary: response.payload)
				let postID: Int = try unboxer.unbox(key: "resource_id")
				closure(postID)
			} catch {
				print("INVALID POST ID FOUND in message \(response.payload)")
			}
		}
	}
	
	public func addChangeCallback(topic: String, closure: @escaping (Socket.Payload) -> Void) {
		self.addCallback(topic: topic, event: "CHANGE") { (response) in
			closure(response.payload)
		}
	}
	
	public func addChangePostCallback(topic: String, closure: @escaping (Socket.Payload) -> Void) {
		self.addCallback(topic: topic, event: "CHANGE_POST") { (response) in
			closure(response.payload)
		}
	}
	
	func push(to topic: String, payload: Socket.Payload) {
		let channel = socket?.channels[topic]
		channel?.send("update-presence-meta", payload: payload)
	}
	
	public func sendStartTypingEvent(to topic: String) {
		
		let payload: Socket.Payload = [
			"last_active_at": Date().timeIntervalSince1970,
			"is_typing": true
		]
		
		push(to: topic, payload: payload)
	}
	
	public func sendStopTypingEvent(to topic: String) {
		
		let payload: Socket.Payload = [
			"last_active_at": Date().timeIntervalSince1970,
			"is_typing": false
		]
		
		push(to: topic, payload: payload)
	}
}
