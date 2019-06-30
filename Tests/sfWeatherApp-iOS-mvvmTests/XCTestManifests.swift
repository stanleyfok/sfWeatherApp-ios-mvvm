import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(sfWeatherApp_iOS_mvvmTests.allTests),
    ]
}
#endif
