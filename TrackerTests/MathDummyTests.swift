import XCTest
@testable import Tracker

class CalculatorTests: XCTestCase {
    
    func testAdd() {
        //Arrange - входные параметры и ожидаемый результат
        let calculator = Calculator()

        let expectedResult = 5
        
        //Act - вызов тестируемого метода
        let result = calculator.add(a: 2, b: 3)
        
        //Assert - проверка соответствия результата ожидаемому
        XCTAssertEqual(result, expectedResult)
    }
    
    func testSubtrack() {
        //Arrange
        let calculator = Calculator()
        let a = 8
        let b = 5
        let expectedResult = 3
        
        //Act
        let result = calculator.subtract(a: a, b: b)
        
        //Assert
        XCTAssertEqual(result, expectedResult)
    }
    
}
