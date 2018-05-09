//
//  Log.swift
//  BAT
//
//  Created by Benjamin Bourasseau on 13/09/2016.
//  Copyright © 2016 Guaraná Technologies Inc. All rights reserved.
//

import Foundation
import Crashlytics

public class Log {
    
    static func crashlytics(message: String, filename: String = #file, function: String = #function, line: Int = #line) {
        let output: String
        if let filename = NSURL(string: filename)?.lastPathComponent {
            output = "\(filename).\(function) line \(line) $ \(message)"
        } else {
            output = "\(filename).\(function) line \(line) $ \(message)"
        }
        
        #if DEBUG
            CLSNSLogv("%@", getVaList([output]))
        #else
            CLSLogv("%@", getVaList([output]))
        #endif
    }
}
