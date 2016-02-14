//
//  ColorSyncProfileClass.swift
//  ColorSyncHelpers
//
//  Created by C.W. Betts on 2/13/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

import Foundation
import ApplicationServices

/// Callback routine with a description of a profile that is
/// called during an iteration through the available profiles.
private func profileIterate(profileInfo: NSDictionary!, userInfo: UnsafeMutablePointer<Void>) -> Bool {
	let array = Unmanaged<NSMutableArray>.fromOpaque(COpaquePointer(userInfo)).takeUnretainedValue()
	
	if let prof = CSProfile(iterateData: profileInfo as! [String: AnyObject]) {
		array.addObject(prof)
	}
	
	return true
}

//TODO: add dictionary generater
public class CSProfile: CustomStringConvertible {
	public private(set) var profile: ColorSyncProfile
	
	public static func allProfiles() throws -> [CSProfile] {
		let profs = NSMutableArray()
		var errVal: Unmanaged<CFError>?

		ColorSyncIterateInstalledProfiles(profileIterate, nil, UnsafeMutablePointer<Void>(Unmanaged.passUnretained(profs).toOpaque()), &errVal);
		
		if let errVal = errVal?.takeUnretainedValue() {
			throw errVal
		}
		
		return profs as NSArray as! [CSProfile]
	}
	
	convenience init?(iterateData: [String: AnyObject]) {
		guard let mURL = iterateData[kColorSyncProfileURL!.takeUnretainedValue() as String] as? NSURL else {
			return nil
		}
		do {
			try self.init(contentsOfURL: mURL)
		} catch _ {
			return nil
		}
	}
	
	private init(internalPtr: ColorSyncProfile) {
		profile = internalPtr
	}
	
	/// - parameter data: profile data
	public convenience init(data: NSData) throws {
		var errVal: Unmanaged<CFError>?
		if let csVal = ColorSyncProfileCreate(data, &errVal)?.takeRetainedValue() {
			self.init(internalPtr: csVal)
		} else {
			guard let errStuff = errVal?.takeUnretainedValue() else {
				throw CSErrors.UnwrappingError
			}
			throw errStuff
		}
	}
	
	/// Creates a profile from a URL.
	public convenience init(contentsOfURL: NSURL) throws {
		var errVal: Unmanaged<CFError>?
		if let csVal = ColorSyncProfileCreateWithURL(contentsOfURL, &errVal)?.takeRetainedValue() {
			self.init(internalPtr: csVal)
		} else {
			guard let errStuff = errVal?.takeUnretainedValue() else {
				throw CSErrors.UnwrappingError
			}
			throw errStuff
		}
	}
	
	/// - parameter name: predefined profile name
	public convenience init?(named name: String) {
		guard let retVal = ColorSyncProfileCreateWithName(name)?.takeRetainedValue() else {
			return nil
		}
		self.init(internalPtr: retVal)
	}
	
	/// - parameter profileInfo: array of dictionaries, each one containing a profile object and the
	/// information on the usage of the profile in the transform.
	///
	///               Required keys:
	///               ==============
	///                      kColorSyncProfile           : ColorSyncProfileRef
	///                      kColorSyncRenderingIntent   : CFStringRef defining rendering intent
	///                      kColorSyncTransformTag      : CFStringRef defining which tags to use
	///               Optional key:
	///               =============
	///                    kColorSyncBlackPointCompensation : CFBooleanRef to enable/disable BPC
	///
	/// - parameter options: dictionary with additional public global options (e.g. preferred CMM, quality,
	/// etc... It can also contain custom options that are CMM specific.
	public convenience init?(profileInfo: [[String: AnyObject]], options: [String: AnyObject]) {
		guard let prof = ColorSyncProfileCreateLink(profileInfo, options)?.takeRetainedValue() else {
			return nil
		}
		self.init(internalPtr: prof)
	}
	
	/// - parameter displayID: system-wide unique display ID (defined by IOKIt); pass 0 for main display.
	///
	/// - returns: ColorSyncProfileRef or `nil` in case of failure
	public convenience init?(displayID: UInt32 = 0) {
		guard let aRet = ColorSyncProfileCreateWithDisplayID(displayID)?.takeRetainedValue() else {
			return nil
		}
		self.init(internalPtr: aRet)
	}
	
