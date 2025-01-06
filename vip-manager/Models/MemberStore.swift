import Foundation
import SwiftUI

@MainActor
class MemberStore: ObservableObject {
    @Published private(set) var members: [Member] = []
    private var isLoading = false
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                  in: .userDomainMask,
                                  appropriateFor: nil,
                                  create: false)
            .appendingPathComponent("members.data")
    }
    
    func load() async {
        guard !isLoading else { return }
        isLoading = true
        
        do {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                isLoading = false
                return
            }
            let members = try JSONDecoder().decode([Member].self, from: data)
            await MainActor.run {
                withAnimation {
                    self.members = members.sorted { $0.createdAt > $1.createdAt }
                }
            }
        } catch {
            print("Error loading members: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func addMember(_ member: Member) {
        withAnimation {
            members.insert(member, at: 0)
        }
        
        // 异步保存
        Task {
            do {
                try await save()
                print("Successfully saved member: \(member.storeName)")
            } catch {
                print("Error saving member: \(error.localizedDescription)")
                // 如果保存失败，从列表中移除
                await MainActor.run {
                    withAnimation {
                        members.removeAll { $0.id == member.id }
                    }
                }
            }
        }
    }
    
    private func save() async throws {
        let data = try JSONEncoder().encode(members)
        let outfile = try Self.fileURL()
        try data.write(to: outfile)
    }
    
    func updateMember(_ member: Member) {
        withAnimation {
            if let index = members.firstIndex(where: { $0.id == member.id }) {
                members[index] = member
            }
        }
        
        Task {
            do {
                try await save()
                print("Successfully updated member: \(member.storeName)")
            } catch {
                print("Error updating member: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteMember(_ member: Member) {
        withAnimation {
            members.removeAll { $0.id == member.id }
        }
        
        Task {
            do {
                try await save()
                print("Successfully deleted member: \(member.storeName)")
            } catch {
                print("Error deleting member: \(error.localizedDescription)")
            }
        }
    }
} 
