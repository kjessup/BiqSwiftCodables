//
//  SwiftCodables.swift
//  Biq
//
//  Created by Kyle Jessup on 2017-12-05.
//

import Foundation

public typealias UserId = UUID
public typealias DeviceURN = String
public typealias Id = UUID

public protocol IdHashable: Hashable {
	associatedtype IdType: Hashable
	var id: IdType { get }
}

extension IdHashable {
	public var hashValue: Int {
		return id.hashValue
	}
	public static func ==(lhs: Self, rhs: Self) -> Bool {
		return lhs.id == rhs.id
	}
}

public enum ObsDatabase {
	public struct BiqObservation: Codable {
		public let id: Int
		public var deviceId: DeviceURN { return bixid }
		public let bixid: DeviceURN
		public let obstime: Double
		// I don't know why they are stored in the db as milliseconds and as a Double
		public var obsTimeSeconds: Double { return obstime / 1000 }
		public let charging: Int
		public let firmware: String
		public let wifiFirmware: String?
		public let battery: Double
		public let temp: Double
		public let light: Int
		public let humidity: Int
		public let accelx: Int
		public let accely: Int
		public let accelz: Int
		public init(id i: Int,
					deviceId d: DeviceURN,
					obstime: Double,
					charging: Int,
					firmware: String,
					wifiFirmware: String,
					battery: Double,
					temp: Double,
					light: Int,
					humidity: Int,
					accelx: Int,
					accely: Int,
					accelz: Int) {
			id = i
			bixid = d
			self.obstime = obstime
			self.charging = charging
			self.firmware = firmware
			self.wifiFirmware = wifiFirmware
			self.battery = battery
			self.temp = temp
			self.light = light
			self.humidity = humidity
			self.accelx = accelx
			self.accely = accely
			self.accelz = accelz
		}
	}
}

public struct BiqDeviceFlag: OptionSet {
	public let rawValue: Int
	public init(rawValue r: Int) {
		rawValue = r
	}
	public static let locked = BiqDeviceFlag(rawValue: 1)
	public static let temperatureCapable = BiqDeviceFlag(rawValue: 1<<2)
	public static let movementCapable = BiqDeviceFlag(rawValue: 1<<3)
	public static let lightCapable = BiqDeviceFlag(rawValue: 1<<4)
}

public struct BiqDevice: Codable, IdHashable {
	public let id: DeviceURN
	public let name: String
	public let ownerId: UserId?
	public let flags: Int?
	public let latitude: Double?
	public let longitude: Double?
	
	public let groupMemberships: [BiqDeviceGroupMembership]?
	public let accessPermissions: [BiqDeviceAccessPermission]?
	
	public var deviceFlags: BiqDeviceFlag {
		return BiqDeviceFlag(rawValue: flags ?? 0)
	}
	public init(id i: DeviceURN,
				name n: String,
				ownerId o: UserId? = nil,
				flags f: BiqDeviceFlag? = nil,
				latitude la: Double? = nil,
				longitude lo: Double? = nil) {
		id = i
		name = n
		ownerId = o
		flags = f?.rawValue
		latitude = la
		longitude = lo
		
		groupMemberships = nil
		accessPermissions = nil
	}
}

public struct BiqDeviceGroup: Codable, IdHashable {
	public let id: Id
	public let ownerId: UserId
	public let name: String
	public let devices: [BiqDevice]?
	
	public init(id i: Id,
				ownerId o: UserId,
				name n: String) {
		id = i
		ownerId = o
		name = n
		devices = nil
	}
}

public struct BiqDeviceGroupMembership: Codable {
	public let groupId: Id
	public let deviceId: DeviceURN
	public init(groupId g: Id,
				deviceId d: DeviceURN) {
		groupId = g
		deviceId = d
	}
}

