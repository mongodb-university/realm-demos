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
        let contentView = ContentView()
        let navView = try contentView.inspect().navigationView()
        XCTAssertNotNil(navView)
        
        let group = try? navView.group(0)
        XCTAssertNotNil(group)
        
        let login = try? group?.view(LoginView.self, 0)
        XCTAssertNotNil(login)
        
        let inventoryView = try? group?.view(InventoryView.self, 0)
        XCTAssertNil(inventoryView)
    }
}

extension ContentView: Inspectable {}
extension InventoryView: Inspectable {}
extension LoginView: Inspectable {}
