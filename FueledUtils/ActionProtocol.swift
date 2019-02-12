//
//  ActionProtocol.swift
//  FueledUtils
//
//  Created by Stéphane Copin on 1/23/19.
//  Copyright © 2019 Fueled. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

///
/// An optional protocol for `ActionError` for use in type constraints
///
public protocol ActionErrorProtocol: Swift.Error {
	///
	/// Type of the error associated with the action error.
	///
	associatedtype SubError: Swift.Error

	///
	/// Whether the receiver is currently in the disabled state or not.
	///
	var isDisabled: Bool { get }

	///
	/// The error the action protocol currently have. If `nil`, the action error is considered `disabled`.
	///
	var error: SubError? { get }
}

extension ActionError: ActionErrorProtocol {
	///
	/// Whether the receiver is currently in the disabled state or not.
	///
	public var isDisabled: Bool {
		return self.error == nil
	}

	///
	/// The error the action protocol currently have. If `nil`, the action error is considered `disabled`.
	///
	public var error: Error? {
		if case .producerFailed(let error) = self {
			return error
		}
		return nil
	}
}

///
/// A protocol for `Action`s for generic constraints and code reuse.
///
public protocol ActionProtocol {
	///
	/// The type of the values output from the action.
	///
	associatedtype Output
	///
	/// The type of the values used as inputs to the action.
	///
	associatedtype Input
	///
	/// The type of errors emitted by the action.
	///
	associatedtype Error: Swift.Error
	///
	/// The type of errors emitted when applying the action.
	///
	associatedtype ApplyError: Swift.Error

	///
	/// Whether the action is currently executing.
	///
	var isExecuting: Property<Bool> { get }
	///
	/// Whether the action is currently enabled.
	///
	var isEnabled: Property<Bool> { get }
	///
	/// A signal of all events generated from all units of work of the `Action`.
	///
	/// In other words, this sends every `Event` from every unit of work that the `Action`
	/// executes.
	///
	var events: Signal<Signal<Output, Error>.Event, NoError> { get }
	///
	/// A signal of all values generated from all units of work of the `Action`.
	///
	/// In other words, this sends every value from every unit of work that the `Action`
	/// executes.
	///
	var values: Signal<Output, NoError> { get }
	///
	/// A signal of all errors generated from all units of work of the `Action`.
	///
	/// In other words, this sends every error from every unit of work that the `Action`
	/// executes.
	///
	var errors: Signal<Error, NoError> { get }
	///
	/// The lifetime of the `Action`.
	///
	var lifetime: Lifetime { get }

	///
	/// Create a `SignalProducer` that would attempt to create and start a unit of work of
	/// the `Action`. The `SignalProducer` would forward only events generated by the unit
	/// of work it created.
	///
	/// - Parameters:
	///   - input: A value to be used to create the unit of work.
	///
	/// - Returns: A producer that forwards events generated by its started unit of work,
	///   or returns an appropriate `ApplyError` indicating the specific error
	///   that happened.
	///
	func apply(_ input: Input) -> SignalProducer<Output, ApplyError>
}

extension Action: ActionProtocol {
}

extension ActionProtocol where Input == Void {
	///
	/// Create a `SignalProducer` that would attempt to create and start a unit of work of
	/// the `Action`. The `SignalProducer` would forward only events generated by the unit
	/// of work it created.
	///
	/// - Returns: A producer that forwards events generated by its started unit of work,
	///   or returns an appropriate `ApplyError` indicating the specific error
	///   that happened.
	///
	public func apply() -> SignalProducer<Output, ApplyError> {
		return self.apply(())
	}
}