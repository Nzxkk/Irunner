import UIKit

class AppTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let runViewController = RunViewController()
        let dataViewController = DataViewController()
        let profileViewController = ProfileViewController()
        // 获取当前登录学生的 ID
        let studentId = UserDefaults.standard.integer(forKey: "loggedInStudentId")
        dataViewController.studentId = studentId // 设置 studentId
                
        runViewController.tabBarItem = UITabBarItem(title: "跑步", image: UIImage(systemName: "figure.run"), tag: 0)
        dataViewController.tabBarItem = UITabBarItem(title: "数据", image: UIImage(systemName: "chart.bar"), tag: 1)
        profileViewController.tabBarItem = UITabBarItem(title: "我的", image: UIImage(systemName: "person"), tag: 2)
        
        let viewControllers = [runViewController, dataViewController, profileViewController]
        self.viewControllers = viewControllers.map { UINavigationController(rootViewController: $0) }
        
        // 设置标签栏背景色
        tabBar.barTintColor = UIColor.white // 设置为你想要的颜色
        tabBar.isTranslucent = false // 确保不透明
    }
}


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)

        // 创建 LoginViewController 实例
        let loginViewController = LoginViewController()
        
        // 使用 UINavigationController 包裹 LoginViewController
        let navigationController = UINavigationController(rootViewController: loginViewController)
        
        // 设置导航控制器为根视图控制器
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}



