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

public final class CSCMM: CustomStringConvertible {
	var cmmInt: ColorSyncCMMRef?
	
	public static func installedCMMs() -> [CSCMM] {
		let cmms = NSMutableArray()
		
		ColorSyncIterateInstalledCMMs(cmmIterator, UnsafeMutablePointer<Void>(Unmanaged.passUnretained(cmms).toOpaque()))
		
		return cmms as NSArray as! [CSCMM]
	}
	
	private init(cmm: ColorSyncCMM) {
		cmmInt = cmm
	}
	
	public convenience init?(bundle: NSBundle) {
		let newBund = CFBundleCreate(kCFAllocatorDefault, bundle.bundleURL)
		self.init(bundle: newBund)
	}
	
	public init?(bundle: CFBundle) {
		guard let newCmm = ColorSyncCMMCreate(bundle)?.takeRetainedValue() else {
			return nil
		}
		cmmInt = newCmm
	}
	
	/// will return `nil` for Apple's built-in CMM
	public var bundle: CFBundle? {
		return ColorSyncCMMGetBundle(cmmInt)?.takeUnretainedValue()
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
}
