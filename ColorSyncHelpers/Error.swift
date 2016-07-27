//
//  Error.swift
//  ColorSyncHelpers
//
//  Created by C.W. Betts on 2/14/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

import Foundation

public enum CSErrors: Int, ErrorProtocol {
	case unwrappingError = -1
	
	public var _code: Int {
		return self.rawValue
	}
}
