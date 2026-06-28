//
//  CategoriesManager.swift
//  Tracker
//

final class CategoriesManager {
    static let shared = CategoriesManager()
    private let store = TrackerCategoryStore()
    private init() {}

    var categories: [String] { store.categoryTitles }

    func addCategory(title: String) {
        try? store.addCategory(title: title)
    }
}
