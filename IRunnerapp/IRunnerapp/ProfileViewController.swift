import UIKit

class ProfileViewController: UIViewController {
    
    var studentId: Int! // 存储当前用户的 ID
    private let nameLabel = UILabel()
    private let ageLabel = UILabel()
    private let achievementsLabel = UILabel() // 用于显示成就的标签
    private let containerView = UIView() // 容器视图
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGray6 // 设置背景颜色
        
        setupContainerView()
        setupLabels()
        fetchUserInfo()
        AchievementsManager.shared.checkAndUnlockAchievements(for: studentId) // 检查并解锁成就
        displayAchievements() // 显示成就
    }
    
    private func setupContainerView() {
        containerView.layer.cornerRadius = 10 // 圆角
        containerView.layer.shadowColor = UIColor.black.cgColor // 阴影颜色
        containerView.layer.shadowOpacity = 0.1 // 阴影透明度
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2) // 阴影偏移
        containerView.layer.shadowRadius = 5 // 阴影半径
        containerView.backgroundColor = .white // 设置容器视图的背景颜色
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupLabels() {
        // 设置成就标签
        achievementsLabel.textAlignment = .center
        achievementsLabel.font = UIFont.systemFont(ofSize: 18)
        achievementsLabel.numberOfLines = 0
        achievementsLabel.textColor = UIColor.darkGray // 成就颜色
        achievementsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 设置姓名标签
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20) // 姓名字体大小
        nameLabel.textColor = UIColor.systemBlue // 姓名颜色
        nameLabel.numberOfLines = 1 // 限制为一行
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 设置年龄标签
        ageLabel.textAlignment = .center
        ageLabel.font = UIFont.systemFont(ofSize: 18)
        ageLabel.textColor = UIColor.systemGray // 年龄颜色
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 所有标签都添加到 containerView 中
        containerView.addSubview(achievementsLabel) // 先添加成就标签
        containerView.addSubview(nameLabel)
        containerView.addSubview(ageLabel)
        
        // 设置布局
        NSLayoutConstraint.activate([
            achievementsLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            achievementsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            achievementsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            nameLabel.topAnchor.constraint(equalTo: achievementsLabel.bottomAnchor, constant: 10), // 名字位于成就下方
            nameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            ageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5), // 年龄位于名字下方
            ageLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            ageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20) // 添加底部约束
        ])
    }
    
    private func fetchUserInfo() {
        // 从 UserDefaults 获取 studentId
        guard let studentId = UserDefaults.standard.value(forKey: "loggedInStudentId") as? Int, studentId > 0 else {
            nameLabel.text = "无法获取用户信息"
            ageLabel.text = ""
            return
        }
        
        // 从数据库获取用户信息
        if let userInfo = DatabaseManager.shared.fetchUserInfo(for: studentId) {
            nameLabel.text = userInfo.name // 只显示姓名
            ageLabel.text = "年龄: \(userInfo.age)"
            self.studentId = studentId // 保存 studentId 供后续使用
        } else {
            nameLabel.text = "无法获取用户信息"
            ageLabel.text = ""
        }
    }
    
    private func displayAchievements() {
        let achievements = AchievementsManager.shared.achievements
        var unlockedAchievements: [String] = []

        for achievement in achievements {
            if achievement.isUnlocked {
                unlockedAchievements.append("✅ \(achievement.title): 成就已获得") // 已解锁的成就
            } else {
                unlockedAchievements.append("❌ \(achievement.title): 尚未获得") // 未解锁的成就
            }
        }

        achievementsLabel.text = unlockedAchievements.joined(separator: "\n") // 使用换行符连接成就
    }
}