public struct BiqDeviceAccessPermission: Codable {
	public let userId: UserId
	public let deviceId: DeviceURN
	public let flags: Int? 
	public init(userId u: UserId,
				deviceId d: DeviceURN,
				flags f: Int = 0) {
		userId = u
		deviceId = d
		flags = f
	}
}

public enum TemperatureScale: Int {
	case celsius, fahrenheit
}

public enum BiqDeviceLimitType: UInt8, Codable {
	case tempHigh,
		 tempLow
	case movementLevel
	case batteryLevel
	case notifications
	case tempScale
	case colour
	case interval
	case reportFormat
	case reportBufferCapacity
	case lightLevel
	case humidityLevel
}

public struct BiqDeviceLimit: Codable {
	public let userId: UserId
	public let deviceId: DeviceURN
	public let limitType: UInt8
	public let limitValue: Float
	public let limitValueString: String?
	public var type: BiqDeviceLimitType? { return BiqDeviceLimitType(rawValue: limitType) }
	public init(userId u: UserId, deviceId d: DeviceURN, limitType t: BiqDeviceLimitType, limitValue v: Float = 0.0, limitValueString vs: String? = nil) {
		userId = u
		deviceId = d
		limitType = t.rawValue
		limitValue = v
		limitValueString = vs
	}
}

public struct BiqDevicePushLimit: Codable {
	public let deviceId: DeviceURN
	public let limitType: UInt8
	public let limitValue: Float
	public let limitValueString: String?
	public var type: BiqDeviceLimitType? { return BiqDeviceLimitType(rawValue: limitType) }
	public init(deviceId d: DeviceURN, limitType t: BiqDeviceLimitType, limitValue v: Float = 0.0, limitValueString vs: String? = nil) {
		deviceId = d
		limitType = t.rawValue
		limitValue = v
		limitValueString = vs
	}
}

public struct BiqDeviceFirmware: Codable {
	public let version: String
	public let type: Int
	public let supersedes: String?
	public let obsoletedBy: String?
	public init(version: String, type: Int, supersedes: String?, obsoletedBy: String?) {
		self.version = version
		self.type = type
		self.supersedes = supersedes
		self.obsoletedBy = obsoletedBy
	}
}
// Requests / Responses 

public enum GroupAPI {
	public struct CreateRequest: Codable {
		public let name: String
		public init(name h: String) {
			name = h
		}
	}
	
	public struct DeleteRequest: Codable {
		public let groupId: Id
		public init(groupId h: Id) {
			groupId = h
		}
	}
	
	public struct UpdateRequest: Codable {
		public let groupId: Id
		public let name: String?
		public init(groupId g: Id, name n: String? = nil) {
			groupId = g
			name = n
		}
	}
	
	public struct ListDevicesRequest: Codable {
		public let groupId: Id
		public init(groupId h: Id) {
			groupId = h
		}
	}
	
	public struct AddDeviceRequest: Codable {
		public let groupId: Id
		public let deviceId: DeviceURN
		public init(groupId h: Id, deviceId d: DeviceURN) {
			groupId = h
			deviceId = d
		}
	}
}

public enum DeviceAPI {
	public struct GenericDeviceRequest: Codable {
		public let deviceId: DeviceURN
		public init(deviceId d: DeviceURN) {
			deviceId = d
		}
	}
	
	public typealias RegisterRequest = GenericDeviceRequest
	public typealias LimitsRequest = GenericDeviceRequest
	
	// request to share someone else's biq
	public struct ShareRequest: Codable {
		public let deviceId: DeviceURN
		public let token: UUID?
		public init(deviceId d: DeviceURN, token t: UUID? = nil) {
			deviceId = d
			token = t
		}
	}
	
	// request to produce a token which permits others to share biq
	public struct ShareTokenRequest: Codable {
		public let deviceId: DeviceURN
		public init(deviceId d: DeviceURN) {
			deviceId = d
		}
	}
	
