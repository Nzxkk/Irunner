import UIKit

class LoginViewController: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "iRunner"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "用户名"
        textField.borderStyle = .roundedRect
        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "密码"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        return textField
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("登录", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()

    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("注册", for: .normal)
        button.backgroundColor = UIColor.systemGreen
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(showRegister), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        DatabaseManager.shared.checkAndCreateDatabase()
        view.backgroundColor = UIColor.systemBackground
        setupLayout()
    }

    private func setupLayout() {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, usernameTextField, passwordTextField, loginButton, registerButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc private func loginButtonTapped() {
        guard let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "请填写用户名和密码")
            return
        }

        if let studentID = validateLogin(username: username, password: password) {
            // 登录成功，保存 studentID
            UserDefaults.standard.set(studentID, forKey: "loggedInStudentId")
            
            // 跳转到 AppTabBarController
            let tabBarController = AppTabBarController()
            navigationController?.setViewControllers([tabBarController], animated: true)
        } else {
            showAlert(message: "用户名或密码错误")
        }
    }

    private func validateLogin(username: String, password: String) -> Int? {
        var statement: OpaquePointer?
        let query = "SELECT student_id FROM students WHERE username = ? AND password = ?"
        
        if sqlite3_prepare_v2(DatabaseManager.shared.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (username as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (password as NSString).utf8String, -1, nil)

            if sqlite3_step(statement) == SQLITE_ROW {
                let studentID = sqlite3_column_int(statement, 0)
                sqlite3_finalize(statement)
                return Int(studentID) // 返回学生 ID
            }
        }
        sqlite3_finalize(statement)
        return nil
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }

    @objc private func showRegister() {
        let registerViewController = RegisterViewController()
        navigationController?.pushViewController(registerViewController, animated: true)
    }

}

