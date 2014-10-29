//
//  main.m
//  Echostar VPN
//
//  Created by Monty on 10/29/14.
//  Copyright (c) 2014 echostar. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppleScriptObjC/AppleScriptObjC.h>

int main(int argc, const char * argv[]) {
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
    return NSApplicationMain(argc, argv);
}
