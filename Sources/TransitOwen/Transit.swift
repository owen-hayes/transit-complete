//
// Transit.swift
//

import Foundation

/// - Tag: TransitID
public typealias TransitID = String

/// - Tag: KeyPathVending
internal protocol KeyPathVending {
    var path: AnyKeyPath { get }
}

/// - Tag: TransitError
public enum TransitError: Error {
    case emptySubstring
    case commaExpected
    case quoteExpected
    case invalidFieldType
    case missingRequiredFields
    case headerRecordMismatch
    case invalidColor
}

extension TransitError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptySubstring:
            return "Substring is empty"
        case .commaExpected:
            return "A comma was expected, but not found"
        case .quoteExpected:
            return "A quote was expected, but not found"
        case .invalidFieldType:
            return "An invalid field type was found"
        case .missingRequiredFields:
            return "One or more required fields is missing"
        case .headerRecordMismatch:
            return "The number of header and data fields are not the same"
        case .invalidColor:
            return "An invalid color was found"
        }
    }
}

/// - Tag: TransitAssignError
public enum TransitAssignError: Error {
    case invalidPath
    case invalidValue
}

extension TransitAssignError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidPath:
            return "Path is invalid"
        case .invalidValue:
            return "Could not value convert to target type"
        }
    }
}

/// - Tag: TransitSomethingError
public enum TransitSomethingError: Error {
    case noDataRecordsFound
}

/// - Tag: Feed
public struct Feed: Identifiable, Equatable {
    public static func == (lhs: Feed, rhs: Feed) -> Bool {
        lhs.id == rhs.id
            && lhs.agencies == rhs.agencies
            && lhs.routes == rhs.routes
            && lhs.stops == rhs.stops
            && lhs.trips == rhs.trips
            && lhs.stopTimes == rhs.stopTimes
            && lhs.calendars == rhs.calendars
            && lhs.shapes == rhs.shapes
            && lhs.agency == rhs.agency
    }

    public let id = UUID()
    public var agencies: Agencies?
    public var routes: Routes?
    public var stops: Stops?
    public var trips: Trips?
    public var stopTimes: StopTimes?
    public var calendars: Calendars? // Added property for Calendars
    public var shapes: GTFSShapes? // Added property for Shapes

    public var agency: Agency? {
        return agencies?[0]
    }

    public init(contentsOfURL url: URL) {
        print(url)
        do {
            let agencyFileURL = url.appendingPathComponent("agency.txt")
            let routesFileURL = url.appendingPathComponent("routes.txt")
            let stopsFileURL = url.appendingPathComponent("stops.txt")
            let tripsFileURL = url.appendingPathComponent("trips.txt")
            let stopTimesFileURL = url.appendingPathComponent("stop_times.txt")
            let calendarsFileURL = url.appendingPathComponent("calendar.txt")
            let shapesFileURL = url.appendingPathComponent("shapes.txt")

            self.agencies = try Agencies(from: agencyFileURL)

            self.routes = try Routes(from: routesFileURL)
            self.stops = try Stops(from: stopsFileURL)
            self.trips = try Trips(from: tripsFileURL)

            self.stopTimes = try StopTimes(from: stopTimesFileURL)

            self.calendars = try Calendars(from: calendarsFileURL)
            self.shapes = try GTFSShapes(from: shapesFileURL)
        } catch {
            print("ERROR occurred :( \(error)")
            return
        }
    }
}
