class Achievement {
    let id: Int
    let title: String
    var isUnlocked: Bool

    init(id: Int, title: String, isUnlocked: Bool = false) {
        self.id = id
        self.title = title
        self.isUnlocked = isUnlocked
    }
}

class AchievementsManager {
    static let shared = AchievementsManager()
    
    private(set) var achievements: [Achievement] = [
        Achievement(id: 1, title: "跑步100米"),
        Achievement(id: 2, title: "连续跑步7天"),
        Achievement(id: 3, title: "完成10次运动记录")
    ]
    
    private init() {}
    
    // 检查并解锁成就的方法
    func checkAndUnlockAchievements(for studentId: Int) {
        // ... 之前的实现
        let totalDistance = DatabaseManager.shared.fetchTotalDistance(for: studentId)
               let totalDays = DatabaseManager.shared.fetchTotalRunningDays(for: studentId)
               let totalRecords = DatabaseManager.shared.fetchRunningRecordCount(for: studentId)

               if totalDistance >= 100 {
                   unlockAchievement(withId: 1) // 跑步100米
               }

               if totalDays >= 7 {
                   unlockAchievement(withId: 2) // 连续跑步7天
               }

               if totalRecords >= 10 {
                   unlockAchievement(withId: 3) // 完成10次运动记录
               }

               saveAchievements()
    }

    func unlockAchievement(withId id: Int) {
        if let index = achievements.firstIndex(where: { $0.id == id }) {
            achievements[index].isUnlocked = true
            print("解锁成就：\(id)")
        }
    }

    func saveAchievements() {
        // 保存成就状态的逻辑
        print("保存成就状态")
    }
}

