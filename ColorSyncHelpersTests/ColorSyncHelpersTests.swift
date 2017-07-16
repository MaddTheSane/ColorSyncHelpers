//
//  ColorSyncHelpersTests.swift
//  ColorSyncHelpersTests
//
//  Created by C.W. Betts on 2/14/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

import XCTest
@testable import ColorSyncHelpers

let validICCNSData: Data = {
	let validICCData: [UInt8] =
		[0x00,0x00,0x02,0x20,0x61,0x70,0x70,0x6C,0x02,0x20,
		 0x00,0x00,0x6D,0x6E,0x74,0x72,0x52,0x47,0x42,0x20,0x58,0x59,0x5A,0x20,
		 0x07,0xD2,0x00,0x05,0x00,0x0D,0x00,0x0C,0x00,0x00,0x00,0x00,0x61,0x63,
		 0x73,0x70,0x41,0x50,0x50,0x4C,0x00,0x00,0x00,0x00,0x61,0x70,0x70,0x6C,
		 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
		 0x00,0x00,0x00,0x00,0xF6,0xD6,0x00,0x01,0x00,0x00,0x00,0x00,0xD3,0x2D,
		 0x61,0x70,0x70,0x6C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
		 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
		 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
		 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0A,0x72,0x58,0x59,0x5A,
		 0x00,0x00,0x00,0xFC,0x00,0x00,0x00,0x14,0x67,0x58,0x59,0x5A,0x00,0x00,
		 0x01,0x10,0x00,0x00,0x00,0x14,0x62,0x58,0x59,0x5A,0x00,0x00,0x01,0x24,
		 0x00,0x00,0x00,0x14,0x77,0x74,0x70,0x74,0x00,0x00,0x01,0x38,0x00,0x00,
		 0x00,0x14,0x63,0x68,0x61,0x64,0x00,0x00,0x01,0x4C,0x00,0x00,0x00,0x2C,
		 0x72,0x54,0x52,0x43,0x00,0x00,0x01,0x78,0x00,0x00,0x00,0x0E,0x67,0x54,
		 0x52,0x43,0x00,0x00,0x01,0x78,0x00,0x00,0x00,0x0E,0x62,0x54,0x52,0x43,
		 0x00,0x00,0x01,0x78,0x00,0x00,0x00,0x0E,0x64,0x65,0x73,0x63,0x00,0x00,
		 0x01,0xB0,0x00,0x00,0x00,0x6D,0x63,0x70,0x72,0x74,0x00,0x00,0x01,0x88,
		 0x00,0x00,0x00,0x26,0x58,0x59,0x5A,0x20,0x00,0x00,0x00,0x00,0x00,0x00,
		 0x74,0x4B,0x00,0x00,0x3E,0x1D,0x00,0x00,0x03,0xCB,0x58,0x59,0x5A,0x20,
		 0x00,0x00,0x00,0x00,0x00,0x00,0x5A,0x73,0x00,0x00,0xAC,0xA6,0x00,0x00,
		 0x17,0x26,0x58,0x59,0x5A,0x20,0x00,0x00,0x00,0x00,0x00,0x00,0x28,0x18,
		 0x00,0x00,0x15,0x57,0x00,0x00,0xB8,0x33,0x58,0x59,0x5A,0x20,0x00,0x00,
		 0x00,0x00,0x00,0x00,0xF3,0x52,0x00,0x01,0x00,0x00,0x00,0x01,0x16,0xCF,
		 0x73,0x66,0x33,0x32,0x00,0x00,0x00,0x00,0x00,0x01,0x0C,0x42,0x00,0x00,
		 0x05,0xDE,0xFF,0xFF,0xF3,0x26,0x00,0x00,0x07,0x92,0x00,0x00,0xFD,0x91,
		 0xFF,0xFF,0xFB,0xA2,0xFF,0xFF,0xFD,0xA3,0x00,0x00,0x03,0xDC,0x00,0x00,
		 0xC0,0x6C,0x63,0x75,0x72,0x76,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,
		 0x01,0x00,0x00,0x00,0x74,0x65,0x78,0x74,0x00,0x00,0x00,0x00,0x43,0x6F,
		 0x70,0x79,0x72,0x69,0x67,0x68,0x74,0x20,0x41,0x70,0x70,0x6C,0x65,0x20,
		 0x43,0x6F,0x6D,0x70,0x75,0x74,0x65,0x72,0x20,0x49,0x6E,0x63,0x2E,0x00,
		 0x00,0x00,0x64,0x65,0x73,0x63,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x13,
		 0x4C,0x69,0x6E,0x65,0x61,0x72,0x20,0x52,0x47,0x42,0x20,0x50,0x72,0x6F,
		 0x66,0x69,0x6C,0x65,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
		 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
		 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
		 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
		 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
		 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
		 0x00,0x00]
	return Data(validICCData)
}()


