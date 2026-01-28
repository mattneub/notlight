import Testing
@testable import NotLight3
import Foundation

private struct DateStateTests {
    @Test("built-in constants are correct")
    func constants() {
        let subject = DateState()
        #expect(subject.predefinedContent == [
            [
                "name":"Now",
                "key":"$time.now",
            ],
            [
                "name":"Today",
                "key":"$time.today",
            ],
            [
                "name":"Yesterday",
                "key":"$time.yesterday",
            ],
            [
                "name":"This Week",
                "key":"$time.this_week",
            ],
            [
                "name":"This Month",
                "key":"$time.this_month",
            ],
            [
                "name":"This Year",
                "key":"$time.this_year",
            ],
        ])
        #expect(subject.relativeContent == [
            [
                "name":"Seconds",
                "key":"$time.now",
            ],
            [
                "name":"Days",
                "key":"$time.today",
            ],
            [
                "name":"Weeks",
                "key":"$time.this_week",
            ],
            [
                "name":"Months",
                "key":"$time.this_month",
            ],
            [
                "name":"Years",
                "key":"$time.this_year",
            ],
        ])
        #expect(subject.agoContent == [
            [
                "name":"Ago",
                "key":"-",
            ],
            [
                "name":"From Now",
                "key":"",
            ],
        ])
    }

    @Test("predefinedKey is correctly calculated")
    func predefinedKey() {
        var subject = DateState()
        subject.predefinedIndex = 1
        #expect(subject.predefinedKey == "$time.today")
    }

    @Test("relativeKey is correctly calculated")
    func relativeKey() {
        var subject = DateState()
        subject.relativeIndex = 1
        #expect(subject.relativeKey == "$time.today")
    }

    @Test("agoKey is correctly calculated")
    func agoKey() {
        var subject = DateState()
        subject.agoIndex = 1
        #expect(subject.agoKey == "")
    }
}
