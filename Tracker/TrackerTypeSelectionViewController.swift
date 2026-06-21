//
//  TrackerTypeSelectionViewController.swift
//  Tracker
//

import UIKit

final class TrackerTypeSelectionViewController: UIViewController {

    var onTrackerCreated: ((Tracker, String) -> Void)?

    // MARK: - UI

    private lazy var habitButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Привычка", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .label
        b.layer.cornerRadius = 16
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(habitTapped), for: .touchUpInside)
        return b
    }()

    private lazy var irregularButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Нерегулярное событие", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .label
        b.layer.cornerRadius = 16
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(irregularTapped), for: .touchUpInside)
        return b
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Создание трекера"
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [habitButton, irregularButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            irregularButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    // MARK: - Actions

    @objc private func habitTapped() {
        let vc = NewTrackerViewController(isHabit: true)
        vc.onTrackerCreated = onTrackerCreated
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func irregularTapped() {
        let vc = NewTrackerViewController(isHabit: false)
        vc.onTrackerCreated = onTrackerCreated
        navigationController?.pushViewController(vc, animated: true)
    }
}