	public struct ShareTokenResponse: Codable {
		public let token: UUID
		public init(token t: UUID) {
			token = t
		}
	}
	
	public struct UpdateRequest: Codable {
		public let deviceId: DeviceURN
		public let name: String?
		public let flags: Int?
		public var deviceFlags: BiqDeviceFlag? {
			if let f = flags {
				return BiqDeviceFlag(rawValue: f)
			}
			return nil
		}
		public init(deviceId g: DeviceURN, name n: String? = nil, flags f: BiqDeviceFlag? = nil) {
			deviceId = g
			name = n
			flags = f?.rawValue
		}
	}
	
	public struct DeviceLimit: Codable {
		public let limitType: BiqDeviceLimitType
		public let limitValue: Float?
		public let limitValueString: String?
		public init(limitType t: BiqDeviceLimitType, limitValue v: Float?, limitValueString vs: String? = nil) {
			limitType = t
			limitValue = v
			limitValueString = vs
		}
	}
	
	public struct UpdateLimitsRequest: Codable {
		public let deviceId: DeviceURN
		public let limits: [DeviceLimit]
		public init(deviceId g: DeviceURN, limits l: [DeviceLimit]) {
			deviceId = g
			limits = l
		}
	}
	
	public typealias DeviceLimitsResponse = UpdateLimitsRequest
	
	public struct ListDevicesResponseItem: Codable {
		public let device: BiqDevice
		public let lastObservation: ObsDatabase.BiqObservation?
		public let shareCount: Int?
		public let limits: [DeviceLimit]?
		public init(device d: BiqDevice, shareCount s: Int, lastObservation o: ObsDatabase.BiqObservation?, limits l: [DeviceLimit]) {
			device = d
			shareCount = s
			lastObservation = o
			limits = l
		}
	}
	public struct ObsRequest: Codable {
		public enum Interval: Int, Codable {
			case all,
				live, // 12 hours
				day, month, year
		}
		public let deviceId: DeviceURN
		public let interval: Int // fix - enums with associated + codable
		public init(deviceId d: DeviceURN, interval i: Interval) {
			deviceId = d
			interval = i.rawValue
		}
	}
}

public enum Observation {
	public enum Element: Int {
		case deviceId,
		firmwareVersion,
		batteryLevel,
		charging,
		temperature,
		lightLevel,
		relativeHumidity,
		relativeTemperature,
		acceleration // xyz
		
	}
}

// ••temperature••
public extension BinaryFloatingPoint {
	var oneDecimalPlace: String {
		return String(format: "%.1f", Float(Float(Int(self * 10))/10))
	}
	var fahrenheit2Celsius: Self {
		return (self - 32) * 5 / 9
	}
	var celsius2Fahrenheit: Self {
		return self * 9 / 5 + 32
	}
	var nearestFive: Self {
		return (self * 2).rounded() / 2
	}
}

public extension TemperatureScale {
	func format<T: BinaryFloatingPoint>(_ temp: T) -> String {
		switch self {
		case .celsius:
			return "\(temp.oneDecimalPlace)ºC"
		case .fahrenheit:
			return "\(temp.oneDecimalPlace)ºF"
		}
	}
	func formatC<T: BinaryFloatingPoint>(_ temp: T) -> String {
		return format(fromC(temp))
	}
	func asC<T: BinaryFloatingPoint>(_ d: T) -> T {
		guard !d.isNaN else {
			return d
		}
		switch self {
		case .celsius:
			return d
		case .fahrenheit:
			return d.fahrenheit2Celsius
		}
	}
	func fromC<T: BinaryFloatingPoint>(_ d: T) -> T {
		guard !d.isNaN else {
			return d
		}
		switch self {
		case .celsius:
			return d
		case .fahrenheit:
			return d.celsius2Fahrenheit
		}
	}
	var suffix: String {
		switch self {
		case .celsius:
			return "C"
		case .fahrenheit:
			return "F"
		}
	}
}
