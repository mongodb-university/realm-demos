//
//  File.swift
//  InventoryDemo
//
//  Created by Diego Freniche Brito on 25/5/21.
//

import Foundation

func readFile(named fileName: String) -> (success: Bool, contents: String) {
    guard let path = Bundle.main.path(forResource: fileName, ofType: nil),
          let text = try? NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
    else { return (success: false, "") }

    return (success: true, contents: (text as String).trimmingCharacters(in: .newlines))
}
