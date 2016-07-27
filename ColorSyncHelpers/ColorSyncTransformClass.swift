//
//  ColorSyncTransformClass.swift
//  ColorSyncHelpers
//
//  Created by C.W. Betts on 2/13/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

import Foundation
import ApplicationServices

/// A class that references a ColorSync transform.
///
/// Most keys are in ApplicationServices/ColorSync/ColorSyncTransform. 
/// Note that you may have to unwrap them!
public final class CSTransform: CustomDebugStringConvertible {
	public struct DataLayout: OptionSetType {
		public let rawValue: UInt32
		public init(rawValue: UInt32) {
			self.rawValue = rawValue
		}
		
		public enum AlphaInfo: UInt32 {
			/// For example, RGB.
			case None = 0
			/// For example, premultiplied RGBA
			case PremultipliedLast
			/// For example, premultiplied ARGB
			case PremultipliedFirst
			/// For example, non-premultiplied RGBA
			case Last
			/// For example, non-premultiplied ARGB
			case First
			/// For example, RBGX.
			case NoneSkipLast
			///For example, XRGB.
			case NoneSkipFirst
		}
		
		public var alphaInfo: AlphaInfo {
			get {
				let newVal = self.intersect(.AlphaInfoMask)
				let rawVal = newVal.rawValue
				return AlphaInfo(rawValue: rawVal) ?? .None
			}
			set {
				remove(.AlphaInfoMask)
				insert(DataLayout(rawValue: newValue.rawValue))
			}
		}
		
		public static var AlphaInfoMask: DataLayout { return DataLayout(rawValue: 0x1f) }
		
		public static var ByteOrderMask: DataLayout { return DataLayout(rawValue: 0x7000) }
		public static var ByteOrderDefault: DataLayout { return DataLayout(rawValue: 0 << 12) }
		public static var ByteOrder16Little: DataLayout { return DataLayout(rawValue: 1 << 12) }
		public static var ByteOrder32Little: DataLayout { return DataLayout(rawValue: 2 << 12) }
		public static var ByteOrder16Big: DataLayout { return DataLayout(rawValue: 3 << 12) }
		public static var ByteOrder32Big: DataLayout { return DataLayout(rawValue: 4 << 12) }
	}

	private var cstint: ColorSyncTransformRef?
	
	public var debugDescription: String {
		return CFCopyDescription(cstint) as String
	}

	/// Creates a transform class with a transform from `from` to `to`.
	///
	/// This is equivalent to using the perceptual rendering intent.
	public convenience init?(from: CSProfile, to: CSProfile) {
		let fromArr: [String: AnyObject]
			= [kColorSyncProfile.takeUnretainedValue() as String: from.profile,
			   kColorSyncRenderingIntent.takeUnretainedValue() as String: kColorSyncRenderingIntentPerceptual.takeUnretainedValue() as NSString,
			   kColorSyncTransformTag.takeUnretainedValue() as String:kColorSyncTransformDeviceToPCS.takeUnretainedValue() as NSString]
		let toArr: [String: AnyObject]
			= [kColorSyncProfile.takeUnretainedValue() as String: to.profile,
			   kColorSyncRenderingIntent.takeUnretainedValue() as String: kColorSyncRenderingIntentPerceptual.takeUnretainedValue() as NSString,
			   kColorSyncTransformTag.takeUnretainedValue() as String:kColorSyncTransformPCSToDevice.takeUnretainedValue() as NSString]

		self.init(profileSequence: [fromArr, toArr], options: nil)
	}
	
	/// Creates a new transform class
	/// - parameter profileSequence: array of dictionaries, each one containing a profile object and the
	/// information on the usage of the profile in the transform.<br>
	///
	///               Required keys:
	///               ==============
	///                      kColorSyncProfile           : ColorSyncProfileRef or CSProfile
	///                      kColorSyncRenderingIntent   : CFStringRef defining rendering intent
	///                      kColorSyncTransformTag      : CFStringRef defining which tags to use
	///               Optional key:
	///               =============
	///                      kColorSyncBlackPointCompensation : CFBooleanRef to enable/disable BPC
	/// - parameter options: dictionary with additional public global options 
	/// (e.g. preferred CMM, quality, etc…) It can also contain custom options that are CMM specific.
	/// - returns: A valid `CSTransform`, or `nil` in case of failure
	public init?(profileSequence: [[String:AnyObject]], options: [String:AnyObject]? = nil) {
		let colorSyncProfKey = kColorSyncProfile.takeUnretainedValue() as String
		// make sure we don't pass our own CSProfile, but the ColorSyncProfileRef the API expects
		let filtered = profileSequence.map { (TheDict) -> [String:AnyObject] in
			var tmpDict: [String:AnyObject] = TheDict
			if let csProfile = tmpDict[colorSyncProfKey] as? CSProfile {
				tmpDict[colorSyncProfKey] = csProfile.profile
			}
			return tmpDict
		}
		guard let tmpTrans = ColorSyncTransformCreate(filtered, options)?.takeRetainedValue() else {
			return nil
		}
		cstint = tmpTrans
	}
	
