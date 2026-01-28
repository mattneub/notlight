enum DateAction: Equatable {
    case agoPopup(Int)
    case datePicker(Date)
    case initialData
    case predefinedPopup(Int)
    case relativePopup(Int)
    case relativeQuantity(Int)
    case useAbsolute
    case usePredefined
    case useRelative
}
