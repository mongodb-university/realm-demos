//
//	DateFormatterSet.swift
//

import Foundation

class HourFormatter: Formatter {
	override func string(for obj: Any?) -> String {
		if let num = obj as? TimeInterval {
			let neg: Bool	= num < 0.0
			let fullHours	= abs(Int(num.rounded(.towardZero)))
			let minutes		= abs(Int(((num - num.rounded(.towardZero)) * 60.0).rounded(.towardZero)))
			let desc		= fullHours < 2 ? "hr" : "hrs"
			
			return String(format: "%@%d:%02d %@", neg ? "-" : " ", fullHours, minutes, desc)
		}
		
		return "0:00 hr"
	}
	
	func stringNoUnits(for obj: Any?) -> String {
		if let num = obj as? TimeInterval {
			let neg: Bool	= num < 0.0
			let fullHours	= abs(Int(num.rounded(.towardZero)))
			let minutes		= abs(Int(((num - num.rounded(.towardZero)) * 60.0).rounded(.towardZero)))
			
			return String(format: "%@%d:%02d", neg ? "-" : " ", fullHours, minutes)
		}
		
		return "0:00"
	}
}

class OrdinalDayFormatter: DateFormatter {
	static var ordinalFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .ordinal
		return formatter
	}()
	
	override func string(from date: Date) -> String {
		let day			= calendar.component(.day, from: date)
		let dayOrdinal	= OrdinalDayFormatter.ordinalFormatter.string(from: NSNumber(value: day)) ?? ""
		
		dateFormat	= "EEEE '\(dayOrdinal)' MMM"
		
		return super.string(from: date)
	}
	
	func fullString(from date: Date) -> String {
		let day			= calendar.component(.day, from: date)
		let dayOrdinal	= OrdinalDayFormatter.ordinalFormatter.string(from: NSNumber(value: day)) ?? ""
		
		dateFormat	= "'\(dayOrdinal)' MMM yyyy"
		
		return super.string(from: date)
	}
	
	func noDayString(from date: Date) -> String {
		let day			= calendar.component(.day, from: date)
		let dayOrdinal	= OrdinalDayFormatter.ordinalFormatter.string(from: NSNumber(value: day)) ?? ""
		
		dateFormat	= "'\(dayOrdinal)' MMM"
		
		return super.string(from: date)
	}
}

class NormalizedISOFormatter: ISO8601DateFormatter {
	override func date(from string: String) -> Date? {
		return super.date(from: string.ISO8601Normalized())
	}
}

class DateFormatterSet {
	lazy var dateTimeFormatter: DateFormatter? = {
		let df	= DateFormatter()
		
		df.doesRelativeDateFormatting	= true
		df.dateStyle					= DateFormatter.Style.medium
		df.timeStyle					= DateFormatter.Style.short
		
		return df
	}()
	
	lazy var shortDateTimeFormatter: DateFormatter? = {
		let df	= DateFormatter()
		
		df.doesRelativeDateFormatting	= true
		df.dateStyle					= DateFormatter.Style.short
		df.timeStyle					= DateFormatter.Style.short
		
		return df
	}()

	let isoFormatter	= NormalizedISOFormatter()
	
	lazy var noYearDateFormatter: DateFormatter = {
		let df	= DateFormatter()
		
		df.dateFormat	= "d MMM"
		
		return df
	}()

	lazy var shortDateFormatter: DateFormatter = {
		let df	= DateFormatter()
		
		df.dateStyle	= DateFormatter.Style.short
		df.timeStyle	= DateFormatter.Style.none
		
		return df
	}()

	lazy var mediumDateFormatter: DateFormatter = {
		let df	= DateFormatter()
		
		df.dateStyle	= DateFormatter.Style.medium
		df.timeStyle	= DateFormatter.Style.none
		
		return df
	}()
	
	lazy var shortTimeFormatter: DateFormatter = {
		let df	= DateFormatter()
		
		df.dateStyle	= DateFormatter.Style.none
		df.timeStyle	= DateFormatter.Style.short
		
		return df
	}()
	
	lazy var mediumDateTimeFormatter: DateFormatter = {
		let df	= DateFormatter()
		
		df.dateFormat	= "d MMM YYYY, HH:mm"
		
		return df
	}()

	lazy var hourMinuteTimeFormatter: DateFormatter = {
		let df	= DateFormatter()
		
		df.dateFormat	= "HH:mm"
		
		return df
	}()
	
	lazy var hourFormatter: HourFormatter = { HourFormatter() }()
	
	lazy var ordinalDayFormatter: OrdinalDayFormatter = {
		let df	= OrdinalDayFormatter()
		
		df.calendar	= Calendar.autoupdatingCurrent
		
		return df
	}()
}

let dateFormatters	= DateFormatterSet()

extension String {
	func ISO8601Normalized() -> String {
		return String(prefix(19)) + "Z"
	}
}
