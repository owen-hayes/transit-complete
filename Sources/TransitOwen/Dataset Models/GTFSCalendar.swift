//
//  Calendar.swift
//
//
//  Created by Owen Hayes on 6/2/24.
//

import Foundation

// MARK: CalendarField

/// All fields that may appear within a `Calendar` record.
public enum CalendarField: String, Hashable, KeyPathVending {
    /// Service ID field.
    case serviceID = "service_id"
    /// Monday field.
    case monday
    /// Tuesday field.
    case tuesday
    /// Wednesday field.
    case wednesday
    /// Thursday field.
    case thursday
    /// Friday field.
    case friday
    /// Saturday field.
    case saturday
    /// Sunday field.
    case sunday
    /// Start date field.
    case startDate = "start_date"
    /// End date field.
    case endDate = "end_date"
    /// Used when a nonstandard field is found within a GTFS feed.
    case nonstandard

    internal var path: AnyKeyPath {
        switch self {
        case .serviceID: return \GTFSCalendar.serviceID
        case .monday: return \GTFSCalendar.monday
        case .tuesday: return \GTFSCalendar.tuesday
        case .wednesday: return \GTFSCalendar.wednesday
        case .thursday: return \GTFSCalendar.thursday
        case .friday: return \GTFSCalendar.friday
        case .saturday: return \GTFSCalendar.saturday
        case .sunday: return \GTFSCalendar.sunday
        case .startDate: return \GTFSCalendar.startDate
        case .endDate: return \GTFSCalendar.endDate
        case .nonstandard: return \GTFSCalendar.nonstandard
        }
    }
}

// MARK: - Calendar

/// A representation of a single Calendar record.
public struct GTFSCalendar: Hashable, Identifiable {
    public let id = UUID()
    public var serviceID: String = ""
    public var monday: String = ""
    public var tuesday: String = ""
    public var wednesday: String = ""
    public var thursday: String = ""
    public var friday: String = ""
    public var saturday: String = ""
    public var sunday: String = ""
    public var startDate: String = ""
    public var endDate: String = ""
    public var nonstandard: String? = nil

    public static let requiredFields: Set =
        [CalendarField.serviceID, CalendarField.monday, CalendarField.tuesday,
         CalendarField.wednesday, CalendarField.thursday, CalendarField.friday,
         CalendarField.saturday, CalendarField.sunday, CalendarField.startDate, CalendarField.endDate]

    public init(
        serviceID: String = "",
        monday: String = "",
        tuesday: String = "",
        wednesday: String = "",
        thursday: String = "",
        friday: String = "",
        saturday: String = "",
        sunday: String = "",
        startDate: String = "",
        endDate: String = ""
    ) {
        self.serviceID = serviceID
        self.monday = monday
        self.tuesday = tuesday
        self.wednesday = wednesday
        self.thursday = thursday
        self.friday = friday
        self.saturday = saturday
        self.sunday = sunday
        self.startDate = startDate
        self.endDate = endDate
    }

    public init(
        from record: String,
        using headers: [CalendarField]
    ) throws {
        do {
            let fields = try record.readRecord()
            if fields.count != headers.count {
                throw TransitError.headerRecordMismatch
            }
            for (index, header) in headers.enumerated() {
                let field = fields[index]
                switch header {
                case .serviceID, .monday, .tuesday, .wednesday, .thursday,
                     .friday, .saturday, .sunday, .startDate, .endDate:
                    try field.assignStringTo(&self, for: header)
                case .nonstandard:
                    continue
                }
            }
        } catch {
            throw error
        }
    }
}

extension GTFSCalendar: Equatable {
    public static func == (lhs: GTFSCalendar, rhs: GTFSCalendar) -> Bool {
        return
            lhs.serviceID == rhs.serviceID &&
            lhs.monday == rhs.monday &&
            lhs.tuesday == rhs.tuesday &&
            lhs.wednesday == rhs.wednesday &&
            lhs.thursday == rhs.thursday &&
            lhs.friday == rhs.friday &&
            lhs.saturday == rhs.saturday &&
            lhs.sunday == rhs.sunday &&
            lhs.startDate == rhs.startDate &&
            lhs.endDate == rhs.endDate
    }
}

extension GTFSCalendar: CustomStringConvertible {
    public var description: String {
        return "Calendar: \(self.serviceID)"
    }
}

// MARK: - Calendars

/// - Tag: Calendars
public struct Calendars: Identifiable, Equatable {
    public let id = UUID()
    public var headerFields = [CalendarField]()
    fileprivate var calendars = [GTFSCalendar]()

    subscript(index: Int) -> GTFSCalendar {
        get {
            return self.calendars[index]
        }
        set(newValue) {
            self.calendars[index] = newValue
        }
    }

    mutating func add(_ calendar: GTFSCalendar) {
        // TODO: Add to header fields supported by this collection
        self.calendars.append(calendar)
    }

    mutating func remove(_ calendar: GTFSCalendar) {}

    init<S: Sequence>(_ sequence: S)
        where S.Iterator.Element == GTFSCalendar
    {
        for calendar in sequence {
            self.add(calendar)
        }
    }

    init(from url: URL) throws {
//        print("trying cals!")
        do {
            let records = try String(contentsOf: url).splitRecords()

            if records.count < 1 { return }
            let headerRecord = String(records[0])
            self.headerFields = try headerRecord.readHeader()

            self.calendars.reserveCapacity(records.count - 1)
            for calendarRecord in records[1 ..< records.count] {
                let calendar = try GTFSCalendar(from: String(calendarRecord), using: headerFields)
                self.add(calendar)
            }
        } catch {
            throw error
        }
    }
}

extension Calendars: Sequence {
    public typealias Iterator = IndexingIterator<[GTFSCalendar]>

    public func makeIterator() -> Iterator {
        return self.calendars.makeIterator()
    }
}
