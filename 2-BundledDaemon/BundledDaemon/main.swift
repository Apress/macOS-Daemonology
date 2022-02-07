//
//  main.swift
//  BundledDaemon
//
//  Created by Alkenso on 2/6/21.
//

import Foundation


NSLog("Daemonology: bundled daemon has pid \(getpid()).")

RunLoop.main.run()
