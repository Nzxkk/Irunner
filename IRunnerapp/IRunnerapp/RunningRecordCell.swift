import UIKit

class RunningRecordCell: UITableViewCell {
    let recordLabel = UILabel()
    let routeImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        // 配置记录标签
        recordLabel.numberOfLines = 0
        recordLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(recordLabel)

        // 配置图片视图
        routeImageView.contentMode = .scaleAspectFit
        routeImageView.isUserInteractionEnabled = true
        routeImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(routeImageView)

        // 添加点击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        routeImageView.addGestureRecognizer(tapGesture)

        // 设置约束
        NSLayoutConstraint.activate([
            recordLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            recordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            recordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            routeImageView.topAnchor.constraint(equalTo: recordLabel.bottomAnchor, constant: 10),
            routeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            routeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            routeImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            routeImageView.heightAnchor.constraint(equalToConstant: 200) // 设置固定高度
        ])
    }

    @objc func imageTapped() {
        guard let image = routeImageView.image else { return }
        NotificationCenter.default.post(name: Notification.Name("ImageTapped"), object: image)
    }
}

