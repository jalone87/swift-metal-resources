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
        
        // values [ -1 , 1 ]
        
        var value = Float(0)
        
        // calculate average loudness
        vDSP_measqv(data, 1, &value, frameLength)
        // values [ 0 , 1 ]
        
        // convert to decibel
        var db = convertToDecibel(value)
        // values [ -160 , -0 ] 0 loudest
        
        //inverse dB to +ve range where 0(silent) -> 160(loudest)
        db = 160 + db
        // values [ 0 , 160 ]
        
        // bring them to a useful scale between intermediated normalized values
        // let dividor = Float(160/0.3)
        // let adjustedVal = 0.3 + db/dividor
        // values [ 0.3 , 0.6 ]
        
        // this way values will be in a very narrow bandwith between 0.53 and 0.58, where audible laudness is. let's use another algorithm, and give more importance to that band
        
        //Only take into account range from 120->160, so FSR = 40
        db = db - 120
        let dividor = Float(40/0.3)
        var adjustedVal = 0.3 + db/dividor
        
        //cutoff
        if (adjustedVal < 0.3) {
            adjustedVal = 0.3
        } else if (adjustedVal > 0.6) {
            adjustedVal = 0.6
        }
        
        return adjustedVal
    }
    
    @inline(__always)
    static func convertToDecibel(_ value: Float) -> Float {
        return 10 * log10f(value)
    }
    
    /// interpolate between previous and current loudness value
    static func interpolate(current: Float, previous: Float) -> [Float]{
        var vals = [Float](repeating: 0, count: 11)
        
        vals[10] = current
        vals[5] = (current + previous)/2
        
        vals[2] = (vals[5] + previous)/2
        vals[1] = (vals[2] + previous)/2
        vals[8] = (vals[5] + current)/2
        vals[9] = (vals[10] + current)/2
        vals[7] = (vals[5] + vals[9])/2
        vals[6] = (vals[5] + vals[7])/2
        vals[3] = (vals[1] + vals[5])/2
        vals[4] = (vals[3] + vals[5])/2
        vals[0] = (previous + vals[1])/2

        return vals
    }
}
