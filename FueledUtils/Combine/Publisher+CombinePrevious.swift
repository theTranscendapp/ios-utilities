// Copyright © 2020, Fueled Digital Media, LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Combine

extension Publisher {
	public func combinePrevious() -> AnyPublisher<(previous: Output, current: Output), Failure> {
		self.combinePreviousImplementation(nil)
	}

	public func combinePrevious(_ initial: Output) -> AnyPublisher<(previous: Output, current: Output), Failure> {
		self.combinePreviousImplementation(initial)
	}

	private func combinePreviousImplementation(_ initial: Output?) -> AnyPublisher<(previous: Output, current: Output), Failure> {
		var previousValue = initial
		return self
			.flatMap { output -> AnyPublisher<(previous: Output, current: Output), Failure> in
				defer {
					previousValue = output
				}
				if let currentPreviousValue = previousValue {
					return Just((currentPreviousValue, output))
						.setFailureType(to: Failure.self)
						.eraseToAnyPublisher()
				} else {
					return Empty(completeImmediately: false).eraseToAnyPublisher()
				}
			}
			.eraseToAnyPublisher()
	}
}