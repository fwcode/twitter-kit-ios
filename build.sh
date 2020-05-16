#!/bin/bash

set -e

## Build TwitterKit.framework - x86_64
xcodebuild \
    -project TwitterKit/TwitterKit.xcodeproj \
    -scheme TwitterKit -configuration Debug \
    -sdk "iphonesimulator" \
    HEADER_SEARCH_PATHS="$(pwd)/TwitterCore/iphonesimulator/Headers $(pwd)/TwitterCore/iphonesimulator/PrivateHeaders"  \
    CONFIGURATION_BUILD_DIR=./iphonesimulator \
    clean build

## From: https://developer.apple.com/library/archive/qa/qa1940/_index.html
# If code signing fails with the error "resource fork, Finder information, or similar detritus not allowed."
#   e.g. /usr/bin/codesign --force --sign - --timestamp=none $(pwd)/TwitterCore/iphonesimulator/TwitterCore.framework
# Try:
#   xattr -lr /Users/SWARM5/Work/twitter-kit-ios-master/TwitterKit/iphonesimulator/TwitterKit.framework
#   xattr -cr /Users/SWARM5/Work/twitter-kit-ios-master/TwitterKit/iphonesimulator/TwitterKit.framework

## Build TwitterKit.framework - armv7, arm64
xcodebuild \
    -project TwitterKit/TwitterKit.xcodeproj \
    -scheme TwitterKit -configuration Debug \
    -sdk "iphoneos" \
    HEADER_SEARCH_PATHS="$(pwd)/TwitterCore/iphoneos/Headers $(pwd)/TwitterCore/iphoneos/PrivateHeaders"  \
    CONFIGURATION_BUILD_DIR=./iphoneos \
    clean build

## Merge into one TwitterKit.framework with x86_64, armv7, arm64
rm -rf iOS
mkdir -p iOS
cp -r TwitterKit/iphoneos/TwitterKit.framework/ iOS/TwitterKit.framework
lipo -create -output iOS/TwitterKit.framework/TwitterKit TwitterKit/iphoneos/TwitterKit.framework/TwitterKit TwitterKit/iphonesimulator/TwitterKit.framework/TwitterKit
lipo -archs iOS/TwitterKit.framework/TwitterKit

## Zip them into TwitterKit.zip
ZIP_FILE=TwitterKit.zip
if test -f "$ZIP_FILE"; then
    rm "$ZIP_FILE"
fi
zip -r "$ZIP_FILE" iOS/*
rm -rf iOS
