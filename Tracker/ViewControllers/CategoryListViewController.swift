//
//  CategoryListViewController.swift
//  Tracker
//

import UIKit

final class CategoryListViewController: UIViewController {

    var selectedCategory: String?
    var onCategorySelected: ((String) -> Void)?

    private var categories: [String] { CategoriesManager.shared.categories }

    // MARK: - UI

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.layer.cornerRadius = 16
        tv.clipsToBounds = true
        tv.backgroundColor = .systemGray6
        tv.separatorColor = UIColor.systemGray2.withAlphaComponent(0.5)
        tv.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tv.tableFooterView = UIView()
        tv.dataSource = self
        tv.delegate = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private lazy var addButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Добавить категорию", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .label
        b.layer.cornerRadius = 16
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
        return b
    }()

    private let placeholderImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "Icon_star"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let placeholderLabel: UILabel = {
        let l = UILabel()
        l.text = "Привычки можно объединить по смыслу"
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textAlignment = .center
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Категория"
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        updatePlaceholder()
    }

    // MARK: - Setup

    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(addButton)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -24),

            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60),

            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),

            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    private func updatePlaceholder() {
        let isEmpty = categories.isEmpty
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    // MARK: - Actions

    @objc private func addCategoryTapped() {
        let vc = NewCategoryViewController()
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension CategoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.textColor = UIColor(named: "Black day")
        cell.backgroundColor = .systemGray6
        cell.selectionStyle = .none
        cell.tintColor = .systemBlue

        cell.accessoryType = category == selectedCategory ? .checkmark : .none

        if indexPath.row == categories.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension CategoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        onCategorySelected?(category)
        navigationController?.popViewController(animated: true)
    }
}
