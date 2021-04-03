
import Foundation
import CoreData
public extension CodingUserInfoKey {
    // Helper property to retrieve the Core Data managed object context
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}

extension UserItem {
    //    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserItem> {
    //        return NSFetchRequest<UserItem>(entityName: "UserItem")
    //    }
}
@objc(UserItem)
public class UserItem: NSManagedObject, Codable {
    
    @NSManaged public var avatar_url: String?
    @NSManaged public var blog: String?
    @NSManaged public var company: String?
    @NSManaged public var followers: NSNumber?
    @NSManaged public var following: NSNumber?
    @NSManaged public var id: Int32
    @NSManaged public var is_viewed: Bool
    @NSManaged public var login: String?
    @NSManaged public var note: String?
    @NSManaged public var type: String?
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case avatar_url
        case login
        case company
        case blog
        case followers
        case following
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
              let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: "UserItem", in: managedObjectContext) else {
            fatalError("Failed to decode User")
        }
        
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        login = try container.decode(String.self, forKey: .login)
        id = try container.decode(Int32.self, forKey: .id)
        avatar_url = try container.decode(String.self, forKey: .avatar_url)
        company = try? container.decode(String.self, forKey: .company)
        blog = try? container.decode(String.self, forKey: .blog)
        followers = try? container.decode(Int32.self, forKey: .followers) as NSNumber
        following = try? container.decode(Int32.self, forKey: .following) as NSNumber
    }
    
    
    public func encode(to encoder: Encoder) throws {
    }
}
