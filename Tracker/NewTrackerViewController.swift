//
//  NewTrackerViewController.swift
//  Tracker
//

import UIKit

final class NewTrackerViewController: UIViewController {

    var onTrackerCreated: ((Tracker, String) -> Void)?

    private let isHabit: Bool
    private var selectedCategory: String?
    private var selectedSchedule: Set<WeekDay> = []
    private var buttonsBottomConstraint: NSLayoutConstraint?

    private let availableEmojis = ["🍏", "😸", "🐶", "🌺", "❤️", "🎯", "🏃", "📚", "💪", "🎨", "🎵", "⭐️"]
    private let availableColors: [UIColor] = [
        .systemRed, .systemOrange, .systemYellow, .systemGreen,
        .systemBlue, .systemPurple, .systemPink, .systemTeal,
        .systemIndigo, .systemBrown, .systemCyan, .systemMint,
    ]

    // MARK: - UI

    private lazy var nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Введите название трекера"
        tf.backgroundColor = .systemGray6
        tf.layer.cornerRadius = 16
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.clearButtonMode = .whileEditing
        tf.returnKeyType = .done
        tf.delegate = self
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        return tf
    }()

    private let characterLimitLabel: UILabel = {
        let l = UILabel()
        l.text = "Ограничение 38 символов"
        l.font = .systemFont(ofSize: 17)
        l.textColor = .systemRed
        l.textAlignment = .center
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var settingsTableView: UITableView = {
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

    private lazy var cancelButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Отменить", for: .normal)
        b.setTitleColor(.systemRed, for: .normal)
        b.layer.cornerRadius = 16
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.systemRed.cgColor
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return b
    }()

    private lazy var createButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Создать", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .systemGray
        b.layer.cornerRadius = 16
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        b.isEnabled = false
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        return b
    }()

    // MARK: - Init

    init(isHabit: Bool) {
        self.isHabit = isHabit
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = isHabit ? "Новая привычка" : "Новое нерегулярное событие"
        setupUI()
        setupKeyboardObservers()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    private func setupUI() {
        let buttonsStack = UIStackView(arrangedSubviews: [cancelButton, createButton])
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = 8
        buttonsStack.distribution = .fillEqually
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nameTextField)
        view.addSubview(characterLimitLabel)
        view.addSubview(settingsTableView)
        view.addSubview(buttonsStack)

        let rowCount = isHabit ? 2 : 1
        let tableHeight = CGFloat(rowCount) * 75

        let buttonsBottom = buttonsStack.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16
        )
        buttonsBottom.isActive = true
        buttonsBottomConstraint = buttonsBottom

        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),

            characterLimitLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            characterLimitLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            settingsTableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 40),
            settingsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            settingsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            settingsTableView.heightAnchor.constraint(equalToConstant: tableHeight),

            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    // MARK: - Actions

    @objc private func nameChanged() {
        let count = nameTextField.text?.count ?? 0
        characterLimitLabel.isHidden = count <= 38
        updateCreateButton()
    }

    @objc private func cancelTapped() {
        navigationController?.dismiss(animated: true)
    }

    @objc private func createTapped() {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespaces),
              !name.isEmpty,
              let category = selectedCategory else { return }
        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: availableColors.randomElement() ?? .systemBlue,
            emoji: availableEmojis.randomElement() ?? "🎯",
            schedule: isHabit ? selectedSchedule : nil
        )
        onTrackerCreated?(tracker, category)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let info = notification.userInfo,
              let kbFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        let kbHeight = kbFrame.height - view.safeAreaInsets.bottom
        UIView.animate(withDuration: duration) {
            self.buttonsBottomConstraint?.constant = -16 - kbHeight
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let info = notification.userInfo,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        UIView.animate(withDuration: duration) {
            self.buttonsBottomConstraint?.constant = -16
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Helpers

    private func updateCreateButton() {
        let text = nameTextField.text ?? ""
        let hasValidName = !text.trimmingCharacters(in: .whitespaces).isEmpty && text.count <= 38
        let hasCategory = selectedCategory != nil
        let hasSchedule = !isHabit || !selectedSchedule.isEmpty
        let isEnabled = hasValidName && hasCategory && hasSchedule
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .label : .systemGray
    }

    private func scheduleSubtitle() -> String {
        guard !selectedSchedule.isEmpty else { return "" }
        if selectedSchedule.count == 7 { return "Каждый день" }
        return WeekDay.ordered
            .filter { selectedSchedule.contains($0) }
            .map { $0.shortName }
            .joined(separator: ", ")
    }
}

// MARK: - UITableViewDataSource

extension NewTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isHabit ? 2 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .systemGray6
        cell.selectionStyle = .none

        let totalRows = isHabit ? 2 : 1
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = selectedCategory
            cell.detailTextLabel?.textColor = .systemGray
        default:
            cell.textLabel?.text = "Расписание"
            let subtitle = scheduleSubtitle()
            cell.detailTextLabel?.text = subtitle.isEmpty ? nil : subtitle
            cell.detailTextLabel?.textColor = .systemGray
        }

        if indexPath.row == totalRows - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension NewTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let vc = CategoryListViewController()
            vc.selectedCategory = selectedCategory
            vc.onCategorySelected = { [weak self] category in
                self?.selectedCategory = category
                tableView.reloadRows(at: [indexPath], with: .none)
                self?.updateCreateButton()
            }
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = ScheduleViewController(selectedDays: selectedSchedule)
            vc.onScheduleSelected = { [weak self] days in
                self?.selectedSchedule = days
                tableView.reloadRows(at: [indexPath], with: .none)
                self?.updateCreateButton()
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - UITextFieldDelegate

extension NewTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
