import XCTest

fileprivate let packageRootPath = URL(fileURLWithPath: #file)
    .pathComponents
    .dropLast(2)
    .joined(separator: "/")
    .dropFirst()

fileprivate let testAssetsPath = packageRootPath + "/Test Assets"

fileprivate let singleWindowOnlyCheckboxPredicate = NSPredicate(format: "label CONTAINS 'Single window only'")

final class TinyMuseUITests: XCTestCase {
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.activate()
    }

    override func tearDownWithError() throws {
        app.terminate()
    }
    
    @MainActor
    func testReplaceOldWindowWhenSingleWindowSettingIsOn() throws {
        app.filePickerPick(path: testAssetsPath, file: "1.wav")

        app.openSettings()
        if !app.checkBoxes.containing(singleWindowOnlyCheckboxPredicate).firstMatch.checked() {
            clickSingleWindowOnlyCheckbox(app)
        }
        app.closeSettings()

        app.openFile(file: "2.wav")

        XCTAssertEqual(2, app.windows.count)
        XCTAssertNotNil(app.windows["TinyMuse"])
        XCTAssertNotNil(app.windows["2.wav"])
    }
    
    @MainActor
    func testOpenTwoWindowsWhenSingleWindowSettingIsOff() throws {
        app.filePickerPick(path: testAssetsPath, file: "1.wav")

        app.openSettings()
        if app.checkBoxes.containing(singleWindowOnlyCheckboxPredicate).firstMatch.checked() {
            clickSingleWindowOnlyCheckbox(app)
        }
        app.closeSettings()

        app.openFile(file: "2.wav")

        XCTAssertEqual(3, app.windows.count)
        XCTAssertNotNil(app.windows["TinyMuse"])
        XCTAssertNotNil(app.windows["1.wav"])
        XCTAssertNotNil(app.windows["2.wav"])
    }
    
    private func clickSingleWindowOnlyCheckbox(_ app: XCUIApplication) {
        app.checkBoxes
            .containing(singleWindowOnlyCheckboxPredicate)
            .firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.25))
            .click()
    }
}
