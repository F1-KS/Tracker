import UIKit

// MARK: - Цвет <-> Hex

extension UIColor {
    var hexString: String {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }

    convenience init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        guard hexString.count == 6, let value = UInt64(hexString, radix: 16) else {
            return nil
        }
        let red = CGFloat((value >> 16) & 0xFF) / 255.0
        let green = CGFloat((value >> 8) & 0xFF) / 255.0
        let blue = CGFloat(value & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

// MARK: - DTO

struct TrackerDTO: Codable {
    let id: String
    let name: String
    let colorHex: String
    let emoji: String
    let schedule: [Int]

    func toModel() -> TrackerStruct {
        return TrackerStruct(
            id: UUID(uuidString: id)!,
            name: name,
            color: UIColor(hex: colorHex) ?? .systemBlue,
            emoji: emoji,
            schedule: Set(schedule.compactMap { WeekDays(rawValue: $0) })
        )
    }

    init(model: TrackerStruct) {
        self.id = model.id.uuidString
        self.name = model.name
        self.colorHex = model.color.hexString
        self.emoji = model.emoji
        self.schedule = Array(model.schedule.map { $0.rawValue })
    }
}

struct CategoryDTO: Codable {
    let title: String
    let trackers: [TrackerDTO]

    func toModel() -> TrackerCategoryStruct {
        return TrackerCategoryStruct(
            title: title,
            trackers: trackers.map { $0.toModel() }
        )
    }

    init(model: TrackerCategoryStruct) {
        self.title = model.title
        self.trackers = model.trackers.map { TrackerDTO(model: $0) }
    }
}

struct RecordDTO: Codable {
    let trackerID: String
    let completionDate: Date

    func toModel() -> TrackerRecordStruct {
        return TrackerRecordStruct(
            trackerID: UUID(uuidString: trackerID)!,
            completionDate: completionDate
        )
    }

    init(model: TrackerRecordStruct) {
        self.trackerID = model.trackerID.uuidString
        self.completionDate = model.completionDate
    }
}

// MARK: - Корневой контейнер

private struct TrackerData: Codable {
    let categories: [CategoryDTO]
    let records: [RecordDTO]
}

// MARK: - Хранилище

final class TrackerStorage {

    static let shared = TrackerStorage()

    private let fileURL: URL

    private init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = documents.appendingPathComponent("trackers_data.json")
    }

    func save(categories: [TrackerCategoryStruct], records: [TrackerRecordStruct]) {
        let data = TrackerData(
            categories: categories.map { CategoryDTO(model: $0) },
            records: records.map { RecordDTO(model: $0) }
        )
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let jsonData = try encoder.encode(data)
            try jsonData.write(to: fileURL, options: .atomic)
        } catch {
            print("Ошибка сохранения: \(error)")
        }
    }

    func load() -> (categories: [TrackerCategoryStruct], records: [TrackerRecordStruct])? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        do {
            let jsonData = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let data = try decoder.decode(TrackerData.self, from: jsonData)
            return (
                categories: data.categories.map { $0.toModel() },
                records: data.records.map { $0.toModel() }
            )
        } catch {
            print("Ошибка загрузки: \(error)")
            return nil
        }
    }
}
