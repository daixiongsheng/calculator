//
//  ContentView.swift
//  Shared
//
//  Created by daixiongsheng on 2022/1/16.
//

import SwiftUI

struct Op: Identifiable {
    var id = UUID()
    var text: String;
    var bg: String;
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
                .sRGB,
                red: Double(r) / 255,
                green: Double(g) / 255,
                blue: Double(b) / 255,
                opacity: Double(a) / 255
        )
    }
}

struct ContentView: View {

    @State private var operators: [Op] = [Op(text: "AC", bg: "#3C3D3F"),
                                          Op(text: "±", bg: "#3C3D3F"),
                                          Op(text: "%", bg: "#3C3D3F"),
                                          Op(text: "÷", bg: "#F59514")]
    private var k_789: [Op] = [Op(text: "7", bg: "#5A5F60"),
                               Op(text: "8", bg: "#5A5F60"),
                               Op(text: "9", bg: "#5A5F60"),
                               Op(text: "×", bg: "#F59514")]
    private var k_456: [Op] = [Op(text: "4", bg: "#5A5F60"),
                               Op(text: "5", bg: "#5A5F60"),
                               Op(text: "6", bg: "#5A5F60"),
                               Op(text: "-", bg: "#F59514")]
    private var k_123: [Op] = [Op(text: "1", bg: "#5A5F60"),
                               Op(text: "2", bg: "#5A5F60"),
                               Op(text: "3", bg: "#5A5F60"),
                               Op(text: "+", bg: "#F59514")]
    private var k_0_dot: [Op] = [Op(text: ".", bg: "#5A5F60"),
                                 Op(text: "=", bg: "#F59514")]
    private var zero: [Op] = [Op(text: "0", bg: "#5A5F60")]

    @State private var displayValue: String = "0"
    @State private var lastOp: String = ""
    @State private var lastOp2: String = ""
    @State private var prefixNums: [String] = []
    @State private var lastOpNumber = ""

    func action(op: String) -> Void {
        switch op {
        case "C":
            operators[0].text = "AC"
            displayValue = "0"
            break
        case "AC":
            resetAll()
            break
        case "=":
            if (prefixNums.isEmpty && lastOpNumber == "" && lastOp2 == "") {
                return
            }
            if (lastOp2 != "" && prefixNums.isEmpty && lastOpNumber == "") {
                prefixNums.append(displayValue)
                prefixNums.append(lastOp2)
            } else if (lastOpNumber != "" && lastOp != "") {
                prefixNums.append(displayValue)
                prefixNums.append(lastOp2)
                prefixNums.append(lastOpNumber)
            } else {
                prefixNums.append(displayValue)
            }
            calc()
            lastOp = lastOp2
            break
        case "+", "-", "×", "÷":
            lastOp = op
            lastOp2 = op
            break
        case "±":
            if (lastOp != "") {
                prefixNums.append(displayValue)
                prefixNums.append(lastOp)
                lastOp = ""
            }
            if (displayValue.hasPrefix("-")) {
                displayValue.removeFirst()
            } else if (displayValue != "0") {
                displayValue = "-" + displayValue
            }
            break
        case "%":
            let f = (displayValue as NSString).doubleValue
            if (f == 0.0) {
                displayValue = "0"
            } else {
                displayValue = String(f / 100.0)
            }
            break
        case ".":
            if (!displayValue.contains(".")) {
                displayValue += "."
            }
            break
        default:
            if (operators[0].text == "AC") {
                operators[0].text = "C"
            }
            if (lastOp != "") {
                prefixNums.append(displayValue)
                prefixNums.append(lastOp)
                lastOp = ""
                displayValue = "0"
            }
            if (displayValue == "0") {
                displayValue = op
            } else {
                displayValue += op
            }
            lastOpNumber = displayValue
            break
        }
    }

    func resetAll() {
        displayValue = "0"
        prefixNums.removeAll()
        lastOpNumber = ""
        lastOp = ""
        lastOp2 = ""
    }

    func isOp(op: String) -> Bool {
        switch op {
        case "+", "-", "×", "÷", "(", ")":
            return true
        default:
            return false
        }
    }

    func greatThan(op1: String, op2: String) -> Bool {
        switch op1 {
        case "(", "-", "+":
            return false
        default:
            break
        }
        switch op2 {
        case "*", "÷":
            return false
        default:
            return true
        }
    }

    func calc() {
        if (prefixNums.isEmpty) {
            return
        }
        var opera: [String] = []
        var suffix: [String] = []
        for op in prefixNums {
            com:
            if (isOp(op: op)) {
                if (op == ")") {
                    while (!opera.isEmpty) {
                        let this = opera.removeLast()
                        if (this == "(") {
                            break
                        }
                        suffix.append(this)
                    }
                } else if (op == "(" || opera.isEmpty || greatThan(op1: op, op2: opera.last!)) {
                    opera.append(op)
                } else {
                    suffix.append(opera.removeLast())
                    break com
                }
            } else {
                suffix.append(op)
            }
        }
        while (!opera.isEmpty) {
            suffix.append(opera.removeLast())
        }
        print("suffix", suffix)
        print("prefixNums", prefixNums)
        var nums: [Double] = []
        for op in suffix {
            if (isOp(op: op)) {
                print(nums.count)
                let op1 = nums.removeLast()
                let op2 = nums.removeLast()
                nums.append(computer(a: op2, b: op1, op: op))
            } else {
                nums.append((op as NSString).doubleValue)
            }
        }
        print("nums", nums)
        prefixNums.removeAll()
        var r = String(nums[0])
        if (r.hasSuffix(".0")) {
            r.removeLast()
            r.removeLast()
        }
        displayValue = r
    }

    func computer(a: Double, b: Double, op: String) -> Double {
        switch op {
        case "+":
            return a + b
        case "-":
            return a - b
        case "×":
            return a * b
        case "÷":
            return a / b
        default:
            return 0.0
        }
    }

    var body: some View {
        VStack {
            Text(displayValue)
                    .foregroundColor(Color(hex: "#FDF1E1"))
                    .font(.system(size: 180))
                    .minimumScaleFactor(0.01)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, maxHeight: 180, alignment: .bottomTrailing)
            HStack {
                VStack {
                    HStack {
                        btn(ops: operators, action: self.action)
                    }
                    HStack {
                        btn(ops: k_789, action: self.action)
                    }
                    HStack {
                        btn(ops: k_456, action: self.action)
                    }
                    HStack {
                        btn(ops: k_123, action: self.action)
                    }
                    HStack {
                        HStack {
                            btn(ops: zero, action: self.action)
                        }
                        HStack {
                            btn(ops: k_0_dot, action: self.action)
                        }
                    }
                }
            }
        }
                .background(Color(hex: "#27272D"))
                .edgesIgnoringSafeArea(.all)

    }

    func btn(ops: [Op], action: @escaping (String) -> ()) -> some View {
        ForEach(ops) {
            op in
            VStack {
                Button(action: { action(op.text) }) {
                    Text(op.text)
                            .foregroundColor(Color(hex: "#FDF1E1"))
                            .font(.system(size: 68))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(hex: op.bg))
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
