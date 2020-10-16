// Copyright © 2020 Fueled Digital Media, LLC
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

import Quick
import Nimble
import FueledUtils
import ReactiveSwift

class CoalescingActionSpec: QuickSpec {
	override func spec() {
		describe("CoalescingAction") {
			describe("apply.dispose()") {
				it("should dispose of all created signal producers") {
					var startCounter = 0
					var disposeCounter = 0
					var interruptedCounter = 0
					let coalescingAction = ReactiveCoalescingAction {
						SignalProducer(value: 2.0)
							.delay(1.0, on: QueueScheduler.main)
							.on(
								started: {
									startCounter += 1
								},
								interrupted: {
									interruptedCounter += 1
								},
								disposed: {
									disposeCounter += 1
								}
							)
					}

					expect(startCounter) == 0

					let producersCount = 5
					let disposables = (0..<producersCount).map { _ in coalescingAction.apply().start() }

					expect(startCounter) == 1

					disposables[0].dispose()

					expect(disposeCounter) == 0
					expect(interruptedCounter) == 0

					disposables[1..<producersCount].forEach { $0.dispose() }

					expect(disposeCounter).toEventually(equal(1))
					expect(interruptedCounter).toEventually(equal(1))
				}
			}
		}
	}
}
