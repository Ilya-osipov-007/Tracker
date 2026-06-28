//
//  TrackersViewController.swift
//  Tracker
//

import UIKit

final class TrackersViewController: UIViewController {

    // MARK: - Data

    private lazy var categoryStore: TrackerCategoryStore = {
        let store = TrackerCategoryStore()
        store.delegate = self
        return store
    }()
    private lazy var recordStore = TrackerRecordStore()

    var categories: [TrackerCategory] { categoryStore.categories }
    var currentDate: Date = Date()

    private var visibleCategories: [TrackerCategory] = []
    private var searchText: String = ""
    private var isDatePickerAttached = false

    // MARK: - UI

    private lazy var datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.preferredDatePickerStyle = .compact
        dp.datePickerMode = .date
        dp.locale = Locale(identifier: "ru_RU")
        dp.backgroundColor = .clear
        dp.date = currentDate
        dp.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return dp
    }()

    private lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Поиск"
        sb.searchBarStyle = .minimal
        sb.delegate = self
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private let placeholderImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "Icon_star"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let placeholderLabel: UILabel = {
        let l = UILabel()
        l.text = "Что будем отслеживать?"
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupUI()
        filterTrackers()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true

        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addTrackerTapped)
        )
        addButton.tintColor = .label
        navigationItem.leftBarButtonItem = addButton
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let navbar = navigationController?.navigationBar,
              !isDatePickerAttached else { return }
        isDatePickerAttached = true
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        navbar.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.trailingAnchor.constraint(equalTo: navbar.trailingAnchor, constant: -16),
            datePicker.centerYAnchor.constraint(equalTo: navbar.topAnchor, constant: 22),
        ])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if datePicker.superview is UINavigationBar {
            datePicker.removeFromSuperview()
            isDatePickerAttached = false
        }
    }

    private func setupUI() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(
            TrackerCategoryHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCategoryHeader.identifier
        )

        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),

            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),

            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    // MARK: - Filtering

    private func filteredCategories(for date: Date, searchText: String) -> [TrackerCategory] {
        let weekdayIndex = Calendar.current.component(.weekday, from: date)
        guard let weekDay = WeekDay(rawValue: weekdayIndex) else { return [] }

        return categories.compactMap { category in
            let filtered = category.trackers.filter { tracker in
                let matchesSchedule = tracker.schedule.map { $0.contains(weekDay) } ?? true
                let matchesSearch = searchText.isEmpty ||
                    tracker.name.localizedCaseInsensitiveContains(searchText)
                return matchesSchedule && matchesSearch
            }
            return filtered.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filtered)
        }
    }

    private func filterTrackers() {
        visibleCategories = filteredCategories(for: currentDate, searchText: searchText)
        collectionView.reloadData()
        updatePlaceholder()
    }

    private func updatePlaceholder() {
        let isEmpty = visibleCategories.isEmpty
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }

    // MARK: - Tracker helpers

    private func completionCount(for tracker: Tracker) -> Int {
        recordStore.completedTrackers.filter { $0.trackerId == tracker.id }.count
    }

    private func isCompleted(_ tracker: Tracker) -> Bool {
        recordStore.completedTrackers.contains(TrackerRecord(trackerId: tracker.id, date: currentDate))
    }

    private func isFutureDate(_ date: Date) -> Bool {
        Calendar.current.compare(date, to: Date(), toGranularity: .day) == .orderedDescending
    }

    // MARK: - Adding trackers

    func addTracker(_ tracker: Tracker, toCategory categoryTitle: String) {
        try? categoryStore.addTracker(tracker, toCategory: categoryTitle)
    }

    // MARK: - Actions

    @objc private func addTrackerTapped() {
        let vc = TrackerTypeSelectionViewController()
        vc.onTrackerCreated = { [weak self] tracker, category in
            self?.addTracker(tracker, toCategory: category)
            self?.dismiss(animated: true)
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    @objc private func dateChanged() {
        currentDate = datePicker.date
        filterTrackers()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func storeDidUpdate() {
        filterTrackers()
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.identifier,
            for: indexPath
        ) as? TrackerCell else { return UICollectionViewCell() }

        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        cell.delegate = self
        cell.configure(
            with: tracker,
            isCompleted: isCompleted(tracker),
            completionCount: completionCount(for: tracker),
            isFutureDate: isFutureDate(currentDate)
        )
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerCategoryHeader.identifier,
                for: indexPath
              ) as? TrackerCategoryHeader else { return UICollectionReusableView() }
        header.configure(with: visibleCategories[indexPath.section].title)
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 9) / 2
        return CGSize(width: width, height: 148)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 9 }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { 16 }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 46)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: 0, bottom: 16, right: 0)
    }
}

// MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    func trackerCell(_ cell: TrackerCell, didToggleCompletionFor trackerId: UUID) {
        let record = TrackerRecord(trackerId: trackerId, date: currentDate)
        if recordStore.completedTrackers.contains(record) {
            try? recordStore.remove(record)
        } else {
            try? recordStore.add(record)
        }
        collectionView.reloadData()
    }
}

// MARK: - UISearchBarDelegate

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        filterTrackers()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
