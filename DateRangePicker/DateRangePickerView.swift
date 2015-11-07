//
//  DateRangePickerView.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Foundation

@IBDesignable
public class DateRangePickerView : NSControl {
	let segmentedControl: NSSegmentedControl
	let dateFormatter = NSDateFormatter()
	var dateRangePickerController: ExpandedDateRangePickerController?
	
	public var startDate: NSDate {
		didSet {
			dateRangePickerController?.startDate = startDate
			updateSegmentedControl()
		}
	}
	public var endDate: NSDate {
		didSet {
			dateRangePickerController?.endDate = endDate
			updateSegmentedControl()
		}
	}
	
	public var dateStyle: NSDateFormatterStyle {
		get {
			return dateFormatter.dateStyle
		}
		
		set {
			dateFormatter.dateStyle = newValue
			updateSegmentedControl()
		}
	}
	
	public var dateRangeString: String {
		get {
			return "\(dateFormatter.stringFromDate(startDate)) - \(dateFormatter.stringFromDate(endDate))"
		}
	}
	
	override public func layout() {
		let sideButtonWidth: CGFloat = 22
		// Magic number to avoid the segmented control overflowing out of its bounds.
		let unusedControlWidth: CGFloat = 8
		segmentedControl.setWidth(sideButtonWidth, forSegment:0)
		segmentedControl.setWidth(self.bounds.size.width - 2 * sideButtonWidth - unusedControlWidth, forSegment:1)
		segmentedControl.setWidth(sideButtonWidth, forSegment:2)
		segmentedControl.frame = self.bounds
		super.layout()
	}
	
	required public init?(coder: NSCoder) {
		segmentedControl = NSSegmentedControl()
		segmentedControl.segmentStyle = .TexturedRounded
		segmentedControl.segmentCount = 3
		segmentedControl.setLabel("◀", forSegment: 0)
		segmentedControl.setLabel("▶", forSegment: 2)
		segmentedControl.action = "segmentDidChange:"
		segmentedControl.autoresizingMask = [.ViewNotSizable]
		(segmentedControl.cell as? NSSegmentedCell)?.trackingMode = .Momentary
		
		endDate = NSDate()
		startDate = endDate.drp_addDays(-6)!
		
		super.init(coder: coder)
		segmentedControl.target = self
		self.addSubview(segmentedControl)
		
		self.dateStyle = .MediumStyle
	}
	
	func segmentDidChange(sender: NSSegmentedControl) {
		// The left and right buttons shift the start and end dates by
		// their difference plus one, so that the new and old date ranges do not overlap.
		let dayDifference = endDate.drp_daysSince(startDate) + 1
		switch (sender.selectedSegment) {
		case 0:
			endDate = endDate.drp_addDays(-dayDifference)!
			startDate = startDate.drp_addDays(-dayDifference)!
		case 1:
			let popover = NSPopover()
			popover.behavior = .Semitransient
			dateRangePickerController = ExpandedDateRangePickerController(startDate: startDate, endDate: endDate)
			popover.contentViewController = dateRangePickerController
			popover.showRelativeToRect(self.bounds, ofView: self, preferredEdge: .MinY)
		case 2:
			endDate = endDate.drp_addDays(dayDifference)!
			startDate = startDate.drp_addDays(dayDifference)!
		default:
			break
		}
	}
	
	private func updateSegmentedControl() {
		segmentedControl.setLabel(dateRangeString, forSegment: 1)
	}
}
