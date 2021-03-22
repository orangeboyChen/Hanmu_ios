import UIKit


let rawLoc = "信息馆2层西区西自然科学区008号"

//正则表达式匹配三位数字
let range = NSRange(location: 0, length: rawLoc.count)
let pattern = "\\d{3}"
let regex = try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
let resArray = regex.matches(in: rawLoc, options: [.reportProgress], range: range)

var tar: String = ""
if resArray.count > 0 {
    let targetRange = resArray[resArray.count - 1]
    let temp: String = rawLoc
    tar = String(temp.dropFirst(targetRange.range.location).prefix(targetRange.range.length))
    print(tar)
}
print(rawLoc.replacingOccurrences(of: tar + "号", with: ""))

print("233")
