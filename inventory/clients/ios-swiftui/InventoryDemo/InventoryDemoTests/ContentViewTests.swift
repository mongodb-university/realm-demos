//
//  ContentViewTests.swift
//  InventoryDemoTests
//
//  Created by Diego Freniche Brito on 19/5/21.
//

import XCTest
import ViewInspector
import SwiftUI
@testable import InventoryDemo

class ContentViewTests: XCTestCase {

    func testContentView() throws {
        // Given a ContentView
        let contentView = ContentView()
        
        // We check its structure
        // Then it should have a Navigation
        let navView = try contentView.inspect().navigationView()
        XCTAssertNotNil(navView)
        
        // Then that Navigation should contain a Group
        let group = try? navView.group(0)
        XCTAssertNotNil(group)
        
        // Then that Group should have a LoginView
        let login = try? group?.view(LoginView.self, 0)
        XCTAssertNotNil(login)
        
        // Then that Group shouldn't have an InventoryView
        let inventoryView = try? group?.view(InventoryView.self, 0)
        XCTAssertNil(inventoryView)
    }
}

// Needed to inspect SwiftUI view hierarchy
extension ContentView: Inspectable {}
extension InventoryView: Inspectable {}
extension LoginView: Inspectable {}
