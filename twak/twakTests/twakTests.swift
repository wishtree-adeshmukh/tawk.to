//
//  twakTests.swift
//  twakTests
//
//  Created by Archana on 01/04/21.
//

import XCTest
@testable import tawk

class twakTests: XCTestCase {
    lazy var userlistResponse: Data = {
        let testBundle = Bundle(for: type(of: self))
        let path = testBundle.path(forResource: "userlistResponse", ofType: "json")
        return try! String(contentsOfFile: path!).data(using: .utf8)!
    }()
    lazy var userDetailResponse: Data = {
        let testBundle = Bundle(for: type(of: self))
        let path = testBundle.path(forResource: "userDetailResponse", ofType: "json")
       
        return try! String(contentsOfFile: path!).data(using: .utf8)!
    }()
    override func setUpWithError() throws {
       //try? Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
   
    
    func testSelectUser()  throws {
        // adding mock entry
        let userAry = CoreDataHandler.sharedInstance.ParseJSONToCodedataAry(data: userlistResponse)
        let userItem = CoreDataHandler.sharedInstance.fetchUserItem(String(userAry[0].id), withContext: nil)
        XCTAssertNotNil(userItem, "Response data is not decoded in Coredata entity UserItem")
        XCTAssertNotNil(userItem?.id, "id should not be nil")
        XCTAssertTrue(userItem?.login == "mojombo")
        XCTAssertEqual(userItem?.avatar_url, "https://avatars.githubusercontent.com/u/1?v=4", "avatar_url in not updated with actual value")
        // Deleting mock entry
        CoreDataHandler.sharedInstance.deleteGitHubUser(userItem!)
    }
    func testUserDetailUpdate() throws {
       // adding mock entry
        _ = CoreDataHandler.sharedInstance.ParseJSONToCodedataAry(data: userlistResponse)
        let userItem = CoreDataHandler.sharedInstance.parseJSONToCodedataObject(data: userDetailResponse)
        XCTAssertNotNil(userItem, "Response data is not decoded in Coredata entity UserItem")
        XCTAssertNotNil(userItem.id, "id should not be nil")
        XCTAssertTrue(userItem.login == "mojombo")
        XCTAssertEqual(userItem.blog, "http://tom.preston-werner.com","blog in not updated with actual value")
        XCTAssertEqual(userItem.company, "@chatterbugapp, @redwoodjs, @preston-werner-ventures ", "company in not updated with actual value")
        XCTAssertEqual(userItem.followers, 22403, "followers in not updated with actual value")
        XCTAssertEqual(userItem.following, 11, "following in not updated with actual value")
        XCTAssertEqual(userItem.avatar_url, "https://avatars.githubusercontent.com/u/1?v=4", "avatar_url in not updated with actual value")
        // Deleting mock entry
        CoreDataHandler.sharedInstance.deleteGitHubUser(userItem)
    }

    func testDataProccessingAndStoring() throws {
        // adding mock entry
        let userAry = CoreDataHandler.sharedInstance.ParseJSONToCodedataAry(data: userlistResponse)
        XCTAssertEqual(userAry.count, 1, "Response data is not decoded in Coredata entity UserItem")
        // Deleting mock entry
       CoreDataHandler.sharedInstance.deleteGitHubUser(userAry[0])
    }
    func testUserNoteUpdate() throws {
        let userAry = CoreDataHandler.sharedInstance.ParseJSONToCodedataAry(data: userlistResponse)
        let userItem = CoreDataHandler.sharedInstance.fetchUserItem(String(userAry[0].id), withContext: nil)
        userItem?.note = "test note added"
        CoreDataHandler.sharedInstance.saveContext(context:(userItem?.managedObjectContext)!)
        let updatedUserItem = CoreDataHandler.sharedInstance.fetchUserItem(String(userAry[0].id), withContext: nil)
        XCTAssertEqual(updatedUserItem?.note, "test note added", "Note is not updated")
        CoreDataHandler.sharedInstance.deleteGitHubUser(updatedUserItem!) 
    }
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