	///
	/// - parameter deviceClass: ColorSync device class
	/// - parameter deviceID: deviceID registered with ColorSync
	/// - parameter profileID: profileID registered with ColorSync; pass `kColorSyncDeviceDefaultProfileID` (the default) to get the default profile.
	///
	/// See ColorSyncDevice.h for more info on `deviceClass`, `deviceID` and `profileID`
	public convenience init?(deviceClass: String, deviceID ID: CFUUID, profileID: AnyObject = kColorSyncDeviceDefaultProfileID.takeUnretainedValue()) {
		if let aRet = ColorSyncProfileCreateDeviceProfile(deviceClass, ID, profileID)?.takeRetainedValue() {
			self.init(internalPtr: aRet)
		}
		return nil
	}

	/// Creates a mutable copy of the current object
	public final func mutableCopy() -> CSMutableProfile {
		return CSMutableProfile(internalPtr: profile)
	}
	
	/// The data associated with the signature.
	public subscript (tag: String) -> NSData? {
		get {
			if let data = ColorSyncProfileCopyTag(profile, tag)?.takeRetainedValue() {
				return data
			}
			return nil
		}
	}
	
	///
	/// - parameter signature: signature of the tag to be searched for
	///
	/// - returns: `true` if tag exists or `false` if it does not.
	public final func containsTag(signature: String) -> Bool {
		return ColorSyncProfileContainsTag(profile, signature as NSString)
	}
	
	/// Returns MD5 digest for the profile calculated as defined by
	/// ICC specification, or a "zero" signature (filled with zeros)
	/// in case of failure.
	public final var MD5: ColorSyncMD5 {
		return ColorSyncProfileGetMD5(profile)
	}
	
	/// The URL of the profile, or `nil` on error.
	public final var URL: NSURL? {
		return ColorSyncProfileGetURL(profile, nil)?.takeUnretainedValue()
	}
	
	/// NSData containing the header data in host endianess
	public var header: NSData? {
		return ColorSyncProfileCopyHeader(profile)?.takeRetainedValue()
	}
	
	public final func estimateGamma() throws -> Float {
		var errVal: Unmanaged<CFError>?
		let aRet = ColorSyncProfileEstimateGamma(profile, &errVal)
		
		if aRet == 0.0 {
			guard let errStuff = errVal?.takeUnretainedValue() else {
				throw CSErrors.UnwrappingError
			}
			throw errStuff
		}
		return aRet
	}
	
	final public var description: String {
		return ColorSyncProfileCopyDescriptionString(profile).takeRetainedValue() as String
	}
	
	/// Array of signatures of tags in the profile
	public final var tagSignatures: [String] {
		return ColorSyncProfileCopyTagSignatures(profile).takeRetainedValue() as NSArray as! [String]
	}
	
	/// Return the flattened data.
	public final func rawData() throws -> NSData {
		var errVal: Unmanaged<CFError>?
		guard let aDat = ColorSyncProfileCopyData(profile, &errVal)?.takeRetainedValue() else {
			guard let errStuff = errVal?.takeUnretainedValue() else {
				throw CSErrors.UnwrappingError
			}
			throw errStuff
		}
		return aDat
	}
	
	/// An utility function creating three tables of floats (redTable, greenTable, blueTable)
	/// each of size `samplesPerChannel`, packed into contiguous memory contained in the `NSData`
	/// to be returned from the `vcgt` tag of the profile (if `vcgt` tag exists in the profile).
	public final func displayTransferTablesFromVCGT(inout samplesPerChannel: Int) -> NSData? {
		return ColorSyncProfileCreateDisplayTransferTablesFromVCGT(profile, &samplesPerChannel)?.takeRetainedValue()
	}
	
