//
//  ColorSyncTransformSwift.swift
//  ColorSyncHelpers
//
//  Created by C.W. Betts on 9/19/18.
//  Copyright © 2018 C.W. Betts. All rights reserved.
//

import Foundation
import ApplicationServices

extension ColorSyncTransform {
	/// The color depth of the data.
	public typealias Depth = ColorSyncDataDepth
	
	/// The data layout of the data that will be read/written by the
	/// transform.
	public typealias Layout = CSTransform.Layout
	
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
	public func transform(width: Int, height: Int, dst: UnsafeMutableRawPointer, dstDepth: Depth, dstLayout: Layout, dstBytesPerRow: Int, src: UnsafeRawPointer, srcDepth: Depth, srcLayout: Layout, srcBytesPerRow: Int, options: [String: Any]? = nil) -> Bool {
		return ColorSyncTransformConvert(self, width, height, dst, dstDepth, dstLayout.rawValue, dstBytesPerRow, src, srcDepth, srcLayout.rawValue, srcBytesPerRow, sanitize(options: options) as NSDictionary?)
	}
	
	/// Transform the data from the source color space to the destination.
	/// - parameter width: width of the image in pixels
	/// - parameter height: height of the image in pixels
	/// - parameter destination: information about the destination data, including a pointer to the destination where the results will be written.
	/// - parameter source: information about the data to be converted.
	/// - parameter options: additional options. Default is `nil`.
	/// - returns: `true` if conversion was successful or `false` otherwise.
	public func transform(width: Int, height: Int, destination: (data: UnsafeMutableRawPointer, depth: Depth, layout: Layout, bytesPerRow: Int), source: (data: UnsafeRawPointer, depth: Depth, layout: Layout, bytesPerRow: Int), options: [String: Any]? = nil) -> Bool {
		
		return transform(width: width, height: height, dst: destination.data, dstDepth: destination.depth, dstLayout: destination.layout, dstBytesPerRow: destination.bytesPerRow, src: source.data, srcDepth: source.depth, srcLayout: source.layout, srcBytesPerRow: source.bytesPerRow, options: options)
	}
	
	/// gets the property of the specified key
	/// - parameter key: `CFTypeRef` to be used as a key to identify the property
	public func getProperty(forKey key: AnyObject, options: [String: Any]? = nil) -> Any? {
		return ColorSyncTransformCopyProperty(self, key, sanitize(options: options) as NSDictionary?)?.takeRetainedValue()
	}
	
	/// Sets the property
	/// - parameter key: `CFTypeRef` to be used as a key to identify the property
	/// - parameter property: `CFTypeRef` to be set as the property
	public func setProperty(key: AnyObject, property: Any?) {
		ColorSyncTransformSetProperty(self, key, property as CFTypeRef?)
	}
	
	/// Gets and sets the properties.
	public subscript (key: AnyObject) -> Any? {
		get {
			return getProperty(forKey: key)
		}
		set {
			ColorSyncTransformSetProperty(self, key, newValue as CFTypeRef?)
		}
	}
}
