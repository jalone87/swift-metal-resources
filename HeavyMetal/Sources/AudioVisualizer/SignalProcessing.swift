//
//  SignalProcessing.swift
//  HeavyMetal
//
//  Created by Lorenzo Tognalini on 12.02.25.
//

import Cocoa
import Accelerate

class SignalProcessing {
    
    /// Calculate the root mean squared of a signal
    /// https://developer.apple.com/documentation/accelerate/vdsp_rmsqv
    static func rms(data: UnsafeMutablePointer<Float>, frameLength: UInt) -> Float {
        var value = Float(0)
        vDSP_measqv(data, 1, &value, frameLength)
        
        var db = convertToDecibel(value)
        
        db = 160 + db;
        let dividor = Float(160/0.3)
        let adjustedVal = 0.3 + db/dividor
        return adjustedVal
    }
    
    @inline(__always)
    static func convertToDecibel(_ value: Float) -> Float {
        return 10 * log10f(value)
    }
}
