//
//  ContentView.swift
//  DEXTHostApp
//
//  Created by Alkenso (Vladimir Vashurkin) on 04.08.2021.
//

import SwiftUI

struct ContentView: View {
    let activate: (@escaping (Error?) -> Void) -> Void
    let deactivate: (@escaping (Error?) -> Void) -> Void
    let ping: (@escaping (Result<(pid_t, String), Error>) -> Void) -> Void
    
    @State var alertMessage: String?
    
    var body: some View {
        VStack {
            Button("Activate") {
                activate {
                    if let error = $0 {
                        alertMessage = "Activation failed: \(error)"
                    } else {
                        alertMessage = "Activated"
                    }
                }
            }
            Button("Deactivate") {
                deactivate {
                    if let error = $0 {
                        alertMessage = "Deactivation failed: \(error)"
                    } else {
                        alertMessage = "Deativated"
                    }
                }
            }
            Button("Ping") {
                ping {
                    switch $0 {
                    case .success(let (pid, version)):
                        alertMessage = "Ping succeeded. Pid = \(pid), version = \(version)"
                    case .failure(let error):
                        alertMessage = "Ping failed: \(error)"
                    }
                }
            }
        }
        .padding()
        .alert(item: $alertMessage) { msg in
            Alert(title: Text(msg))
        }
    }
}

extension String: Identifiable {
    public var id: ObjectIdentifier {
        ObjectIdentifier(self as NSString)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(activate: { _ in }, deactivate: { _ in }, ping: { _ in })
    }
}
