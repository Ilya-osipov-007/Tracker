//
//  NewTrackerViewController.swift
//  Tracker
//

import UIKit

final class NewTrackerViewController: UIViewController {

    var onTrackerCreated: ((Tracker, String) -> Void)?

    private let isHabit: Bool
    private var selectedCategory: String? = "Важное"
    private var selectedSchedule: Schedule = Schedule()
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var buttonsBottomConstraint: NSLayoutConstraint?

    private let availableEmojis = ["🍏", "😸", "🐶", "🌺", "❤️", "🎯", "🏃", "📚", "💪", "🎨", "🎵", "⭐️"]
    private let availableColors: [UIColor] = [
        .systemRed, .systemOrange, .systemYellow, .systemGreen,
        .systemBlue, .systemPurple, .systemPink, .systemTeal,
        .systemIndigo, .systemBrown, .systemCyan, .systemMint,
    ]

    // MARK: - UI

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private lazy var contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

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

    private let emojiSectionLabel: UILabel = {
        let l = UILabel()
        l.text = "Emoji"
        l.font = .boldSystemFont(ofSize: 19)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private let colorSectionLabel: UILabel = {
        let l = UILabel()
        l.text = "Цвет"
        l.font = .boldSystemFont(ofSize: 19)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
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
        navigationItem.hidesBackButton = true
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

        view.addSubview(scrollView)
        view.addSubview(buttonsStack)
        scrollView.addSubview(contentView)

        contentView.addSubview(nameTextField)
        contentView.addSubview(characterLimitLabel)
        contentView.addSubview(settingsTableView)
        contentView.addSubview(emojiSectionLabel)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorSectionLabel)
        contentView.addSubview(colorCollectionView)

        let rowCount = isHabit ? 2 : 1
        let tableHeight = CGFloat(rowCount) * 75
        // 2 rows × ~52pt cell + 1 gap + section insets — works across standard iPhone widths
        let collectionHeight: CGFloat = 160

        let buttonsBottom = buttonsStack.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16
        )
        buttonsBottom.isActive = true
        buttonsBottomConstraint = buttonsBottom

        NSLayoutConstraint.activate([
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -8),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),

            characterLimitLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            characterLimitLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            settingsTableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 40),
            settingsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            settingsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            settingsTableView.heightAnchor.constraint(equalToConstant: tableHeight),

            emojiSectionLabel.topAnchor.constraint(equalTo: settingsTableView.bottomAnchor, constant: 32),
            emojiSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),

            emojiCollectionView.topAnchor.constraint(equalTo: emojiSectionLabel.bottomAnchor, constant: 16),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: collectionHeight),

            colorSectionLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),

            colorCollectionView.topAnchor.constraint(equalTo: colorSectionLabel.bottomAnchor, constant: 16),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: collectionHeight),
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
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
        characterLimitLabel.isHidden = count < 38
        updateCreateButton()
    }

    @objc private func cancelTapped() {
        navigationController?.dismiss(animated: true)
    }

    @objc private func createTapped() {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespaces),
              !name.isEmpty,
              let category = selectedCategory,
              let emoji = selectedEmoji,
              let color = selectedColor else { return }
        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: color,
            emoji: emoji,
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
        let hasEmoji = selectedEmoji != nil
        let hasColor = selectedColor != nil
        let isEnabled = hasValidName && hasCategory && hasSchedule && hasEmoji && hasColor
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

        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.textColor = UIColor(named: "Black day")
        cell.detailTextLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.textColor = UIColor(named: "Grey")

        let totalRows = isHabit ? 2 : 1
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = selectedCategory
        default:
            cell.textLabel?.text = "Расписание"
            let subtitle = scheduleSubtitle()
            cell.detailTextLabel?.text = subtitle.isEmpty ? nil : subtitle
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
            // TODO: навигация к выбору категории будет добавлена в следующем спринте
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

// MARK: - UICollectionViewDataSource

extension NewTrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView === emojiCollectionView ? availableEmojis.count : availableColors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCell.identifier, for: indexPath
            ) as? EmojiCell else { return UICollectionViewCell() }
            let emoji = availableEmojis[indexPath.item]
            cell.configure(with: emoji, isSelected: emoji == selectedEmoji)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCell.identifier, for: indexPath
            ) as? ColorCell else { return UICollectionViewCell() }
            let color = availableColors[indexPath.item]
            cell.configure(with: color, isSelected: color == selectedColor)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension NewTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 6
        let spacing: CGFloat = 5 * (columns - 1)
        let side = floor((collectionView.bounds.width - spacing) / columns)
        return CGSize(width: side, height: side)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === emojiCollectionView {
            selectedEmoji = availableEmojis[indexPath.item]
            emojiCollectionView.reloadData()
        } else {
            selectedColor = availableColors[indexPath.item]
            colorCollectionView.reloadData()
        }
        updateCreateButton()
    }
}

// MARK: - UITextFieldDelegate

extension NewTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let current = textField.text ?? ""
        let updated = (current as NSString).replacingCharacters(in: range, with: string)
        return updated.count <= 38
    }
}

// MARK: - EmojiCell

private final class EmojiCell: UICollectionViewCell {
    static let identifier = "EmojiCell"

    private let emojiLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 32)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 16
        clipsToBounds = true
        contentView.addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with emoji: String, isSelected: Bool) {
        emojiLabel.text = emoji
        backgroundColor = isSelected ? .systemGray5 : .clear
    }
}

// MARK: - ColorCell

private final class ColorCell: UICollectionViewCell {
    static let identifier = "ColorCell"

    private let colorView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 8
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 8
        contentView.addSubview(colorView)
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -6),
            colorView.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -6),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        layer.borderWidth = isSelected ? 3 : 0
        layer.borderColor = color.withAlphaComponent(0.3).cgColor
    }
}
