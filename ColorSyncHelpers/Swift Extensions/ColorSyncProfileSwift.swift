//
//  ColorSyncProfileSwift.swift
//  ColorSyncHelpers
//
//  Created by C.W. Betts on 9/19/18.
//  Copyright © 2018 C.W. Betts. All rights reserved.
//

import Foundation
import ApplicationServices

public extension ColorSyncProfile {
	/// The data associated with the signature.
	/// - parameter tag: signature of the tag to be retrieved
	@inlinable subscript (tag: String) -> Data? {
		get {
			if let data = ColorSyncProfileCopyTag(self, tag as NSString)?.takeRetainedValue() {
				return data as Data
			}
			return nil
		}
	}
	
	/// Tests if the profiles has a specified tag.
	///
	/// - parameter signature: signature of the tag to be searched for
	///
	/// - returns: `true` if tag exists, or `false` if it does not.
	@inlinable final func containsTag(_ signature: String) -> Bool {
		return ColorSyncProfileContainsTag(self, signature as NSString)
	}
	
	/// Returns MD5 digest for the profile calculated as defined by
	/// ICC specification, or `nil` in case of failure.
	final var md5: ColorSyncMD5? {
		let toRet = ColorSyncProfileGetMD5(self)
		var theMD5 = toRet
		return withUnsafePointer(to: &theMD5.digest) { (TheT) -> ColorSyncMD5? in
			let newErr = UnsafeRawPointer(TheT).assumingMemoryBound(to: UInt.self)
			let toCheck = UnsafeBufferPointer<UInt>(start: newErr, count: MemoryLayout<ColorSyncMD5>.size / MemoryLayout<UInt>.size)
			for i in toCheck {
				if i != 0 {
					return toRet
				}
			}
			return nil
		}
	}
	
	/// The URL of the profile, or `nil` on error.
	final var url: Foundation.URL? {
		return ColorSyncProfileGetURL(self, nil)?.takeUnretainedValue() as URL?
	}
	
	/// `Data` containing the header data in host endianess.
	@inlinable var header: Data? {
		return ColorSyncProfileCopyHeader(self)?.takeRetainedValue() as Data?
	}
	
	/// Estimates the gamma of the profile.
	final func estimateGamma() throws -> Float {
		var errVal: Unmanaged<CFError>?
		let aRet = ColorSyncProfileEstimateGamma(self, &errVal)
		
		if aRet == 0.0 {
			guard let errStuff = errVal?.takeRetainedValue() else {
				throw CSErrors.unwrappingError
			}
			throw errStuff
		}
		return aRet
	}

	/// Return the flattened data.
	final func rawData() throws -> Data {
		var errVal: Unmanaged<CFError>?
		guard let aDat = ColorSyncProfileCopyData(self, &errVal)?.takeRetainedValue() else {
			guard let errStuff = errVal?.takeRetainedValue() else {
				throw CSErrors.unwrappingError
			}
			throw errStuff
		}
		return aDat as Data
	}
	
	/// An utility function creating three tables of floats (redTable, greenTable, blueTable)
	/// each of size `samplesPerChannel`, packed into contiguous memory contained in the `Data`
	/// to be returned from the `vcgt` tag of the profile (if `vcgt` tag exists in the profile).
	@inlinable final func displayTransferTablesFromVCGT(_ samplesPerChannel: inout Int) -> Data? {
		return ColorSyncProfileCreateDisplayTransferTablesFromVCGT(self, &samplesPerChannel)?.takeRetainedValue() as Data?
	}
	
	/// A utility function converting `vcgt` tag (if `vcgt` tag exists in the profile and
	/// conversion possible) to formula components used by `CGSetDisplayTransferByFormula`.
	@inlinable final func displayTransferFormulaFromVCGT() -> (red: (min: Float, max: Float, gamma: Float), green: (min: Float, max: Float, gamma: Float), blue: (min: Float, max: Float, gamma: Float))? {
		typealias Component = (min: Float, max: Float, gamma: Float)
		var red = Component(0, 0, 0)
		var green = Component(0, 0, 0)
		var blue = Component(0, 0, 0)
		if !ColorSyncProfileGetDisplayTransferFormulaFromVCGT(self, &red.min, &red.max, &red.gamma, &green.min, &green.max, &green.gamma, &blue.min, &blue.max, &blue.gamma) {
			return nil
		}
		
		return (red, green, blue)
	}
}

public extension ColorSyncMutableProfile {
	/*
	/// `Data` containing the header data in host endianess
	override public var header: Data? {
		get {
			return super.header
		}
		set {
			if let aHeader = newValue {
				ColorSyncProfileSetHeader(self, aHeader as NSData)
			} else {
				print("header was sent nil, not doing anything!")
			}
		}
	}*/
	
	@inlinable func setHeaderData(_ aHeader: Data) {
		ColorSyncProfileSetHeader(self, aHeader as NSData)
	}
	
	/// Removes a tag named `named`.
	@inlinable func removeTag(_ named: String) {
		ColorSyncProfileRemoveTag(self, named as NSString)
	}
	
	func setTag(_ named: String, to newValue: Data?) {
		if let data = newValue {
			ColorSyncProfileSetTag(self, named as NSString, data as NSData)
		} else {
			removeTag(named)
		}
	}
	
	/*
	/// The data associated with the signature.
	/// - parameter tag: signature of the tag to be retrieved
	override public subscript (tag: String) -> Data? {
		get {
			return super[tag]
		}
		set {
			if let data = newValue {
				ColorSyncProfileSetTag(self, tag as NSString, data as NSData)
			} else {
				removeTag(tag)
			}
		}
	}*/
}
