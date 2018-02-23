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
	
	let socket: Socket
	
	
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
			fatalError("invalid URL")
		}
		self.socket = Socket(url: url)
		socket.enableLogging = false
	}
	
	public var isConnected: Bool {
		return socket.isConnected
	}
	
	public func channel(topic: String, deviceID: Int?, onJoin: (@escaping (Socket.Payload) -> Void)) {
		let payload = deviceID.flatMap { ["device_id": $0] } ?? [:]
		let channel = self.socket.channel(topic, payload: payload)
		channel.join()?.receive("ok", callback: { (payload) in
			onJoin(payload)
		}).receive("error", callback: { (payload) in
			print(payload)
		})
		
	}
	
	public func connect(onConnect: (@escaping () -> Void), onDisconnect: ((Error?) -> ())? = nil) {
		socket.onConnect = onConnect
		socket.onDisconnect = onDisconnect ?? { error in
			
		}
		socket.connect()

	}
	
	public func disconnect() {
		socket.disconnect()
	}
	
	public func addCallback(topic: String, event: String, closure: @escaping (Response) -> Void) {
		
		var channel: Channel
		
		if let subscribedChannel = socket.channels[topic] {
			channel = subscribedChannel
			channel.on(event, callback: closure)
		}
	}
	
	public func addPresenceStateCallback(topic: String, onStateChange: @escaping ((Presence.PresenceState) -> Void)) {
		guard let channel = socket.channels[topic] else {
			return
		}
		// Presence support.
		channel.presence.onStateChange = onStateChange
		
		channel.onPresenceUpdate { (presence) in
//			print(presence.firstMetas())
		}
		
		channel.presence.onJoin = { id, meta in
		}
		
		channel.presence.onLeave = { id, meta in
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
		let channel = socket.channels[topic]
		channel?.send("update-presence-meta", payload: payload)
	}
	
	public func send(_ updatingEvent: Updating, to topic: String) {
		let payload: Socket.Payload = [
			"last_active_at": updatingEvent.lastActiveAt.timeIntervalSince1970,
			"is_updating": updatingEvent.isUpdating
		]
		
		push(to: topic, payload: payload)
	}
	
	public func send(_ typingEvent: Typing, to topic: String) {
		let payload: Socket.Payload = [
			"last_active_at": typingEvent.lastActiveAt.timeIntervalSince1970,
			"is_typing": typingEvent.isTyping
		]
		
		push(to: topic, payload: payload)
	}
	
	public func send(_ foregroundViewingEvent: ForegroundViewing, to topic: String) {
		let payload: Socket.Payload = [
			"last_active_at": foregroundViewingEvent.lastActiveAt.timeIntervalSince1970,
			"is_foreground": foregroundViewingEvent.isForeground,
			"is_viewing": foregroundViewingEvent.isViewing
		]
		
		push(to: topic, payload: payload)
	}
	
	public func sendViewingEvent(to topic: String) {
		
	}
}
