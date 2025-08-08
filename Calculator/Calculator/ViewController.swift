//
//  ViewController.swift
//  Calculator
//
//  Created by Koray Urun on 6.08.2025.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var historyPanelView: UIView!
    @IBOutlet var historyTableView: UITableView!
    @IBOutlet var displayLabel: UILabel!
    var history: [(expression: String, result: String)] = []
    var currentExpression: [String] = []
    var currentNumber: String = ""
    var lastWasOperator: Bool = false
    var dotUsed: Bool = false
    var isResultDisplayed = false
    var isHistoryVisible = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayLabel.text = ""
        historyTableView.delegate = self
        historyTableView.dataSource = self
        loadHistory()
        view.layoutIfNeeded()
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeDown.direction = .down
        historyPanelView.addGestureRecognizer(swipeDown)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
            let item = history[indexPath.row]
            cell.textLabel?.text = "\(item.expression) = \(item.result)"
            return cell
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        let tag = sender.tag
        
        switch tag {
        case 0...9:
            if isResultDisplayed {
                    displayLabel.text = "\(tag)"
                    currentNumber = "\(tag)"
                    isResultDisplayed = false
                } else {
                    currentNumber += "\(tag)"
                    displayLabel.text! += "\(tag)"
                }
                lastWasOperator = false
        case 10: // +
            appendOperator("+")
        case 11: // -
            appendOperator("-")
        case 12: // ×
            appendOperator("*")
        case 13: // ÷
            appendOperator("/")
        case 14: // =
            if !currentNumber.isEmpty {
                currentExpression.append(currentNumber)
            }

            let expressionString = currentExpression.joined(separator: " ")
            let result = evaluateExpression()
            displayLabel.text = result
            history.append((expression: "\(expressionString)", result: result))
            historyTableView.reloadData()
            saveHistory()

            // 5. Temizlik
            currentExpression.removeAll()
            currentNumber = ""
            dotUsed = false
            lastWasOperator = false
            isResultDisplayed = true

            
        case 15: // AC
            currentExpression.removeAll()
            currentNumber = ""
            displayLabel.text = ""
            dotUsed = false
            lastWasOperator = false
        case 16: // +/-
            if !currentNumber.isEmpty {
                if currentNumber.first == "-" {
                    currentNumber.removeFirst()
                } else {
                    currentNumber = "-" + currentNumber
                }
                updateDisplay()
            }
        case 17: // %
            if let num = Double(currentNumber) {
                currentNumber = String(num / 100)
                updateDisplay()
            }
        case 18: // .
            if !dotUsed {
                if currentNumber.isEmpty {
                    currentNumber = "0."
                    displayLabel.text! += "0."
                } else {
                    currentNumber += "."
                    displayLabel.text! += "."
                }
                dotUsed = true
            }
            
        case 19: // Switch
            if self.presentingViewController != nil {
                // Bilimsel moddayız, bu VC modally sunulmuş → geri dön
                self.dismiss(animated: true, completion: nil)
            } else {
                // Normal moddayız, bilimsel moda geç → segue tetikle
                performSegue(withIdentifier: "toScienceVC", sender: self)
            }

        
        default:
            break
        }
    }
    
    func appendOperator(_ op: String) {
        guard !lastWasOperator else { return }
        
        if !currentNumber.isEmpty {
            currentExpression.append(currentNumber)
            currentNumber = ""
            dotUsed = false
        }
        currentExpression.append(op)
        displayLabel.text! += " \(op) "
        lastWasOperator = true
    }
    
    func updateDisplay() {
        // Güncel ifadeyi tekrar yaz
        let expression = currentExpression.joined(separator: " ") + (currentNumber.isEmpty ? "" : " \(currentNumber)")
        displayLabel.text = expression
    }
    
    func evaluateExpression() -> String {
        let postfix = infixToPostfix(currentExpression)
        let result = evaluatePostfix(postfix)
        if result.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(result))
        } else {
            return String(result)
        }
    }
    
    func precedence(_ op: String) -> Int {
        switch op {
        case "+", "-": return 1
        case "*", "/": return 2
        default: return 0
        }
    }
    
    func infixToPostfix(_ tokens: [String]) -> [String] {
        var output: [String] = []
        var stack: [String] = []
        
        for token in tokens {
            if Double(token) != nil {
                output.append(token)
            } else if "+-*/".contains(token) {
                while let last = stack.last, precedence(last) >= precedence(token) {
                    output.append(stack.removeLast())
                }
                stack.append(token)
            }
        }
        while let op = stack.popLast() {
            output.append(op)
        }
        return output
    }
    
    func evaluatePostfix(_ tokens: [String]) -> Double {
        var stack: [Double] = []
        
        for token in tokens {
            if let num = Double(token) {
                stack.append(num)
            } else if "+-*/".contains(token), stack.count >= 2 {
                let b = stack.removeLast()
                let a = stack.removeLast()
                switch token {
                case "+": stack.append(a + b)
                case "-": stack.append(a - b)
                case "*": stack.append(a * b)
                case "/": stack.append(a / b)
                default: break
                }
            }
            
        }
        
        
        return stack.last ?? 0
    }
    
    
 


    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .down {
            isHistoryVisible = false
        }
    }

    
    func saveHistory() {
        let stringHistory = history.map { "\($0.expression)|\($0.result)" }
        UserDefaults.standard.set(stringHistory, forKey: "history")
    }

    func loadHistory() {
        if let saved = UserDefaults.standard.stringArray(forKey: "history") {
            history = saved.map {
                let components = $0.split(separator: "|", maxSplits: 1).map(String.init)
                if components.count == 2 {
                    return (expression: components[0], result: components[1])
                } else {
                    return (expression: components[0], result: "")
                }
            }
                historyTableView.reloadData()
        }
    }
    
    
    @IBAction func cleanHistoryTapped(_ sender: UIButton) {
        history.removeAll()
        UserDefaults.standard.removeObject(forKey: "history") // 3. Kalıcı geçmişi de sil
        historyTableView.reloadData()

    }
    
    

    
    
    
    
    
    
    
    
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    

