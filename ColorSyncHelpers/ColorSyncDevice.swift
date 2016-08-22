//
//  ColorSyncDevice.swift
//  ColorSyncHelpers
//
//  Created by C.W. Betts on 8/22/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

import Foundation
import ApplicationServices


public class CSDevice {
	
	public enum Scope {
		case Any
		case Current
	}
	
	public struct Profiles: CustomStringConvertible, CustomDebugStringConvertible {
		public enum DeviceClass: String {
			case Camera = "cmra"
			case Display = "mntr"
			case Printer = "prtr"
			case Scanner = "scnr"
		}
		public var identifier: NSUUID
		public var deviceDescription: String
		public var modeDescription: String
		public var profileID: String
		public var profileURL: NSURL
		public var extraEntries: [String: AnyObject]
		public var isFactory: Bool
		public var isDefault: Bool
		public var isCurrent: Bool
		public var deviceClass: DeviceClass
		
		public var description: String {
			return "\(deviceDescription), \(modeDescription) (\(deviceClass))"
		}
		
		public var debugDescription: String {
			return "CSDeviceInfo(deviceClass: \(deviceClass), identifier: \(identifier.UUIDString), deviceDescription: \"\(deviceDescription)\", modeDescription: \"\(modeDescription)\", profileID: \(profileID), profileURL: \(profileURL), isFactory: \(isFactory), isDefault: \(isDefault), isCurrent: \(isCurrent))"
		}
	}
	
	public struct Info {
		public struct FactoryProfiles {
			public struct Profile {
				var profileURL: NSURL?
				var modeDescription: String
			}
			public var defaultProfileID: String
			public var profiles: [String: Profile]
		}
		
		public var deviceClass: Profiles.DeviceClass
		public var deviceID: NSUUID
		public var deviceDescription: String
		public var factoryProfiles: FactoryProfiles
		public var customProfiles: [String: NSURL?]
		public var userScope: Scope
		public var hostScope: Scope
	}

	/// Returns a dictionary with the following keys and values resolved for the current host and current user.
	///
	///     <<
	///         kColorSyncDeviceClass                   {camera, display, printer, scanner}
	///         kColorSyncDeviceID                      {CFUUIDRef registered with ColorSync}
	///         kColorSyncDeviceDescription             {localized device description}
	///         kColorSyncFactoryProfiles  (dictionary) <<
	///                                                     {ProfileID}    (dictionary) <<
	///                                                                                     kColorSyncDeviceProfileURL      {CFURLRef or kCFNull}
	///                                                                                     kColorSyncDeviceModeDescription {localized mode description}
	///                                                                                 >>
	///                                                      ...
	///                                                     kColorSyncDeviceDefaultProfileID {ProfileID}
	///                                                 >>
	///         kColorSyncCustomProfiles  (dictionary) <<
	///                                                     {ProfileID}    {CFURLRef or kCFNull}
	///                                                     ...
	///                                                <<
	///         kColorSyncDeviceUserScope              {kCFPreferencesAnyUser or kCFPreferencesCurrentUser}
	///         kColorSyncDeviceHostScope              {kCFPreferencesAnyHost or kCFPreferencesCurrentHost}
	///     >>
	private func copyDeviceInfo(deviceClass: String, identifier: CFUUID) -> [String: AnyObject] {
		return ColorSyncDeviceCopyDeviceInfo(deviceClass, identifier).takeRetainedValue() as NSDictionary as! [String: AnyObject]
	}
	
