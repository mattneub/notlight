struct DateState: Equatable {
    let predefinedContent = [
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
    ]

    var predefinedIndex = 0
    var predefinedKey: String {
        predefinedContent[predefinedIndex]["key"] ?? ""
    }

    let relativeContent = [
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
    ]

    var relativeIndex = 0
    var relativeKey: String {
        relativeContent[relativeIndex]["key"] ?? ""
    }
    var relativeQuantity = 1

    let agoContent = [
        [
            "name":"Ago",
            "key":"-",
        ],
        [
            "name":"From Now",
            "key":"",
        ],
    ]

    var agoIndex = 0
    var agoKey: String {
        agoContent[agoIndex]["key"] ?? ""
    }

    var absoluteDate = Date.now
}
