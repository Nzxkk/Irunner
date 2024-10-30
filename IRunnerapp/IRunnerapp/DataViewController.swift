import UIKit

class DataViewController: UIViewController {
    var studentId: Int?
    var allRunningRecords: [(startTime: String, endTime: String, distance: String, duration: String, speed: String, routeImage: Data?)] = []
    var filteredRecords: [(startTime: String, endTime: String, distance: String, duration: String, speed: String, routeImage: Data?)] = []

    let startDatePicker = UIDatePicker()
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1) // 设置柔和背景色

        // 获取跑步记录
        if let studentId = studentId {
            allRunningRecords = DatabaseManager.shared.fetchRunningRecords(for: studentId)
            filteredRecords = allRunningRecords // 初始化为所有记录
        }

        setupUI()
        
        // 监听图片点击事件
        NotificationCenter.default.addObserver(self, selector: #selector(showImage(_:)), name: Notification.Name("ImageTapped"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "跑步记录"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // 添加日期选择器
        startDatePicker.datePickerMode = .date
        startDatePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        let stackView = UIStackView(arrangedSubviews: [startDatePicker])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        // 创建 UITableView 显示跑步记录
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RunningRecordCell.self, forCellReuseIdentifier: "RunningRecordCell")
        tableView.backgroundColor = UIColor.clear // 透明背景
        view.addSubview(tableView)

        // 设置约束
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc func dateChanged() {
        let selectedDate = startDatePicker.date

        // 筛选记录，只考虑开始日期
        filteredRecords = allRunningRecords.filter { record in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let start = dateFormatter.date(from: record.startTime) {
                return Calendar.current.isDate(start, inSameDayAs: selectedDate)
            }
            return false
        }

        // 刷新表格
        tableView.reloadData()
    }

    @objc func showImage(_ notification: Notification) {
        guard let image = notification.object as? UIImage else { return }

        let imageViewController = UIViewController()
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.frame = imageViewController.view.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageViewController.view.addSubview(imageView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissImage))
        imageView.addGestureRecognizer(tapGesture)

        present(imageViewController, animated: true, completion: nil)
    }

    @objc func dismissImage() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension DataViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredRecords.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // 每个分区只有一行
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RunningRecordCell", for: indexPath) as! RunningRecordCell
        
        let record = filteredRecords[indexPath.section]
        
        // 显示详细信息
        cell.recordLabel.text = """
        开始时间: \(record.startTime)
        结束时间: \(record.endTime)
        距离: \(record.distance) 米
        时长: \(record.duration)
        速度: \(record.speed) 米/秒
        """
        
        // 设置单元格样式
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.1
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 4

        // 显示图片
        if let imageData = record.routeImage {
            cell.routeImageView.image = UIImage(data: imageData)
        } else {
            cell.routeImageView.image = nil // 如果没有图片，设置为 nil
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension DataViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "记录 \(section + 1)"
    }
}

