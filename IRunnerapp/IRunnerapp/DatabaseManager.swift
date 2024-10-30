import Foundation
import SQLite3

class DatabaseManager {

    static let shared = DatabaseManager() // 创建一个单例
    var db: OpaquePointer?

    private init() {}

    // 获取数据库文件路径
    private func getDatabasePath() -> String {
        return "/Users/nzxkk/Desktop/IRunnerapp/runningapp" // 替换为你的数据库文件名
    }

    // 检查并创建数据库
    func checkAndCreateDatabase() {
        let dbPath = getDatabasePath()

        // 打开数据库，如果数据库不存在则创建
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("成功打开数据库: \(dbPath)")
            createTables()
        } else {
            print("无法打开数据库")
        }
    }

    // 创建所需的表
    private func createTables() {
        if !tableExists(tableName: "students") {
            createStudentsTable()
        } else {
            print("表 students 已存在")
        }

        if !tableExists(tableName: "running_records") {
            createRunningRecordsTable()
        } else {
            print("表 running_records 已存在")
        }
    }

    // 检查表是否存在
    private func tableExists(tableName: String) -> Bool {
        let query = "SELECT name FROM sqlite_master WHERE type='table' AND name='\(tableName)';"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                sqlite3_finalize(statement)
                return true // 表存在
            }
        }

        sqlite3_finalize(statement)
        return false // 表不存在
    }

    // 创建 students 表
    private func createStudentsTable() {
        let createStudentsTableString = """
        CREATE TABLE students (
            student_id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            age INTEGER NOT NULL
        );
        """

        createTable(query: createStudentsTableString, tableName: "students")
    }

    // 创建 running_records 表
    private func createRunningRecordsTable() {
        let createRunningRecordsTableString = """
        CREATE TABLE running_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id INTEGER NOT NULL,
            start_time TEXT NOT NULL,
            end_time TEXT NOT NULL,
            distance REAL NOT NULL,
            duration TEXT NOT NULL,
            speed REAL NOT NULL,
            FOREIGN KEY (student_id) REFERENCES students(student_id)
        );
        """

        createTable(query: createRunningRecordsTableString, tableName: "running_records")
    }

    // 创建表的辅助方法
    private func createTable(query: String, tableName: String) {
        var createTableStatement: OpaquePointer?

        // 准备 SQL 语句
        if sqlite3_prepare_v2(db, query, -1, &createTableStatement, nil) == SQLITE_OK {
            // 执行 SQL 语句
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("成功创建表 \(tableName)")
            } else {
                print("无法创建表 \(tableName)")
            }
        } else {
            print("无法准备创建表 \(tableName) 的 SQL 语句")
        }

        // 释放资源
        sqlite3_finalize(createTableStatement)
    }
    func fetchUserInfo(for studentId: Int) -> (name: String, age: Int)? {
            var statement: OpaquePointer?
            let query = "SELECT username, age FROM students WHERE student_id = ?;"

            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(studentId))

                if sqlite3_step(statement) == SQLITE_ROW {
                    let name = String(cString: sqlite3_column_text(statement, 0))
                    let age = Int(sqlite3_column_int(statement, 1))
                    sqlite3_finalize(statement)
                    return (name, age)
                }
            }

            sqlite3_finalize(statement)
            return nil
        }
    func insertStudent(username: String, password: String, age: Int) -> Bool {
        var statement: OpaquePointer?
        let query = "INSERT INTO students (username, password, age) VALUES (?, ?, ?)"

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (username as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (password as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 3, Int32(age))

            if sqlite3_step(statement) == SQLITE_DONE {
                sqlite3_finalize(statement)
                return true
            } else {
                print("插入失败: \(String(cString: sqlite3_errmsg(db)))") // 打印插入失败的错误信息
            }
        } else {
            print("准备失败: \(String(cString: sqlite3_errmsg(db)))") // 打印准备失败的错误信息
        }

        sqlite3_finalize(statement)
        return false
    }
    func insertRunningRecord(studentId: Int, startTime: String, endTime: String, distance: Double, duration: String, speed: Double, routeImage: Data) -> Bool {
        var statement: OpaquePointer?
        let query = "INSERT INTO running_records (student_id, start_time, end_time, distance, duration, speed, route_image) VALUES (?, ?, ?, ?, ?, ?, ?)"

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(studentId))
            sqlite3_bind_text(statement, 2, (startTime as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (endTime as NSString).utf8String, -1, nil)
            sqlite3_bind_double(statement, 4, distance)
            sqlite3_bind_text(statement, 5, (duration as NSString).utf8String, -1, nil)
            sqlite3_bind_double(statement, 6, speed)
            sqlite3_bind_blob(statement, 7, (routeImage as NSData).bytes, Int32(routeImage.count), nil)

            if sqlite3_step(statement) == SQLITE_DONE {
                sqlite3_finalize(statement)
                return true
            } else {
                print("插入失败: \(String(cString: sqlite3_errmsg(db)))")
            }
        } else {
            print("准备失败: \(String(cString: sqlite3_errmsg(db)))")
        }

        sqlite3_finalize(statement)
        return false
    }

    func fetchRunningRecords(for studentId: Int) -> [(startTime: String, endTime: String, distance: String, duration: String, speed: String, routeImage: Data?)] {
        var records: [(String, String, String, String, String, Data?)] = []
        var statement: OpaquePointer?

        let query = "SELECT start_time, end_time, distance, duration, speed, route_image FROM running_records WHERE student_id = ?"
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(studentId))

            while sqlite3_step(statement) == SQLITE_ROW {
                let startTime = String(cString: sqlite3_column_text(statement, 0))
                let endTime = String(cString: sqlite3_column_text(statement, 1))
                
                // 格式化距离和速度为小数点后两位
                let distance = String(format: "%.2f", sqlite3_column_double(statement, 2))
                let duration = String(cString: sqlite3_column_text(statement, 3))
                let speed = String(format: "%.2f", sqlite3_column_double(statement, 4))

                // 处理 route_image 字段，可能是 nil
                let routeImage: Data?
                if let imageData = sqlite3_column_blob(statement, 5) {
                    let imageSize = sqlite3_column_bytes(statement, 5)
                    routeImage = Data(bytes: imageData, count: Int(imageSize))
                } else {
                    routeImage = nil
                }

                records.append((startTime, endTime, distance, duration, speed, routeImage))
            }
        } else {
            print("准备查询失败: \(String(cString: sqlite3_errmsg(db)))")
        }

        sqlite3_finalize(statement)
        
        print("查询到的记录: \(records)") // 添加调试输出
        return records
    }

    func fetchTotalDistance(for studentId: Int) -> Double {
        var totalDistance: Double = 0
        var statement: OpaquePointer?

        let query = "SELECT SUM(distance) FROM running_records WHERE student_id = ?;"
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(studentId))

            if sqlite3_step(statement) == SQLITE_ROW {
                totalDistance = sqlite3_column_double(statement, 0)
            }
        }
        
        sqlite3_finalize(statement)
        return totalDistance
    }

    func fetchTotalRunningDays(for studentId: Int) -> Int {
        var totalDays: Int = 0
        var statement: OpaquePointer?

        let query = "SELECT COUNT(DISTINCT date(start_time)) FROM running_records WHERE student_id = ?;"
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(studentId))

            if sqlite3_step(statement) == SQLITE_ROW {
                totalDays = Int(sqlite3_column_int(statement, 0))
            }
        }
        
        sqlite3_finalize(statement)
        return totalDays
    }

    func fetchRunningRecordCount(for studentId: Int) -> Int {
        var count: Int = 0
        var statement: OpaquePointer?

        let query = "SELECT COUNT(*) FROM running_records WHERE student_id = ?;"
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(studentId))

            if sqlite3_step(statement) == SQLITE_ROW {
                count = Int(sqlite3_column_int(statement, 0))
            }
        }
        
        sqlite3_finalize(statement)
        return count
    }

    // 关闭数据库
    func closeDatabase() {
        if sqlite3_close(db) != SQLITE_OK {
            print("无法关闭数据库")
        }
        db = nil
    }
}

