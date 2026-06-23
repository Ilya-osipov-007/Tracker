//
//  ScheduleViewController.swift
//  Tracker
//

import UIKit

final class ScheduleViewController: UIViewController {

    var onScheduleSelected: ((Schedule) -> Void)?
    private var selectedDays: Schedule

    // MARK: - UI

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.layer.cornerRadius = 16
        tv.clipsToBounds = true
        tv.backgroundColor = .systemGray6
        tv.separatorColor = UIColor.systemGray2.withAlphaComponent(0.5)
        tv.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tv.isScrollEnabled = false
        tv.tableFooterView = UIView()
        tv.dataSource = self
        tv.delegate = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private lazy var doneButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Готово", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .label
        b.layer.cornerRadius = 16
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return b
    }()

    // MARK: - Init

    init(selectedDays: Schedule) {
        self.selectedDays = selectedDays
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Расписание"
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(doneButton)

        let tableHeight = CGFloat(75 * WeekDay.ordered.count)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: tableHeight),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    // MARK: - Actions

    @objc private func doneTapped() {
        onScheduleSelected?(selectedDays)
        navigationController?.popViewController(animated: true)
    }

    @objc private func switchToggled(_ sender: UISwitch) {
        let day = WeekDay.ordered[sender.tag]
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        WeekDay.ordered.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let day = WeekDay.ordered[indexPath.row]
        cell.textLabel?.text = day.displayName
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.selectionStyle = .none
        cell.backgroundColor = .systemGray6

        let toggle = UISwitch()
        toggle.isOn = selectedDays.contains(day)
        toggle.onTintColor = .systemBlue
        toggle.tag = indexPath.row
        toggle.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
        cell.accessoryView = toggle

        if indexPath.row == WeekDay.ordered.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }
}
