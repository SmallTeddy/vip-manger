import Foundation

struct Member: Identifiable, Codable, Comparable {
    var id = UUID()
    var storeName: String       // 店铺名称
    var location: String        // 店铺位置
    var balance: Double         // 余额
    var phoneNumber: String     // 手机号
    var createdAt: Date        // 创建时间
    var updatedAt: Date        // 更新时间
    
    // 实现 Comparable 协议，默认按创建时间排序
    static func < (lhs: Member, rhs: Member) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
    
    // 添加自定义排序方法
    enum SortOption {
        case name, balance, date
    }
    
    static func sort(_ members: [Member], by option: SortOption) -> [Member] {
        switch option {
        case .name:
            return members.sorted { $0.storeName < $1.storeName }
        case .balance:
            return members.sorted { $0.balance > $1.balance }
        case .date:
            return members.sorted { $0.createdAt > $1.createdAt }
        }
    }
} 
