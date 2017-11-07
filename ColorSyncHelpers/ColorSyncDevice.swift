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
		case `any`
		case current
	}
	
	public struct Profile: CustomStringConvertible, CustomDebugStringConvertible {
		public enum DeviceClass: String {
			case Camera = "cmra"
			case Display = "mntr"
			case Printer = "prtr"
			case Scanner = "scnr"
		}
		public var identifier: UUID
		public var deviceDescription: String
		public var modeDescription: String
		public var profileID: String
		public var profileURL: URL
		public var extraEntries: [String: Any]
		public var isFactory: Bool
		public var isDefault: Bool
		public var isCurrent: Bool
		public var deviceClass: DeviceClass
		
		public var description: String {
			return "\(deviceDescription), \(modeDescription) (\(deviceClass))"
		}
		
		public var debugDescription: String {
			return "CSDeviceInfo(deviceClass: \(deviceClass), identifier: \(identifier.uuidString), deviceDescription: \"\(deviceDescription)\", modeDescription: \"\(modeDescription)\", profileID: \(profileID), profileURL: \(profileURL), isFactory: \(isFactory), isDefault: \(isDefault), isCurrent: \(isCurrent))"
		}
	}
	
	public struct Info {
		public struct FactoryProfiles {
			public struct Profile {
				public var profileURL: URL?
				public var modeDescription: String
			}
			public var defaultProfileID: String
			public var profiles: [String: Profile]
		}
		
		public var deviceClass: Profile.DeviceClass
		public var deviceID: UUID
		public var deviceDescription: String
		public var factoryProfiles: FactoryProfiles
		public var customProfiles: [String: URL?]
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
	private func copyDeviceInfo(_ deviceClass: String, identifier: CFUUID) -> [String: Any] {
		return ColorSyncDeviceCopyDeviceInfo(deviceClass as NSString, identifier).takeRetainedValue() as NSDictionary as! [String: Any]
	}
	
	public func info(deviceClass dc: Profile.DeviceClass, identifier: UUID) -> Info {
		//Info
		
		var devInfo = copyDeviceInfo(dc.rawValue, identifier: CFUUIDCreateFromString(kCFAllocatorDefault, identifier.uuidString as NSString))
		let devClass: Profile.DeviceClass
		let preDevClass = devInfo.removeValue(forKey: kColorSyncDeviceClass.takeUnretainedValue() as String) as! String
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
		let devID = devInfo.removeValue(forKey: kColorSyncDeviceID.takeUnretainedValue() as String) as! CFUUID
		let devDes = devInfo.removeValue(forKey: kColorSyncDeviceDescription.takeUnretainedValue() as String) as! String
		var factProf = devInfo.removeValue(forKey: kColorSyncDeviceDescription.takeUnretainedValue() as String) as! NSDictionary as! [String: Any]
		let defaultID = factProf.removeValue(forKey: kColorSyncDeviceDefaultProfileID.takeUnretainedValue() as String) as! String
		var ahi: [String:CSDevice.Info.FactoryProfiles.Profile] = [:]
		for (tmpID, dict) in factProf as! [String:[String: Any]] {
			//var listDir: [CSDevice.Info.FactoryProfiles.Profile] = []
			
			ahi[tmpID] = Info.FactoryProfiles.Profile(profileURL: (dict[kColorSyncDeviceProfileURL.takeUnretainedValue() as String]) as? URL, modeDescription: (dict[kColorSyncDeviceModeDescription.takeUnretainedValue() as String]) as! String)
		}
		let fac = Info.FactoryProfiles(defaultProfileID: defaultID, profiles: ahi)
		let custProfs: Dictionary<String, URL?> = {
			let custom = devInfo.removeValue(forKey: kColorSyncCustomProfiles.takeUnretainedValue() as String) as! NSDictionary as! [String: Any]
			var tmpDict: Dictionary<String, URL?> = [:]
			for (key, value) in custom {
				tmpDict[key] = value as? URL
			}
			return tmpDict
		}()
		
		let userScopeStr = devInfo.removeValue(forKey: kColorSyncDeviceUserScope.takeUnretainedValue() as String) as! NSString
		let hostScopeStr = devInfo.removeValue(forKey: kColorSyncDeviceHostScope.takeUnretainedValue() as String) as! NSString
		let userScope: Scope
		let hostScope: Scope
		if userScopeStr == kCFPreferencesAnyUser {
			userScope = .any
		} else {
			userScope = .current
		}

		if hostScopeStr == kCFPreferencesAnyHost {
			hostScope = .any
		} else {
			hostScope = .current
		}
		
		let aUU = UUID(uuidString: CFUUIDCreateString(kCFAllocatorDefault, devID) as String)!

		return Info(deviceClass: devClass, deviceID: aUU, deviceDescription: devDes, factoryProfiles: fac, customProfiles: custProfs, userScope: userScope, hostScope: hostScope)
	}
	
	public static func deviceInfos() -> [Profile] {
		let profsArr: Array<[String: Any]> = {
			let profs = NSMutableArray()
			
			ColorSyncIterateDeviceProfiles({ (aDict, refCon) -> Bool in
				let array = Unmanaged<NSMutableArray>.fromOpaque(refCon!).takeUnretainedValue()
				
				let bDict = (aDict as NSDictionary!).copy()
				array.add(bDict)
				return true
				}, UnsafeMutableRawPointer(Unmanaged.passUnretained(profs).toOpaque()))
			
			return profs as NSArray as! Array<[String: Any]>
		}()
		
		let devInfo = profsArr.map { (aDict) -> Profile in
			var otherDict = aDict
			let devClass: Profile.DeviceClass
			let preDevClass = otherDict.removeValue(forKey: kColorSyncDeviceClass.takeUnretainedValue() as String) as! String
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
			let devID = otherDict.removeValue(forKey: kColorSyncDeviceID.takeUnretainedValue() as String) as! CFUUID
			let profID = otherDict.removeValue(forKey: kColorSyncDeviceProfileID.takeUnretainedValue() as String) as! String
			let profURL = otherDict.removeValue(forKey: kColorSyncDeviceProfileURL.takeUnretainedValue() as String) as! URL
			let devDes = otherDict.removeValue(forKey: kColorSyncDeviceDescription.takeUnretainedValue() as String) as! String
			let modeDes = otherDict.removeValue(forKey: kColorSyncDeviceModeDescription.takeUnretainedValue() as String) as! String
			let isFactory = otherDict.removeValue(forKey: kColorSyncDeviceProfileIsFactory.takeUnretainedValue() as String) as! Bool
			let isDefault = otherDict.removeValue(forKey: kColorSyncDeviceProfileIsDefault.takeUnretainedValue() as String) as! Bool
			let isCurrent = otherDict.removeValue(forKey: kColorSyncDeviceProfileIsCurrent.takeUnretainedValue() as String) as! Bool
			
			let devNSID = UUID(uuidString: CFUUIDCreateString(kCFAllocatorDefault, devID) as String)!
			
			return Profile(identifier: devNSID, deviceDescription: devDes, modeDescription: modeDes, profileID: profID, profileURL: profURL, extraEntries: otherDict, isFactory: isFactory, isDefault: isDefault, isCurrent: isCurrent, deviceClass: devClass)
		}
		
		return devInfo
	}
}
