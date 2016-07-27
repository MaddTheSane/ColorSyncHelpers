//
//  CMM.swift
//  ColorSyncHelpers
//
//  Created by C.W. Betts on 2/14/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

import Foundation
import ApplicationServices

private func cmmIterator(_ cmm: ColorSyncCMM?, userInfo: UnsafeMutablePointer<Void>?) -> Bool {
	guard let userInfo = userInfo, let cmm = cmm else {
		return false
	}
	let array = Unmanaged<NSMutableArray>.fromOpaque(userInfo).takeUnretainedValue()
	
	array.add(CSCMM(cmm: cmm))
	
	return true
}

public final class CSCMM: CustomStringConvertible, CustomDebugStringConvertible {
	var cmmInt: ColorSyncCMM?
	
	public static func installedCMMs() -> [CSCMM] {
		let cmms = NSMutableArray()
		
		ColorSyncIterateInstalledCMMs(cmmIterator, UnsafeMutablePointer<Void>(Unmanaged.passUnretained(cmms).toOpaque()))
		
		return cmms as NSArray as! [CSCMM]
	}
	
	private init(cmm: ColorSyncCMM) {
		cmmInt = cmm
	}
	
	public convenience init?(bundle: Bundle) {
		let newBund = CFBundleCreate(kCFAllocatorDefault, bundle.bundleURL)
		self.init(bundle: newBund!)
	}
	
	public init?(bundle: CFBundle) {
		guard let newCmm = ColorSyncCMMCreate(bundle)?.takeRetainedValue() else {
			return nil
		}
		cmmInt = newCmm
	}
	
	/// will return `nil` for Apple's built-in CMM
	public var bundle: Bundle? {
		if let cfBundle = ColorSyncCMMGetBundle(cmmInt)?.takeUnretainedValue() {
			let aURL: URL = CFBundleCopyBundleURL(cfBundle) as URL
			return Bundle(url: aURL)!
		}
		return nil
	}
	
	public var localizedName: String {
		return ColorSyncCMMCopyLocalizedName(cmmInt)!.takeRetainedValue() as String
	}
	
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
