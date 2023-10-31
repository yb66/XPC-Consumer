# XPC Consumer

## What is it?

Some code to consume the XPC events that LaunchAgent will fire when plugging in a USB device to a Mac.

## Why?

I was trying to get a launchagent to watch for when my iPhone was plugged in via USB. It turns out you need to use XPC events. Unfortunately, they will repeatedly fire, every 10 seconds. I found that [someone had helpfully supplied some Objective-C](https://github.com/snosrap/xpc_set_event_stream_handler/tree/master) that would consume the event. However, on my system at least, what it actually did was not consume the event but get stuck waiting for a semaphore that was never going to fire. This meant that only one event fired but also that unplugging and then later plugging in again wouldn't fire a new event as it was still stuck on that first event's semaphore.

So, with the help of ChatGPT (which was quite the unhelpful helper, for some reason) I have written some Swift that, on my system at least, will consume the event and allow for the device to be plugged/unplugged and still fire new events.

I'm not a Swift programmer so this may or may not be idiomatic, or even any good. Feel free to use this code or suggest improvements.

## How to compile

I use `swiftc xpc_consumer.swift -o xpc-consumer`. Then I `sudo mv xpc-consumer /usr/local/bin/`.

## How to use / setting up

I've provided an [example plist](example.plist). Do take a look first and change the placeholder values to the right things for your system.

To get the idProduct and IOProviderClass integers, plug in the device you want to watch for and then run `system_profiler SPUSBDataType` on the command line. Somewhere in that output are the Product ID and Vendor ID you need. They'll be in hex so you need to convert them to an int. (You can use `ruby -e 'puts "Product ID #{PRODUCT_ID}, Vendor ID #{VENDOR_ID}"'`, just plug those hex values in.)

### Write a script

You need to write a script and save it somewhere for the xpc-consumer to run when it receives an event. Make sure it's executable with `chmod +x`.

### Place the plist

Copy the changed plist to `~/Library/LaunchAgents/`

### Create log files

I don't trust launchctl to get this right so I do it. Replace PROJECTNAME above with the one you used in the plist!

```shell
touch $HOME/Library/Logs/PROJECTNAME/PROJECTNAME-stderr.log $HOME/Library/Logs/PROJECTNAME/PROJECTNAME-stdout.log
```

### Run the LaunchAgent

```shell
launchctl bootstrap gui/$(id -u $(whoami)) ~/Library/LaunchAgents/PROJECTNAME.plist
```

***Again, replace PROJECTNAME above with the one you used in the plist.***


### Check it's running okay

```shell
launchctl list | grep 'PROJECTNAME'
```

### Tail the logs

First time running this, I'd do this just to be sure it's working:

```shell
tail -f $HOME/Library/Logs/PROJECTNAME/PROJECTNAME-stderr.log $HOME/Library/Logs/PROJECTNAME/PROJECTNAME-stdout.log &
```

### Plug in the device

You should see stuff appear in the logs.

## That's it.

I hope that helps.

## Licence

See LICENCE.txt



