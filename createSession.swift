import Foundation
import Files
import Unbox
import Commander
import Environment

public func convertToBase64(_ str: String) -> String {
	if let data = str.data(using: String.Encoding.utf8) {
		return data.base64EncodedString()
	}
	else {
		return ""
	}
}

let userAgent = "Marathon"

func writeScriptFile(exportFlag: Bool, sessionID: String, userAgent: String, presenceChannel: String) throws {
	if exportFlag {
		let currentFolder = Folder.current
		let scriptFile = try currentFolder.createFileIfNeeded(withName: "kayako-env-vars.sh")
		
		let scriptData = "export KAYAKO_SESSION=\(sessionID)\n export KAYAKO_USER_AGENT=\(userAgent)\n export PRESENCE_CHANNEL=\(presenceChannel)\n export KAYAKO_URL=kayako-mobile-testing.kayako.com \n export KAYAKO_EMAIL=robin.malhotra@kayako.com"
		try scriptFile.write(string: scriptData)
	}
}

Group {
	let loginCommand = command(
		Option("email", "", description: "Your Kayako Email"),
		Option("password", "", description: "Your password"),
		Option("url", "", description: "Your Kayako URL"),
		Flag("export", flag: "g", disabledName: nil, disabledFlag: nil, description: "automatically generates a script with export values", default: false)
	) { email, password, url, exportFlag in
		let folder = Folder.home
		let currentTimeStamp = Date().timeIntervalSinceReferenceDate
		let sessionsFolder = try folder.createSubfolderIfNeeded(withName: ".kayako-session")
		
		if let lastRunFile = try? sessionsFolder.file(named: ".lastRun") {
			let lastRunTimestamp = try TimeInterval(lastRunFile.readAsInt())
			let threeHourInterval: TimeInterval = 60 * 60 * 3
			let delta = currentTimeStamp - lastRunTimestamp
			
			if delta < threeHourInterval {
				let sessionFile = try sessionsFolder.file(named: "sessionID.txt")
				let fileData = try sessionFile.readAsString()
				print(fileData)
				exit(0)
			}
		}
		
		let sem = DispatchSemaphore.init(value: 0)
		
		var request = URLRequest(url: URL(string: "https://\(url)/api/v1/session?include=user")!)
		request.addValue("Basic \(convertToBase64("\(email):\(password)"))", forHTTPHeaderField: "Authorization")
		request.addValue("false", forHTTPHeaderField: "X-CSRF")
		request.addValue("Marathon", forHTTPHeaderField: "User-Agent")
		
		URLSession.shared.dataTask(with: request) { (data, response, error) in
			if let data = data {
				do {
					let unboxer = try Unboxer.init(data: data)
					let sessionID: String = try unboxer.unbox(key: "session_id")
					
					let fileString = "\(sessionID)"
					print(fileString)
					let sessionFile = try sessionsFolder.createFile(named: "sessionID.txt")
					try sessionFile.write(string: fileString)
					
					let lastRunFile = try sessionsFolder.createFile(named: ".lastRun")
					try lastRunFile.write(string: String(Int(currentTimeStamp)))
					
					let presenceChannel: String = try unboxer.unbox(keyPath: "data.user.presence_channel")
					
					try writeScriptFile(exportFlag: exportFlag, sessionID: sessionID, userAgent: userAgent, presenceChannel: presenceChannel)
					
				} catch {
					print("💥 Invalid response. Printing JSON down below 👇")
					let json = try! JSONSerialization.jsonObject(with: data, options: [])
					let prettyJson = try! JSONSerialization.data(withJSONObject: json, options:JSONSerialization.WritingOptions.prettyPrinted )
					if let prettyString = String(data: prettyJson, encoding: String.Encoding.utf8) {
						print(prettyString)
					}
					
				}
			}
			if let error = error {
				print("💥")
				print("error: \(error)")
			}
			sem.signal()
			}.resume()
		
		
		sem.wait()
		
	}
	
	$0.addCommand("login", loginCommand)
	
	$0.command("env", {
		print("setting env var")
		Env["ROBIN"] = "robin"
		print("Set")
	})
	
	$0.command("clear") {
		print("Clearing Data...")
		let sessionFolder = try Folder.home.subfolder(named: ".kayako-session")
		try sessionFolder.delete()
		print("Cleared 🗑")
	}
	}.run()


