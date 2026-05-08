//
//  AppState.swift
//  DuLich
//
//  Created by Macbook Pro on 6/5/26.
//

import Foundation
import Combine

final class AppState: ObservableObject {
    @Published var hasSeenWelcome: Bool = false

    init() {
        // load from UserDefaults nếu cần
        hasSeenWelcome = UserDefaults.standard.bool(forKey: "hasSeenWelcome")
    }

    func markWelcomeSeen() {
        hasSeenWelcome = true
        UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
    }
}
