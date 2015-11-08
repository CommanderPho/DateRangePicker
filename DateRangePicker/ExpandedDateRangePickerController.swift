//
//  ExpandedDateRangePickerController.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Cocoa

extension DateRange {
	func buildMenuItem() -> NSMenuItem {
		switch (self) {
		case Custom, PastDays, CalendarUnit:
			return NSMenuItem(title: title, action: nil, keyEquivalent: "")
		case None:
			return NSMenuItem.separatorItem()
		}
	}
}

public protocol ExpandedDateRangePickerControllerDelegate: class {
	func expandedDateRangePickerController(controller: ExpandedDateRangePickerController, didSetDateRange dateRange: DateRange)
}

public class ExpandedDateRangePickerController: NSViewController {
	let presetRanges: [DateRange] = [
		.Custom(NSDate(), NSDate()),
		.None,
		.PastDays(7),
		.PastDays(15),
		.PastDays(30),
		.PastDays(90),
		.PastDays(365),
		.None,
		.CalendarUnit(0, .WeekOfYear),
		.CalendarUnit(0, .Month),
		.CalendarUnit(0, .Quarter),
		.CalendarUnit(0, .Year)
	]
	@IBOutlet var presetRangeSelector: NSPopUpButton?
	
	// These are needed for the bindings with NSDatePicker
	public dynamic var startDate: NSDate {
		get {
			return dateRange.startDate!
		}
		
		set {
			dateRange = DateRange.Custom(newValue, endDate)
		}
	}
	public dynamic var endDate: NSDate {
		get {
			return dateRange.endDate!
		}
		
		set {
			dateRange = DateRange.Custom(startDate, newValue)
		}
	}
	
	public var dateRange: DateRange {
		willSet {
			self.willChangeValueForKey("endDate")
			self.willChangeValueForKey("startDate")
		}
		
		didSet {
			self.didChangeValueForKey("endDate")
			self.didChangeValueForKey("startDate")
			presetRangeSelector?.selectItemAtIndex(presetRanges.indexOf({ $0 == dateRange }) ?? 0)
			delegate?.expandedDateRangePickerController(self, didSetDateRange: dateRange)
		}
	}
	
	public weak var delegate: ExpandedDateRangePickerControllerDelegate?
	
	public init(dateRange: DateRange) {
		self.dateRange = dateRange
		super.init(nibName: ExpandedDateRangePickerController.className(),
			bundle: NSBundle(forClass: ExpandedDateRangePickerController.self))!
	}
	
	public required init?(coder: NSCoder) {
		dateRange = .None
		super.init(coder: coder)
		assert(false, "This initializer should not be used.")
	}

	public override func awakeFromNib() {
        super.awakeFromNib()
		
		guard let menu = presetRangeSelector?.menu else { return }
		for range in presetRanges {
			menu.addItem(range.buildMenuItem())
		}
		presetRangeSelector?.selectItemAtIndex(presetRanges.indexOf({ $0 == dateRange }) ?? 0)
    }
	
	@IBAction func presetRangeSelected(sender: NSPopUpButton) {
		let selectedRange = presetRanges[sender.indexOfSelectedItem]
		switch (selectedRange) {
		case .Custom, .None:
			dateRange = DateRange.Custom(startDate, endDate)
		case .PastDays, .CalendarUnit:
			dateRange = selectedRange
		}
	}
}
