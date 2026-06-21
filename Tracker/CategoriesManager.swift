//
//  CategoriesManager.swift
//  Tracker
//

final class CategoriesManager {
    static let shared = CategoriesManager()
    private init() {}

    var categories: [String] = ["Важное"]
}
