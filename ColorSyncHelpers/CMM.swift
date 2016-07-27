//
//  CMM.swift
//  ColorSyncHelpers
//
//  Created by C.W. Betts on 2/14/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

import Foundation
import ApplicationServices

private func cmmIterator(cmm: ColorSyncCMM!, userInfo: UnsafeMutablePointer<Void>) -> Bool {
	let array = Unmanaged<NSMutableArray>.fromOpaque(COpaquePointer(userInfo)).takeUnretainedValue()
	
	array.addObject(CSCMM(cmm: cmm))
	
	return true
}

public final class CSCMM: CustomStringConvertible, CustomDebugStringConvertible {
	var cmmInt: ColorSyncCMMRef
	
	/// The system-supplied CMM
	public static var appleCMM: CSCMM {
		let cmms = installedCMMs()
		for cmm in cmms {
			if cmm.bundle == nil {
				return cmm
			}
		}
		return cmms.first!
	}
	
	/// Returns all of the available CMMs.
	public static func installedCMMs() -> [CSCMM] {
		let cmms = NSMutableArray()
		
		ColorSyncIterateInstalledCMMs(cmmIterator, UnsafeMutablePointer<Void>(Unmanaged.passUnretained(cmms).toOpaque()))
		
		return cmms as NSArray as! [CSCMM]
	}
	
	private init(cmm: ColorSyncCMM) {
		cmmInt = cmm
	}
	
	/// Creates a CSCMM object from the supplied bundle.
	public convenience init?(bundle: NSBundle) {
		if let newBund = CFBundleCreate(kCFAllocatorDefault, bundle.bundleURL) {
			self.init(bundle: newBund)
		} else {
			return nil
		}
	}
	
	/// Creates a CSCMM object from the supplied bundle.
	public init?(bundle: CFBundle) {
		guard let newCmm = ColorSyncCMMCreate(bundle)?.takeRetainedValue() else {
			return nil
		}
		cmmInt = newCmm
	}
	
	/// Will return `nil` for Apple's built-in CMM
	public var bundle: NSBundle? {
		if let cfBundle = ColorSyncCMMGetBundle(cmmInt)?.takeUnretainedValue() {
			let aURL: NSURL = CFBundleCopyBundleURL(cfBundle)
			return NSBundle(URL: aURL)!
		}
		return nil
	}
	
	/// Returns the localized name of the ColorSync module
	public var localizedName: String {
		return ColorSyncCMMCopyLocalizedName(cmmInt)!.takeRetainedValue() as String
	}
	
	/// Returns the identifier of the ColorSync module
	public var identifier: String {
		return ColorSyncCMMCopyCMMIdentifier(cmmInt)!.takeRetainedValue() as String
	}
	
	public var description: String {
		return "\(identifier), \"\(localizedName)\""
	}
	
	public var debugDescription: String {
		return CFCopyDescription(cmmInt) as String
	}
}
