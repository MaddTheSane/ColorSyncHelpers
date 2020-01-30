//
//  Error.swift
//  ColorSyncHelpers
//
//  Created by C.W. Betts on 2/14/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

import Foundation

@objc public enum CSErrors: Int, Error {
	/// Could not unwrap the error that was returned from a failed function call.
	case unwrappingError = -1
}

extension CSErrors: CustomStringConvertible {
	public var description: String {
		switch self {
		case .unwrappingError:
			return "Unable to unwrap the error returned by ColorSync functions.\nThere's nothing you can do, other than create a ticket at https://feedbackassistant.apple.com Fixing this issue is impossible from an outside developer."
		@unknown default:
			return "Unknown error \(self.rawValue)"
		}
	}
}
