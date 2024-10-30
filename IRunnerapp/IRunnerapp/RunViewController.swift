import UIKit
import MapKit
import CoreLocation

class RunViewController: UIViewController, CLLocationManagerDelegate {

    var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var isRunning = false // 跑步状态
    var isPaused = false // 暂停状态
    var startStopButton: UIButton!
    var pauseButton: UIButton!

    var polyline: MKPolyline?
    var locations: [CLLocation] = [] // 存储位置点
    var startLocation: CLLocation? // 初始位置
    var startTime: Date? // 开始时间

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupLocationManager()
        setupStartStopButton()
        setupPauseButton()
    }

    func setupMapView() {
        mapView = MKMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.showsUserLocation = true
        view.addSubview(mapView)
    }

    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1 // 设置为每米更新一次，确保频率较高
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func setupStartStopButton() {
        startStopButton = UIButton(type: .system)
        startStopButton.setTitle("开始跑步", for: .normal)
        startStopButton.addTarget(self, action: #selector(startStopButtonTapped), for: .touchUpInside)

        startStopButton.translatesAutoresizingMaskIntoConstraints = false
        startStopButton.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        startStopButton.layer.cornerRadius = 10

        view.addSubview(startStopButton)

        NSLayoutConstraint.activate([
            startStopButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startStopButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            startStopButton.widthAnchor.constraint(equalToConstant: 150),
            startStopButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func setupPauseButton() {
        pauseButton = UIButton(type: .system)
        pauseButton.setTitle("暂停", for: .normal)
        pauseButton.addTarget(self, action: #selector(pauseButtonTapped), for: .touchUpInside)

        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        pauseButton.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        pauseButton.layer.cornerRadius = 10

        view.addSubview(pauseButton)

        NSLayoutConstraint.activate([
            pauseButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            pauseButton.bottomAnchor.constraint(equalTo: startStopButton.topAnchor, constant: -20),
            pauseButton.widthAnchor.constraint(equalToConstant: 150),
            pauseButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        pauseButton.isHidden = true // 初始隐藏暂停按钮
    }

    @objc func startStopButtonTapped() {
        if !isRunning {
            // 开始跑步
            isRunning = true
            isPaused = false
            startStopButton.setTitle("结束跑步", for: .normal)
            locationManager.startUpdatingLocation()
            pauseButton.isHidden = false // 显示暂停按钮
            locations.removeAll() // 清空之前的位置
            startLocation = nil // 重置初始位置
            startTime = Date() // 记录开始时间
        } else {
            // 结束跑步
            isRunning = false
            startStopButton.setTitle("开始跑步", for: .normal)
            locationManager.stopUpdatingLocation()
            pauseButton.isHidden = true // 隐藏暂停按钮
            
            if let polyline = polyline {
                mapView.removeOverlay(polyline)
            }

            // 计算总距离和时间
            let totalDistance = calculateTotalDistance()
            let totalTime = Date().timeIntervalSince(startTime ?? Date())
            let speed = totalTime > 0 ? totalDistance / totalTime : 0 // 速度 = 距离 / 时间
            
            // 获取当前学生的 ID
            let studentId = UserDefaults.standard.integer(forKey: "loggedInStudentId")

            // 格式化开始和结束时间
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let startTimeString = dateFormatter.string(from: startTime ?? Date())
            let endTimeString = dateFormatter.string(from: Date())
            let durationString = String(format: "%.2f 秒", totalTime)

            // 捕获地图图像
                    if let mapImage = captureMapImage() {
                        if let imageData = mapImage.pngData() { // 或使用 jpegData(compressionQuality:)
                            // 插入数据到数据库
                            let result = DatabaseManager.shared.insertRunningRecord(studentId: studentId, startTime: startTimeString, endTime: endTimeString, distance: totalDistance, duration: durationString, speed: speed, routeImage: imageData)
                            
                            if result {
                                print("跑步记录及路线图插入成功")
                            } else {
                                print("跑步记录插入失败")
                            }
                        }
                    }
            

            // 输出结果
            print("总距离: \(totalDistance) 米")
            print("总时间: \(totalTime) 秒")
            print("平均速度: \(speed) 米/秒")
        }
    }


    @objc func pauseButtonTapped() {
        if !isPaused {
            // 暂停跑步
            isPaused = true
            startStopButton.setTitle("继续跑步", for: .normal)
            locationManager.stopUpdatingLocation()
        } else {
            // 继续跑步
            isPaused = false
            startStopButton.setTitle("结束跑步", for: .normal)
            locationManager.startUpdatingLocation()
        }
    }
    func captureMapImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(mapView.bounds.size, false, 0.0)
        mapView.drawHierarchy(in: mapView.bounds, afterScreenUpdates: true)
        let mapImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return mapImage
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // 输出经纬度
        print("当前经度: \(location.coordinate.longitude), 当前纬度: \(location.coordinate.latitude)")

        // 更新用户位置
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)

        // 添加当前位置到数组
        self.locations.append(location)
        
        // 设置初始位置
        if startLocation == nil {
            startLocation = location // 记录初始位置
        }

        // 绘制路径
        if isRunning {
            drawPath()
        }
    }

    func drawPath() {
        // 移除之前的路径
        if let polyline = polyline {
            mapView.removeOverlay(polyline)
        }
        
        // 创建新的路径
        polyline = MKPolyline(coordinates: locations.map { $0.coordinate }, count: locations.count)
        mapView.addOverlay(polyline!)
    }

    func calculateTotalDistance() -> CLLocationDistance {
        guard let startLocation = startLocation else { return 0 }
        var totalDistance: CLLocationDistance = 0
        
        for location in locations {
            totalDistance += startLocation.distance(from: location)
        }
        
        return totalDistance
    }

    // MKMapViewDelegate 方法
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.delegate = self
    }
}

// MKMapViewDelegate 实现
extension RunViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.blue // 设置路径颜色
            renderer.lineWidth = 5.0 // 设置路径宽度
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