class ColorSyncHelpersTests: XCTestCase {
	
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
	
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
    func testBasicGetters() {
		let cmms = CSCMM.installedCMMs()
		let nilStr = "(nil)"
		print("CMMs:")
		print(cmms)
		for cmm in cmms {
			print(cmm.description)
			print("\tBundle: \(cmm.bundle != nil ? String(describing: cmm.bundle!) : "(no bundle)")")
			print("\tLocalized Name: \(cmm.localizedName)")
			print("\tIdentifier: \(cmm.identifier)")
		}
		
		print("\nProfiles:")
		do {
			let profiles = try CSProfile.allProfiles()
			for profile in profiles {
				var des = profile.description
				print("\(des):")
				do {
				let tmpSigs = profile.tagSignatures
				des = tmpSigs.description
				print("\tTags: " + des)
				}
				do {
				let dat = profile.header
				des = dat?.description ?? nilStr
				print("\tHeader: " + des)
				}
				//dat = try? profile.rawData()
				//des = dat?.description ?? "nil"
				//print("Raw Profile data: " + des)
				do {
				let gamma = try? profile.estimateGamma()
				des = gamma?.description ?? nilStr
				print("\tGamma: \(des)")
				}
				do {
				let url = profile.URL
				des = url?.path ?? nilStr
				print("\tURL: \(des)")
				}
				do {
				if let md5 = profile.MD5 {
					des = "\(md5)"
				} else {
					des = nilStr
				}
				print("\tMD5: \(des)")
				}
				//print("\ttags:")
				//for tag in tmpSigs {
				//	let data = profile[tag]!
				//	print("\t\t\(tag): \(data)")
				//}
				//print("")
				do {
					if let dtf = profile.displayTransferFormulaFromVCGT() {
						des = "\(dtf)"
					} else {
						des = nilStr
					}
					print("\tDisplay Transfer Formula: \(des)")
				}
				do {
					if let warnings = try profile.verify() {
						des = "Warnings: \(warnings)"
					} else {
						des = "no warnings"
					}
				} catch {
					des = "Invalid: \(error)"
				}
				print("\tVerify: \(des)")
			}
		} catch _ {}
    }
	
	func testInvalidData() {
		// Copied from the valid data test, but with some rows deleted to render it invalid
		let byteArray: [UInt8] = [0x00,0x00,0x02,0x20,0x61,0x70,0x70,0x6C,0x02,0x20,
			0x00,0x00,0x6D,0x6E,0x74,0x72,0x52,0x47,0x42,0x20,0x58,0x59,0x5A,0x20,
			0x07,0xD2,0x00,0x05,0x00,0x0D,0x00,0x0C,0x00,0x00,0x00,0x00,0x61,0x63,
			0x73,0x70,0x41,0x50,0x50,0x4C,0x00,0x00,0x00,0x00,0x61,0x70,0x70,0x6C,
			0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
			0x00,0x00,0x00,0x00,0xF6,0xD6,0x00,0x01,0x00,0x00,0x00,0x00,0xD3,0x2D,
			0x61,0x70,0x70,0x6C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
			0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
			0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
			0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0A,0x72,0x58,0x59,0x5A,
			0x00,0x00,0x00,0xFC,0x00,0x00,0x00,0x14,0x67,0x58,0x59,0x5A,0x00,0x00,
			0x01,0x10,0x00,0x00,0x00,0x14,0x62,0x58,0x59,0x5A,0x00,0x00,0x01,0x24,
			0x00,0x00,0x00,0x14,0x77,0x74,0x70,0x74,0x00,0x00,0x01,0x38,0x00,0x00,
			0x01,0xB0,0x00,0x00,0x00,0x6D,0x63,0x70,0x72,0x74,0x00,0x00,0x01,0x88,
			0x00,0x00,0x00,0x26,0x58,0x59,0x5A,0x20,0x00,0x00,0x00,0x00,0x00,0x00,
			0x74,0x4B,0x00,0x00,0x3E,0x1D,0x00,0x00,0x03,0xCB,0x58,0x59,0x5A,0x20,
			0x00,0x00,0x00,0x00,0x00,0x00,0x5A,0x73,0x00,0x00,0xAC,0xA6,0x00,0x00,
			0x17,0x26,0x58,0x59,0x5A,0x20,0x00,0x00,0x00,0x00,0x00,0x00,0x28,0x18,
			0x00,0x00,0x15,0x57,0x00,0x00,0xB8,0x33,0x58,0x59,0x5A,0x20,0x00,0x00,
			0x00,0x00,0x00,0x00,0xF3,0x52,0x00,0x01,0x00,0x00,0x00,0x01,0x16,0xCF,
			0x73,0x66,0x33,0x32,0x00,0x00,0x00,0x00,0x00,0x01,0x0C,0x42,0x00,0x00,
			0x05,0xDE,0xFF,0xFF,0xF3,0x26,0x00,0x00,0x07,0x92,0x00,0x00,0xFD,0x91,
			0xFF,0xFF,0xFB,0xA2,0xFF,0xFF,0xFD,0xA3,0x00,0x00,0x03,0xDC,0x00,0x00,
			0xC0,0x6C,0x63,0x75,0x72,0x76,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,
			0x01,0x00,0x00,0x00,0x74,0x65,0x78,0x74,0x00,0x00,0x00,0x00,0x43,0x6F,
			0x70,0x79,0x72,0x69,0x67,0x68,0x74,0x20,0x41,0x70,0x70,0x6C,0x65,0x20,
			0x43,0x6F,0x6D,0x70,0x75,0x74,0x65,0x72,0x20,0x49,0x6E,0x63,0x2E,0x00,
			0x00,0x00,0x64,0x65,0x73,0x63,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x13,
			0x4C,0x69,0x6E,0x65,0x61,0x72,0x20,0x52,0x47,0x42,0x20,0x50,0x72,0x6F,
			0x66,0x69,0x6C,0x65,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
			0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
			0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
			0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
			0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
			0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00]
		let data = Data(byteArray)
		
		do {
			let profile = try CSProfile(data: data)
			print(profile)
		} catch {
			print(error)
			XCTAssert(true, "CSProfile failed, \(error)")
			return
		}
		XCTFail("CSProfile should have failed")
	}
	
