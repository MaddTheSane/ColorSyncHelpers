//
//  Error.swift
//  ColorSyncHelpers
//
//  Created by C.W. Betts on 2/14/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

import Foundation

@objc public enum CSErrors: Int, ErrorProtocol {
	/// Could not unwrap the error that was returned from a failed function call.
	case unwrappingError = -1
	
	public var _code: Int {
		return self.rawValue
	}
}
