--
--  AppDelegate.applescript
--  Echostar VPN
--
--  Created by Monty on 10/29/14.
--  Copyright (c) 2014 echostar. All rights reserved.
--

script AppDelegate
    property parent : class "NSObject"
    
    -- IBOutlets
    property theWindow : missing value
    
    -- App Properties - Monty
    property vpnTextLabel : missing value
    property vpnTimeLabel : missing value
    property vpnStatusImage : missing value
    property btnConnect : missing value
    property btnDisconnect : missing value
    
    on applicationWillFinishLaunching_(aNotification)
        -- Kill snx if it is already running.
        try
            set vpnStatus to do shell script "ps ax | grep snx | grep -v grep"
            do shell script "snx -d"
            on error
            log "snx is not running"
        end try
        setImageForStatus_(0)
        
    end applicationWillFinishLaunching_
    
    on setImageForStatus_(status)
        if status = 1 then
            set imageName to current application's NSImageNameStatusAvailable
            else
            set imageName to current application's NSImageNameStatusUnavailable
        end if
        
        vpnStatusImage's setImage_(current application's NSImage's imageNamed_(imageName))
    end setImageForStatus_
    
    -- Connect Button
    on btnConnect_(sender)
        -- Update the status label
        vpnTextLabel's setStringValue_("Initializing VPN Interface")
        
        set vpnServer to "eaccess.echostar.com"
        -- set vpnUser to ""
        -- set vpnPassword to ""
        
        -- Get the users password
        set currentUser to (short user name of (system info))
        display dialog "Enter your Echostar username" default answer currentUser
        set the vpnUser to the text returned of the result
        display dialog "Enter your Echostar password" default answer "" with hidden answer
        set the vpnPassword to the text returned of the result
        
        -- Connect to the Echostar VPN
        do shell script ("expect -c 'spawn -ignore HUP /bin/sh -c \"snx -s " & vpnServer & " -u " & vpnUser & "\"; expect \"*?assword:*\"; send \"" & vpnPassword & "\"; send \"\\r\";expect \"24 hours\"' > /tmp/vpn.status 2>&1")
        
        -- Wait a bit for the connection to establish
        delay 5
        
        -- Display the results
        try
            set vpnStatus to (do shell script "tail -n 9 /tmp/vpn.status")
            vpnTextLabel's setStringValue_(vpnStatus)
            on error
            vpnTextLabel's setStringValue_("Error: Can't 'tail -n 9 /tmp/vpn.status'")
        end try
        
        try
            set theTime to (do shell script "date")
            vpnTimeLabel's setStringValue_("Connected on " & theTime)
        end try
        setImageForStatus_(1)
    end btnConnect_
    
    -- Disconnect Button
    on btnDisconnect_(sender)
        -- Update the status label
        vpnTextLabel's setStringValue_("Disconnecting VPN Interface")
        try
            -- kill the vpn connection
            do shell script "snx -d"
            on error
            vpnTextLabel's setStringValue_("Error: 'snx -d' failed")
        end try
        
        -- Delete the vpn.status file
        try
            do shell script "rm /tmp/vpn.status"
            on error
            vpnTextLabel's setStringValue_("Error: Can't 'rm /tmp/vpn.status'")
            
        end try
        
        -- Update the status label
        
        vpnTextLabel's setStringValue_("VPN Disconnected. \n\nClick 'Connect' to reconnect")
        vpnTimeLabel's setStringValue_("Currently disconnected")
        setImageForStatus_(0)
    end btnDisconnect_
    
    on applicationShouldTerminate_(sender)
        -- Insert code here to do any housekeeping before your application quits
        
        -- kill the vpn connection
        do shell script "snx -d"
        
        -- Delete the vpn.status file
        try
            do shell script "rm /tmp/vpn.status"
            on error
            log "No file to remove"
        end try
        
        
        return current application's NSTerminateNow
    end applicationShouldTerminate_
    
end script