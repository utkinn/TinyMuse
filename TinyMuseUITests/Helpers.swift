import XCTest

extension XCUIApplication {
    func filePickerGoTo(path: any StringProtocol) {
        typeKey("g", modifierFlags: [.command, .shift])
        typeText(path + "\r")
    }
    
    func filePickerPick(path: (any StringProtocol)? = nil, file: String) {
        if let path = path {
            filePickerGoTo(path: path)
        }
        cells.containing(.textField, identifier: file).firstMatch.doubleClick()
    }
    
    func openSettings() {
        typeKey(",", modifierFlags: .command)
    }
    
    func closeSettings() {
        windows["com_apple_SwiftUI_Settings_window"].buttons["_XCUI:CloseWindow"].firstMatch.click()
    }
    
    func openFilePicker() {
        typeKey("o", modifierFlags: .command)
    }

    func openFile(path: (any StringProtocol)? = nil, file: String) {
        openFilePicker()
        filePickerPick(path: path, file: file)
    }
}

extension XCUIElement {
    func uncheck() {
        if checked() {
            click()
        }
    }
    
    func check() {
        if !checked() {
            click()
        }
    }
    
    func checked() -> Bool { value as! Bool }
}