	func testValidData() {
		let data = validICCNSData
		
		do {
			let profile = try CSProfile(data: data)
			print(profile)
		} catch {
			XCTFail("CSProfile failed, \(error)")
		}
	}
	
	func testMakingItMutable() {
		let data = validICCNSData
		let copyrightTag = kColorSyncSigCopyrightTag.takeUnretainedValue() as String
		
		func testCopyrightTag(profile: CSProfile) {
			if let copy = profile[copyrightTag] {
				print(String(data: copy, encoding: String.Encoding.utf8) ?? "")
			} else {
				print("No \"\(copyrightTag)\" tag!")
			}
		}
		
		do {
			let profile = try CSProfile(data: data)
			print(profile.profile)
			testCopyrightTag(profile: profile)
			
			let mutProfile = profile.mutableCopy()
			testCopyrightTag(profile: mutProfile)
			mutProfile[copyrightTag] = "text\0\0\0\0Testing this…\0".data(using: String.Encoding.utf8)
			testCopyrightTag(profile: mutProfile)
			print(mutProfile.profile)
			XCTAssertNotNil(try? mutProfile.rawData())
			print(mutProfile.profile)
			mutProfile[copyrightTag] = nil
			print(mutProfile.profile)
			testCopyrightTag(profile: mutProfile)
			XCTAssertNil(mutProfile[copyrightTag])
		} catch {
			XCTFail("CSProfile failed, \(error)")
		}
	}
	
	func testRawMutable() {
		let data = validICCNSData

		let aMut = CSMutableProfile()
		print(aMut.profile)
		
		do {
			let aMut2 = try CSMutableProfile(data: data)
			print(aMut2.profile)
			aMut2.removeTag(kColorSyncSigCopyrightTag.takeUnretainedValue() as String)
			print(aMut2.profile)
		} catch {
			XCTFail("CSMutableProfile failed, \(error)")
		}
	}
	
	func testMD5() {
		let data = validICCNSData

		guard let profile = try? CSProfile(data: data) else {
			XCTFail("CSProfile failed")
			return
		}

		let md5Data = profile.MD5
		
		XCTAssertNotNil(md5Data)
	}
	
	func testInvalidRemove() {
		let data = validICCNSData
		
		guard let profile = try? CSProfile(data: data) else {
			XCTFail("CSProfile failed")
			return
		}

		do {
			try profile.uninstall()
		} catch let error as CSErrors {
			print("Got CSError:", error.rawValue)
			//XCTFail("We got invalid error returned")
			return
		} catch {
			print(error)
		}
		XCTFail("What did we uninstall!?")
	}
}