	/// Transform the data from the source color space to the destination.
	/// - parameter width: width of the image in pixels
	/// - parameter height: height of the image in pixels
	/// - parameter dst: a pointer to the destination where the results will be written.
	/// - parameter dstDepth: describes the bit depth and type of the destination color components
	/// - parameter dstFormat: describes the format and byte packing of the destination pixels
	/// - parameter dstBytesPerRow: number of bytes in the row of data
	/// - parameter src: a pointer to the data to be converted.
	/// - parameter srcDepth: describes the bit depth and type of the source color components
	/// - parameter srcFormat: describes the format and byte packing of the source pixels
	/// - parameter srcBytesPerRow: number of bytes in the row of data
	/// - parameter options: additional options. Default is `nil`.
	/// - returns: `true` if conversion was successful or `false` otherwise.
	public func transform(width width: Int, height: Int, dst: UnsafeMutablePointer<Void>, dstDepth: ColorSyncDataDepth, dstLayout: DataLayout, dstBytesPerRow: Int, src: UnsafePointer<Void>, srcDepth: ColorSyncDataDepth, srcLayout: DataLayout, srcBytesPerRow: Int, options: [String: AnyObject]? = nil) -> Bool {
		return ColorSyncTransformConvert(cstint, width, height, dst, dstDepth, dstLayout.rawValue, dstBytesPerRow, src, srcDepth, srcLayout.rawValue, srcBytesPerRow, options)
	}
	
	/// Transform the data from the source color space to the destination.
	/// - parameter width: width of the image in pixels
	/// - parameter height: height of the image in pixels
	/// - parameter destination: information about the destination data, including a pointer to the destination where the results will be written.
	/// - parameter source: information about the data to be converted.
	/// - parameter options: additional options. Default is `nil`.
	/// - returns: `true` if conversion was successful or `false` otherwise.
	public func transform(width width: Int, height: Int, destination: (data: UnsafeMutablePointer<Void>, depth: ColorSyncDataDepth, layout: DataLayout, bytesPerRow: Int), source: (data: UnsafePointer<Void>, depth: ColorSyncDataDepth, layout: DataLayout, bytesPerRow: Int), options: [String: AnyObject]? = nil) -> Bool {
		
		return transform(width: width, height: height, dst: destination.data, dstDepth: destination.depth, dstLayout: destination.layout, dstBytesPerRow: destination.bytesPerRow, src: source.data, srcDepth: source.depth, srcLayout: source.layout, srcBytesPerRow: source.bytesPerRow, options: options)
	}

	/// Transform the data from the source color space to the destination.
	/// - parameter width: width of the image in pixels
	/// - parameter height: height of the image in pixels
	/// - parameter destination: information about the destination data, including an `NSMutableData` reference to the destination where the results will be written.
	/// - parameter source: information about the data to be converted.
	/// - parameter options: additional options. Default is `nil`.
	/// - returns: `true` if conversion was successful or `false` otherwise.
	public func transform(width width: Int, height: Int, destination: (data: NSMutableData, depth: ColorSyncDataDepth, layout: DataLayout, bytesPerRow: Int), source: (data: NSData, depth: ColorSyncDataDepth, layout: DataLayout, bytesPerRow: Int), options: [String: AnyObject]? = nil) -> Bool {
		
		return transform(width: width, height: height, dst: destination.data.mutableBytes, dstDepth: destination.depth, dstLayout: destination.layout, dstBytesPerRow: destination.bytesPerRow, src: source.data.bytes, srcDepth: source.depth, srcLayout: source.layout, srcBytesPerRow: source.bytesPerRow, options: options)
	}
	
	/// gets the property of the specified key
	/// - parameter key: `CFTypeRef` to be used as a key to identify the property
	public func getProperty(key key: AnyObject, options: [String: AnyObject]? = nil) -> AnyObject? {
		return ColorSyncTransformCopyProperty(cstint, key, options).takeRetainedValue()
	}
	
	/// Sets the property
	/// - parameter key: `CFTypeRef` to be used as a key to identify the property
	/// - parameter property: `CFTypeRef` to be set as the property
	public func setProperty(key key: AnyObject, property: AnyObject) {
		ColorSyncTransformSetProperty(cstint, key, property)
	}
}
