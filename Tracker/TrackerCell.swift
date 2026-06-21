//
//  TrackerCell.swift
//  Tracker
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func trackerCell(_ cell: TrackerCell, didToggleCompletionFor trackerId: UUID)
}

final class TrackerCell: UICollectionViewCell {
    static let identifier = "TrackerCell"

    weak var delegate: TrackerCellDelegate?
    private var trackerId: UUID?

    // MARK: - UI

    private let cardView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let emojiContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let emojiLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = .white
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let daysLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let completeButton: UIButton = {
        let b = UIButton(type: .system)
        b.layer.cornerRadius = 17
        b.tintColor = .white
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Configure

    func configure(with tracker: Tracker, isCompleted: Bool, completionCount: Int, isFutureDate: Bool) {
        trackerId = tracker.id
        nameLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        cardView.backgroundColor = tracker.color
        daysLabel.text = daysString(for: completionCount)

        let image = isCompleted ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus")
        completeButton.setImage(image, for: .normal)
        completeButton.backgroundColor = isCompleted
            ? tracker.color.withAlphaComponent(0.3)
            : tracker.color
        completeButton.isEnabled = !isFutureDate
        completeButton.alpha = isFutureDate ? 0.5 : 1.0
    }

    // MARK: - Private

    private func daysString(for count: Int) -> String {
        let mod10 = count % 10, mod100 = count % 100
        if mod10 == 1 && mod100 != 11 { return "\(count) день" }
        if (2...4).contains(mod10) && !(11...14).contains(mod100) { return "\(count) дня" }
        return "\(count) дней"
    }

    @objc private func completeTapped() {
        guard let id = trackerId else { return }
        delegate?.trackerCell(self, didToggleCompletionFor: id)
    }

    private func setupUI() {
        contentView.addSubview(cardView)
        cardView.addSubview(emojiContainerView)
        emojiContainerView.addSubview(emojiLabel)
        cardView.addSubview(nameLabel)
        contentView.addSubview(daysLabel)
        contentView.addSubview(completeButton)
        completeButton.addTarget(self, action: #selector(completeTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),

            emojiContainerView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiContainerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiContainerView.widthAnchor.constraint(equalToConstant: 24),
            emojiContainerView.heightAnchor.constraint(equalToConstant: 24),

            emojiLabel.centerXAnchor.constraint(equalTo: emojiContainerView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiContainerView.centerYAnchor),

            nameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            daysLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),

            completeButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34),
        ])
    }
}
