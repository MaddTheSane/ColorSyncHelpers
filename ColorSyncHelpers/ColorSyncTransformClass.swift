//
//  ColorSyncTransformClass.swift
//  ColorSyncHelpers
//
//  Created by C.W. Betts on 2/13/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

import Foundation
import ApplicationServices

public class CSTransform {
	public struct DataLayout: OptionSetType {
		public let rawValue: UInt32
		public init(rawValue: UInt32) {
			self.rawValue = rawValue
		}
		
		public enum AlphaInfo: UInt32 {
			/// For example, RGB.
			case None
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
		
		public var alphaInfo: AlphaInfo? {
			get {
				let newVal = self.intersect(.AlphaInfoMask)
				let rawVal = newVal.rawValue
				return AlphaInfo(rawValue: rawVal)
			}
		}
		
		public static let AlphaInfoMask = DataLayout(rawValue: 0x1f)
		
		public static let ByteOrderMask = DataLayout(rawValue: 0x7000)
		public static let ByteOrderDefault = DataLayout(rawValue: 0 << 12)
		public static let ByteOrder16Little = DataLayout(rawValue: 1 << 12)
		public static let ByteOrder32Little = DataLayout(rawValue: 2 << 12)
		public static let ByteOrder16Big = DataLayout(rawValue: 3 << 12)
		public static let ByteOrder32Big = DataLayout(rawValue: 4 << 12)
	};
	
	
	//typedef uint32_t DataLayout;

	var cstint: ColorSyncTransformRef?
}
