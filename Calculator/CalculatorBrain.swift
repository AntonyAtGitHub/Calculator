//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Antony on 28/9/15.
//  Copyright © 2015 OnUs. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private enum Op: CustomStringConvertible { // Enums and structs have no inheritance. CustomStringConvertible here is a protocol
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {   // Enums, just like structs and classes, can have properties.
                                    // Only computed properties in enums, structs and classes can have properties that are values
            get{
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = Array<Op>()               // = [Op]()
    
    private var knownOps = Dictionary<String, Op>() // = [String:Op]()
    
    
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("×", *))         // Use function as parameter
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        learnOp(Op.UnaryOperation("√", sqrt))       // Used to be knownOps["√"] = Op.UnaryOperation("√", sqrt)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) { // Recursion helper with return type of Tuple
    
        if (!ops.isEmpty) {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
                
            case .Operand(let operand):
                return (operand, remainingOps)
                
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {                     // "if" the result is a Double, which is totally different with Java usage
                    return (operation(operand), operandEvaluation.remainingOps)
                }
                
            case .BinaryOperation(_, let operation):
                let operand1Evaluation = evaluate(remainingOps)
                if let operand1 = operand1Evaluation.result {
                    let operand2Evaluation = evaluate(operand1Evaluation.remainingOps)
                    if let operand2 = operand2Evaluation.result {
                        return (operation(operand1, operand2), operand2Evaluation.remainingOps)
                    }
                }
            }
        }
        
        
        return (nil, ops)
    }
    
    func evaluate() -> Double? {                // Return type here must be an Optional, because it is not always Double.
                                                // Sometimes Error, for example, performing operation without any operands.
        let (result, remainingOps) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainingOps) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {   // operation is an optional Op, because the symbol might be not found in knownOps then nil is returned.
                                                // Whenever you look up something in a dictionay, it always returns an Optional (nil or the type)
                                                // "if" I am able to find the symbol in knownOps, which is totally different with Java usage
            opStack.append(operation)
        }
        
        return evaluate()
    }
}