	/// Installs the profile
	///
	/// - parameter domain: either `kColorSyncProfileComputerDomain` or `kColorSyncProfileUserDomain`.<br>
	///             `kColorSyncProfileComputerDomain` is for sharing the profiles (from `/Library/ColorSync/Profiles`).<br>
	///             `kColorSyncProfileUserDomain` is for user custom profiles (installed under home directory, i.e. in
	///             `~/Library/ColorSync/Profiles`.<br>
	///             Default is `kColorSyncProfileUserDomain`.
	/// - parameter subpath:	String created from the file system representation of the path of
	/// the file to contain the installed profile. The last component of the path is interpreted 
	/// as a file name if it ends with the extension ".icc". Otherwise, the subpath is interpreted
	/// as the directory path and file name will be created from the profile description tag, appended 
	/// with the ".icc" extension.
	/// - throws: on error.
	public final func install(domain domain: String = kColorSyncProfileUserDomain.takeUnretainedValue() as String, subpath: String?) throws {
		var errVal: Unmanaged<CFError>?
		if !ColorSyncProfileInstall(profile, domain, subpath, &errVal) {
			guard let errStuff = errVal?.takeUnretainedValue() else {
				throw CSErrors.UnwrappingError
			}
			throw errStuff
		}
	}
	
	/// This profile must return a valid url for `URL`,
	/// i.e. it must be created with `init(contentsOfURL:)`. Also, the url
	/// must be in either in `kColorSyncProfileComputerDomain` or
	/// `kColorSyncProfileUserDomain`, including subfolders of those.
	public final func uninstall() throws {
		var errVal: Unmanaged<CFError>?
		if !ColorSyncProfileUninstall(profile, &errVal) {
			guard let errStuff = errVal?.takeUnretainedValue() else {
				throw CSErrors.UnwrappingError
			}
			throw errStuff
		}
	}
	
	/// A utility function converting `vcgt` tag (if `vcgt` tag exists in the profile and 
	/// conversion possible) to formula components used by `CGSetDisplayTransferByFormula`.
	public final func displayTransferFormulaFromVCGT() -> (red: (min: Float, max: Float, gamma: Float), green: (min: Float, max: Float, gamma: Float), blue: (min: Float, max: Float, gamma: Float))? {
		var redMin: Float = 0
		var redMax: Float = 0
		var redGamma: Float = 0
		var greenMin: Float = 0
		var greenMax: Float = 0
		var greenGamma: Float = 0
		var blueMin: Float = 0
		var blueMax: Float = 0
		var blueGamma: Float = 0
		if !ColorSyncProfileGetDisplayTransferFormulaFromVCGT(profile, &redMin, &redMax, &redGamma, &greenMin, &greenMax, &greenGamma, &blueMin, &blueMax, &blueGamma) {
			return nil
		}
		
		return ((redMin, redMax, redGamma), (greenMin, greenMax, greenGamma), (blueMin, blueMax, blueGamma))
	}
}

/// - parameter displayID: system-wide unique display ID (defined by IOKIt)
public func estimateGamma(displayID displayID: Int32) throws -> Float {
	var errVal: Unmanaged<CFError>?
	let aRet = ColorSyncProfileEstimateGammaWithDisplayID(displayID, &errVal)
	
	guard aRet != 0.0 else {
		guard let errStuff = errVal?.takeUnretainedValue() else {
			throw CSErrors.UnwrappingError
		}
		throw errStuff
	}
	return aRet
}

public final class CSMutableProfile: CSProfile {
	private var mutPtr: ColorSyncMutableProfile
	
	/// returns empty CSMutableProfile
	public init() {
		mutPtr = ColorSyncProfileCreateMutable().takeRetainedValue()
		super.init(internalPtr: mutPtr)
	}
	
	private override init(internalPtr: ColorSyncProfile) {
		mutPtr = ColorSyncProfileCreateMutableCopy(internalPtr).takeRetainedValue()
		super.init(internalPtr: mutPtr)
	}
	
	/// NSData containing the header data in host endianess
	override public var header: NSData? {
		get {
			return super.header
		}
		set {
			if let aHeader = newValue {
				ColorSyncProfileSetHeader(mutPtr, aHeader)
			} else {
				print("header was sent nil, not doing anything!")
			}
		}
	}

	/// The data associated with the signature.
	override public subscript (tag: String) -> NSData? {
		get {
			return super[tag]
		}
		set {
			if let data = newValue {
				ColorSyncProfileSetTag(mutPtr, tag as NSString, data)
			} else {
				ColorSyncProfileRemoveTag(mutPtr, tag as NSString)
			}
		}
	}
}
