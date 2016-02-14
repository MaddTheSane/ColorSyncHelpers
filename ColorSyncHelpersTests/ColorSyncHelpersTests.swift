//
//  ColorSyncHelpersTests.swift
//  ColorSyncHelpersTests
//
//  Created by C.W. Betts on 2/14/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

import XCTest
import ColorSyncHelpers

class ColorSyncHelpersTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
		let cmms = CSCMM.installedCMMs()
		print("CMMs:")
		print(cmms)
		for cmm in cmms {
			print("Bundle: \(cmm.bundle)")
			print("Localized Name: \(cmm.localizedName)")
			print("Identifier: \(cmm.identifier)")
		}
		
		print("\nProfiles:")
		do {
			let profiles = try CSProfile.allProfiles()
			for profile in profiles {
				var des = profile.description
				print(des)
				let tmpSigs = profile.tagSignatures
				des = tmpSigs.description
				print("tags: " + des)
				let dat = profile.header
				des = dat?.description ?? "nil"
				print("Header: " + des)
				//dat = try? profile.rawData()
				//des = dat?.description ?? "nil"
				//print("Raw Profile data: " + des)
				let gamma = try? profile.estimateGamma()
				des = gamma?.description ?? "nil"
				print("gamma: \(des)")
				let url = profile.URL
				des = url?.description ?? "nil"
				print("URL: \(des)")
				print("MD5: \(profile.MD5)")
				print("")
				for tag in tmpSigs {
					let data = profile[tag]!
					print("\(tag): \(data)")
				}
				print("")
			}
		} catch _ {}
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
