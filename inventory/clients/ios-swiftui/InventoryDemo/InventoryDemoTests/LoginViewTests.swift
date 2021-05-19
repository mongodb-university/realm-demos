//
//  LoginViewTests.swift
//  InventoryDemoTests
//
//  Created by Diego Freniche Brito on 18/5/21.
//

import XCTest
import ViewInspector
import SwiftUI
@testable import InventoryDemo

class LoginViewTests: XCTestCase {

    func testLoginView() throws {
        @Binding var username = Binding<String>(wrappedValue: "Pepe")
        
        let loginView = LoginView(username: username)
        let subViews = try loginView.inspect()
        XCTAssertEqual(subViews.count, 1)
        
//        let loginVStack = try loginView.inspect().navigationBarItems().vStack()
//        XCTAssertEqual(loginVStack.count, 1)

        
//        let spacer = try loginView.inspect().navigationBarItems().inspect().find(InputField.self)
//
//        XCTAssertNotNil(spacer)
        

//        let item = InventoryItem("Item 1")
//        let itemView = ItemView(item: item)
//        let text = try itemView.inspect().find(Text.self).text().string()
//        XCTAssertEqual("", text)
        
    }

}

extension ItemView: Inspectable {}
extension Spacer: Inspectable {}
extension Text: Inspectable {}

extension LoginView: Inspectable {}
extension InputField: Inspectable {}
