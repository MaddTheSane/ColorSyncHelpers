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
/// Most keys are in "ApplicationServices/ColorSync/ColorSyncTransform".
/// Note that you may have to unwrap them!
public final class CSTransform: CustomDebugStringConvertible {
	
	/// The color depth of the data.
	public typealias Depth = ColorSyncDataDepth
	
	/// The data layout of the data that will be read/written by the
	public struct Layout: OptionSet {
		public let rawValue: UInt32
		public init(rawValue: UInt32) {
			self.rawValue = rawValue
		}
		
		public enum AlphaInfo: UInt32 {
			/// For example, RGB.
			case none = 0
			/// For example, premultiplied RGBA
			case premultipliedLast
			/// For example, premultiplied ARGB
			case premultipliedFirst
			/// For example, non-premultiplied RGBA
			case last
			/// For example, non-premultiplied ARGB
			case first
			/// For example, RBGX.
			case noneSkipLast
			///For example, XRGB.
			case noneSkipFirst
		}
		
		/// The alpha info of the current layout.
		public var alphaInfo: AlphaInfo {
			get {
				let newVal = self.intersection(.AlphaInfoMask)
				let rawVal = newVal.rawValue
				return AlphaInfo(rawValue: rawVal) ?? .none
			}
			set {
				remove(.AlphaInfoMask)
				insert(Layout(rawValue: newValue.rawValue))
			}
		}
		
		public static var AlphaInfoMask: Layout { return Layout(rawValue: 0x1f) }
		
		public static var ByteOrderMask: Layout { return Layout(rawValue: 0x7000) }
		public static var ByteOrderDefault: Layout { return Layout(rawValue: 0 << 12) }
		public static var ByteOrder16Little: Layout { return Layout(rawValue: 1 << 12) }
		public static var ByteOrder32Little: Layout { return Layout(rawValue: 2 << 12) }
		public static var ByteOrder16Big: Layout { return Layout(rawValue: 3 << 12) }
		public static var ByteOrder32Big: Layout { return Layout(rawValue: 4 << 12) }
	}

	let cstint: ColorSyncTransform
	
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
		guard let tmpTrans = ColorSyncTransformCreate(sanitize(profileInfo: profileSequence), sanitize(options: options))?.takeRetainedValue() else {
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
	public func transform(width: Int, height: Int, dst: UnsafeMutablePointer<Void>, dstDepth: Depth, dstLayout: Layout, dstBytesPerRow: Int, src: UnsafePointer<Void>, srcDepth: Depth, srcLayout: Layout, srcBytesPerRow: Int, options: [String: AnyObject]? = nil) -> Bool {
		return ColorSyncTransformConvert(cstint, width, height, dst, dstDepth, dstLayout.rawValue, dstBytesPerRow, src, srcDepth, srcLayout.rawValue, srcBytesPerRow, sanitize(options: options))
	}
	
	/// Transform the data from the source color space to the destination.
	/// - parameter width: width of the image in pixels
	/// - parameter height: height of the image in pixels
	/// - parameter destination: information about the destination data, including a pointer to the destination where the results will be written.
	/// - parameter source: information about the data to be converted.
	/// - parameter options: additional options. Default is `nil`.
	/// - returns: `true` if conversion was successful or `false` otherwise.
	public func transform(width: Int, height: Int, destination: (data: UnsafeMutablePointer<Void>, depth: Depth, layout: Layout, bytesPerRow: Int), source: (data: UnsafePointer<Void>, depth: Depth, layout: Layout, bytesPerRow: Int), options: [String: AnyObject]? = nil) -> Bool {
		
		return transform(width: width, height: height, dst: destination.data, dstDepth: destination.depth, dstLayout: destination.layout, dstBytesPerRow: destination.bytesPerRow, src: source.data, srcDepth: source.depth, srcLayout: source.layout, srcBytesPerRow: source.bytesPerRow, options: options)
	}

	/// Transform the data from the source color space to the destination.
	/// - parameter width: width of the image in pixels
	/// - parameter height: height of the image in pixels
	/// - parameter destination: information about the destination data, including an `NSMutableData` reference to the destination where the results will be written.
	/// - parameter source: information about the data to be converted.
	/// - parameter options: additional options. Default is `nil`.
	/// - returns: `true` if conversion was successful or `false` otherwise.
	public func transform(width: Int, height: Int, destination: (data: NSMutableData, depth: Depth, layout: Layout, bytesPerRow: Int), source: (data: NSData, depth: Depth, layout: Layout, bytesPerRow: Int), options: [String: AnyObject]? = nil) -> Bool {
		
		return transform(width: width, height: height, dst: destination.data.mutableBytes, dstDepth: destination.depth, dstLayout: destination.layout, dstBytesPerRow: destination.bytesPerRow, src: (source.data as NSData).bytes, srcDepth: source.depth, srcLayout: source.layout, srcBytesPerRow: source.bytesPerRow, options: options)
	}
	
	/// gets the property of the specified key
	/// - parameter key: `CFTypeRef` to be used as a key to identify the property
	public func getProperty(key: AnyObject, options: [String: AnyObject]? = nil) -> AnyObject? {
		return ColorSyncTransformCopyProperty(cstint, key, sanitize(options: options))?.takeRetainedValue()
	}
	
	/// Sets the property
	/// - parameter key: `CFTypeRef` to be used as a key to identify the property
	/// - parameter property: `CFTypeRef` to be set as the property
	public func setProperty(key: AnyObject, property: AnyObject?) {
		ColorSyncTransformSetProperty(cstint, key, property)
	}
	
	/// Gets and sets the properties.
	public subscript (key: AnyObject) -> AnyObject? {
		get {
			return getProperty(key: key)
		}
		set {
			ColorSyncTransformSetProperty(cstint, key, newValue)
		}
	}
}
