import Foundation
import Dispatch

let version = "1.1.1"

if CommandLine.argc == 2 && 
		CommandLine.arguments[1].starts(with: "-") {
	let mainArg = CommandLine.arguments[1]
	let help = """
This program will consume an XPC event and then 
run the shell script given as the first argument.
The <event-label> is the key you use in the 
LaunchAgent's plist, e.g.

<key>com.apple.iokit.matching</key>
    <dict>
      <key>logseq-sync.usb.event</key>

Thus, in this case the event-label would be
logseq-sync.usb.event

Usage:
	xpc-consumer PATH/TO/SCRIPT <event-label>
	xpc-consumer (-v|--version)
	xpc-consumer (-h|--help)
"""
	
	if mainArg == "-h" || mainArg == "--help" {
		print(help)
	} else if mainArg == "-v" || mainArg == "--version" {
		print("Version \(version)")
	} else {
		print(help)
	}
	exit(0)
} else if CommandLine.argc == 3 {
	let date = Date()
	NSLog("MyXPCConsumer \(version) is running at \(date)")

	let scriptArg = CommandLine.arguments[1]
	let eventArg = CommandLine.arguments[2]
	NSLog("scriptArg = \(scriptArg)")
	NSLog("eventArg = \(eventArg)")

	if let eventLabel = eventArg.cString(using: .utf8) {
		let eventStreamHandler: xpc_handler_t = { dict in
			NSLog("MyXPCConsumer eventStreamHandler called")

			if xpc_dictionary_get_string(dict, eventLabel) != nil {
				NSLog("MyXPCConsumer logseq-sync.usb.event event handler fired")
			} else {
				NSLog("MyXPCConsumer event handler fired but not logseq-sync.usb.event so skipping")
				// Either consume the event
				// or reach here and ignore the event if
				// it's not the one we want
				return
			}
		}
		xpc_set_event_stream_handler("com.apple.iokit.matching", nil, eventStreamHandler)
	}

	if let command = scriptArg.cString(using: .utf8) {
		execv(command, [nil])
	}
}


