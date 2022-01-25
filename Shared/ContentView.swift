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

    @State var operators: [Op] = [Op(text: "AC", bg: "#3C3D3F"),
                                  Op(text: "±", bg: "#3C3D3F"),
                                  Op(text: "%", bg: "#3C3D3F"),
                                  Op(text: "÷", bg: "#F59514")]
    var k_789: [Op] = [Op(text: "7", bg: "#5A5F60"),
                       Op(text: "8", bg: "#5A5F60"),
                       Op(text: "9", bg: "#5A5F60"),
                       Op(text: "×", bg: "#F59514")]
    var k_456: [Op] = [Op(text: "4", bg: "#5A5F60"),
                       Op(text: "5", bg: "#5A5F60"),
                       Op(text: "6", bg: "#5A5F60"),
                       Op(text: "-", bg: "#F59514")]
    var k_123: [Op] = [Op(text: "1", bg: "#5A5F60"),
                       Op(text: "2", bg: "#5A5F60"),
                       Op(text: "3", bg: "#5A5F60"),
                       Op(text: "+", bg: "#F59514")]
    var k_0_dot: [Op] = [Op(text: ".", bg: "#5A5F60"),
                         Op(text: "=", bg: "#F59514")]

    var zero: [Op] = [Op(text: "0", bg: "#5A5F60")]

    @State private var expression: String = "0"
    @State private var curResult: String = "0"

    @State private var canOp: Bool = true

    private var hasOp: Bool {
        get {
            self.expression.hasSuffix("+") ||
                    self.expression.hasSuffix("-") ||
                    self.expression.hasSuffix("×") ||
                    self.expression.hasSuffix("÷")
        }
    }

    func action(op: String) -> Void {
        switch op {
        case "C":
            operators[0].text = "AC"
            curResult = "0"
            canOp = true
            break
        case "AC":
            resetAll()
            break
        case "=":
            calc()
            break
        case "+", "-", "×", "÷":
            if (!canOp) {
                break
            }
            canOp = false
            if (expression == "0") {
                expression = curResult
            } else {
                expression += curResult
            }
            if (hasOp) {
                print(expression.endIndex)
                expression.remove(at: expression.index(before: expression.endIndex))
            }
            expression += op
            print(expression)
            break
        case "±":
            if (curResult.hasPrefix("-")) {
                curResult.remove(at: curResult.startIndex)
            } else if (curResult != "0") {
                curResult = "-" + curResult
            }
            break
        case "%":
            break
        case ".":
            if (!curResult.contains(".")) {
                curResult += "."
            }
            break
        default:
            if (operators[0].text == "AC") {
                operators[0].text = "C"
            }
            if (hasOp && !canOp) {
                curResult = "0"
            }
            if (!canOp) {
                canOp = true
            }
            print(curResult, expression)
            if (curResult == "0") {
                curResult = op
            } else {
                curResult += op
            }
            break
        }
    }

    func resetAll() {
        self.operators[0].text = "AC"
        self.expression = "0"
        self.curResult = "0"
    }

    func calc() {
        if (!canOp) {
            expression += "0"
        } else {
            expression += curResult
        }
        curResult = expression
    }

    var body: some View {
        VStack {
            Text(curResult)
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
                            .font(.system(size: 100))
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