	public func info(deviceClass dc: Profiles.DeviceClass, identifier: NSUUID) -> Info {
		//Info
		
		var devInfo = copyDeviceInfo(dc.rawValue, identifier: CFUUIDCreateFromString(kCFAllocatorDefault, identifier.UUIDString))
		let devClass: Profiles.DeviceClass
		let preDevClass = devInfo.removeValueForKey(kColorSyncDeviceClass.takeUnretainedValue() as String) as! String
		switch preDevClass {
		case kColorSyncCameraDeviceClass.takeUnretainedValue() as NSString as String:
			devClass = .Camera
			
		case kColorSyncDisplayDeviceClass.takeUnretainedValue() as NSString as String:
			devClass = .Display
			
		case kColorSyncPrinterDeviceClass.takeUnretainedValue() as NSString as String:
			devClass = .Printer
			
		case kColorSyncScannerDeviceClass.takeUnretainedValue() as NSString as String:
			devClass = .Scanner
			
		default:
			fatalError("Unknown device class \(preDevClass)")
		}
		let devID = devInfo.removeValueForKey(kColorSyncDeviceID.takeUnretainedValue() as String) as! CFUUID
		let devDes = devInfo.removeValueForKey(kColorSyncDeviceDescription.takeUnretainedValue() as String) as! String
		var factProf = devInfo.removeValueForKey(kColorSyncDeviceDescription.takeUnretainedValue() as String) as! NSDictionary as! [String: AnyObject]
		let defaultID = factProf.removeValueForKey(kColorSyncDeviceDefaultProfileID.takeUnretainedValue() as String) as! String
		var ahi: [String:CSDevice.Info.FactoryProfiles.Profile] = [:]
		for (tmpID, dict) in factProf as! [String:[String:AnyObject]] {
			//var listDir: [CSDevice.Info.FactoryProfiles.Profile] = []
			
			ahi[tmpID] = Info.FactoryProfiles.Profile(profileURL: (dict[kColorSyncDeviceProfileURL.takeUnretainedValue() as String]) as? NSURL, modeDescription: (dict[kColorSyncDeviceModeDescription.takeUnretainedValue() as String]) as! String)
		}
		let fac = Info.FactoryProfiles(defaultProfileID: defaultID, profiles: ahi)
		let custProfs: Dictionary<String, NSURL?> = {
			let custom = devInfo.removeValueForKey(kColorSyncCustomProfiles.takeUnretainedValue() as String) as! NSDictionary as! [String: AnyObject]
			var tmpDict: Dictionary<String, NSURL?> = [:]
			for (key, value) in custom {
				tmpDict[key] = value as? NSURL
			}
			return tmpDict
		}()
		
		let userScopeStr = devInfo.removeValueForKey(kColorSyncDeviceUserScope.takeUnretainedValue() as String) as! NSString
		let hostScopeStr = devInfo.removeValueForKey(kColorSyncDeviceHostScope.takeUnretainedValue() as String) as! NSString
		let userScope: Scope
		let hostScope: Scope
		if userScopeStr == kCFPreferencesAnyUser {
			userScope = .Any
		} else {
			userScope = .Current
		}

		if hostScopeStr == kCFPreferencesAnyHost {
			hostScope = .Any
		} else {
			hostScope = .Current
		}
		
		let aUU = NSUUID(UUIDString: CFUUIDCreateString(kCFAllocatorDefault, devID) as String)!

		return Info(deviceClass: devClass, deviceID: aUU, deviceDescription: devDes, factoryProfiles: fac, customProfiles: custProfs, userScope: userScope, hostScope: hostScope)
	}
	
	public static func deviceInfos() -> [Profiles] {
		let profsArr: Array<[String: AnyObject]>
		do {
			let profs = NSMutableArray()
			
			ColorSyncIterateDeviceProfiles({ (aDict, refCon) -> Bool in
				let array = Unmanaged<NSMutableArray>.fromOpaque(COpaquePointer(refCon)).takeUnretainedValue()
				
				let bDict = (aDict as NSDictionary).copy()
				array.addObject(bDict)
				return true
				}, UnsafeMutablePointer<Void>(Unmanaged.passUnretained(profs).toOpaque()))
			
			profsArr = profs as NSArray as! Array<[String: AnyObject]>
		}
		
		let devInfo = profsArr.map { (aDict) -> Profiles in
			var otherDict = aDict
			let devClass: Profiles.DeviceClass
			let preDevClass = otherDict.removeValueForKey(kColorSyncDeviceClass.takeUnretainedValue() as String) as! String
			switch preDevClass {
			case kColorSyncCameraDeviceClass.takeUnretainedValue() as NSString as String:
				devClass = .Camera
				
			case kColorSyncDisplayDeviceClass.takeUnretainedValue() as NSString as String:
				devClass = .Display
				
			case kColorSyncPrinterDeviceClass.takeUnretainedValue() as NSString as String:
				devClass = .Printer
				
			case kColorSyncScannerDeviceClass.takeUnretainedValue() as NSString as String:
				devClass = .Scanner
				
			default:
				fatalError("Unknown device class \(preDevClass)")
			}
			let devID = otherDict.removeValueForKey(kColorSyncDeviceID.takeUnretainedValue() as String) as! CFUUID
			let profID = otherDict.removeValueForKey(kColorSyncDeviceProfileID.takeUnretainedValue() as String) as! String
			let profURL = otherDict.removeValueForKey(kColorSyncDeviceProfileURL.takeUnretainedValue() as String) as! NSURL
			let devDes = otherDict.removeValueForKey(kColorSyncDeviceDescription.takeUnretainedValue() as String) as! String
			let modeDes = otherDict.removeValueForKey(kColorSyncDeviceModeDescription.takeUnretainedValue() as String) as! String
			let isFactory = otherDict.removeValueForKey(kColorSyncDeviceProfileIsFactory.takeUnretainedValue() as String) as! Bool
			let isDefault = otherDict.removeValueForKey(kColorSyncDeviceProfileIsDefault.takeUnretainedValue() as String) as! Bool
			let isCurrent = otherDict.removeValueForKey(kColorSyncDeviceProfileIsCurrent.takeUnretainedValue() as String) as! Bool
			
			let devNSID = NSUUID(UUIDString: CFUUIDCreateString(kCFAllocatorDefault, devID) as String)!
			
			return Profiles(identifier: devNSID, deviceDescription: devDes, modeDescription: modeDes, profileID: profID, profileURL: profURL, extraEntries: otherDict, isFactory: isFactory, isDefault: isDefault, isCurrent: isCurrent, deviceClass: devClass)
		}
		
		return devInfo
	}
}
