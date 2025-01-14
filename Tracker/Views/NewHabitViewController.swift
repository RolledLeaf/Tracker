import UIKit

final class NewHabitViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.layer.cornerRadius = 16
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.textColor = UIColor.custom(.createButtonColor)
        textField.backgroundColor = UIColor.custom(.backgroundGray)
        textField.textAlignment = .left
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private let categoryAndScheduleTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        tableView.rowHeight = 75
        return tableView
    }()
    
    private let emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.sectionInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 17
        layout.minimumInteritemSpacing = 23
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.identifier)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let colorsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.sectionInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 17
        layout.minimumInteritemSpacing = 23
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ColorsCollectionViewCell.self, forCellWithReuseIdentifier: ColorsCollectionViewCell.identifier)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let createTrackerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.custom(.textFieldGray)
        button.layer.cornerRadius = 16
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor.custom(.cancelButtonRed), for: .normal)
        button.backgroundColor = .clear
        button.layer.borderWidth = 1   // Толщина рамки
        button.layer.borderColor = UIColor.custom(.cancelButtonRed)?.cgColor
        button.layer.cornerRadius = 16
        return button
    }()
    
    
    
    
    private let tableViewOptions = ["Категория", "Расписание"]
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    private let trackerCollectionColors: [CollectionColors] = [.collectionRed1, .collectionOrange2, .collectionBlue3, .collectionPurple4, .collectionLightGreen5, .collectionViolet6, .collectionBeige7, .collectionLightBlue8, .collectionJadeGreen9, .collectionDarkPurple10, .collectionCarrotOrange11, .collectionPink12, .collectionLightBrick13, .collectionSemiblue14, .collectionLightPurple15, .collectionDarkViolet16, .collectionPalePurple17, .collectionGreen18]
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
    }
    
    
    private func setupViews() {
        
        
        let buttonsStackView = UIStackView(arrangedSubviews: [ cancelButton, createTrackerButton])
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 8
        buttonsStackView.distribution = .fillEqually
        
        let collectionsStackView = UIStackView(arrangedSubviews: [ emojiCollectionView, colorsCollectionView])
        collectionsStackView.axis = .vertical
        collectionsStackView.spacing = 34
        collectionsStackView.distribution = .fillEqually
        
        
        let UIelements = [titleLabel, trackerNameTextField, categoryAndScheduleTableView, collectionsStackView, buttonsStackView]
        UIelements.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        UIelements.forEach { contentView.addSubview($0) }
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        NSLayoutConstraint.activate([
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 900),
            
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            trackerNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            trackerNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            categoryAndScheduleTableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            categoryAndScheduleTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryAndScheduleTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            categoryAndScheduleTableView.heightAnchor.constraint(equalToConstant: 150),
            
            collectionsStackView.topAnchor.constraint(equalTo: categoryAndScheduleTableView.bottomAnchor, constant: 50),
            collectionsStackView.heightAnchor.constraint(equalToConstant: 445),
            collectionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 23),
            collectionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -23),
            
            buttonsStackView.topAnchor.constraint(equalTo: collectionsStackView.bottomAnchor, constant: 46),
            
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)])
        
        
        emojiCollectionView.delegate = self
        colorsCollectionView.delegate = self
        categoryAndScheduleTableView.delegate = self
        
        emojiCollectionView.dataSource = self
        colorsCollectionView.dataSource = self
        categoryAndScheduleTableView.dataSource = self
        
        emojiCollectionView.register(
            CollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CollectionHeaderView.identifier
        )
        
        
        colorsCollectionView.register(
            CollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CollectionHeaderView.identifier
        )
        
        categoryAndScheduleTableView.register(CategoryAndScheduleTableViewCell.self, forCellReuseIdentifier: CategoryAndScheduleTableViewCell.identifier) //регистрация по ячейке
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        print("Requested supplementary view for kind: \(kind), section: \(indexPath.section)")
        
        guard kind == UICollectionView.elementKindSectionHeader else {
            print("Invalid kind requested")
            return UICollectionReusableView()
        }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CollectionHeaderView.identifier,
            for: indexPath
        ) as? CollectionHeaderView else {
            print("Failed to dequeue CollectionHeaderView")
            return UICollectionReusableView()
        }
        
        print("Successfully dequeued CollectionHeaderView for section \(indexPath.section)")
        
        // Configure header
        if collectionView == emojiCollectionView {
            header.configure(with: "Emoji")
        } else if collectionView == colorsCollectionView {
            header.configure(with: "Цвет")
        }
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let size = CGSize(width: 52, height: 18) // Или другой размер
        print("Header size for section \(section): \(size)")
        return size
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojis.count
        } else if collectionView == colorsCollectionView {
            return trackerCollectionColors.count
        }
        return 0
    }
    
    //Настройка коллекций
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.identifier, for: indexPath) as? EmojiCollectionViewCell else {
                print("Collection wasn't able to dequeue cell")
                return UICollectionViewCell()
            }
            
            cell.configure(with: emojis[indexPath.item])
            return cell
        } else if collectionView == colorsCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorsCollectionViewCell.identifier, for: indexPath) as? ColorsCollectionViewCell else {
                return UICollectionViewCell()
            }
            guard let color = trackerCollectionColors[indexPath.item].uiColor else {
                cell.configure(with: .gray)  // дефолтный цвет
                return cell
            }
            
            // Настроим ячейку, передав цвет
            cell.configure(with: color)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == colorsCollectionView {
            let selectedColor = trackerCollectionColors[indexPath.item]
            print("Selected color: \(selectedColor)")
            // Обработайте выбор цвета
        } else if collectionView == emojiCollectionView {
            let selectedEmoji = emojis[indexPath.item]
            print("Selected emoji: \(selectedEmoji)")
            // Обработайте выбор эмдзи
        }
    }
    
    
    //Настройки таблицы
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryAndScheduleTableViewCell.identifier, for: indexPath) as? CategoryAndScheduleTableViewCell else {
            return UITableViewCell()
        }
        
        let titles = tableViewOptions
        cell.configure(with: titles[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let categoryListVC = CategoriesListViewController()
            let navigationController = UINavigationController(rootViewController: categoryListVC)
            navigationController.modalPresentationStyle = .automatic
            present(navigationController, animated: true)
        } else if indexPath.row == 1 {
            // Действие для "Расписание"
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius: CGFloat = 16

        // Сброс настроек для всех ячеек
        cell.layer.cornerRadius = 0
        cell.layer.maskedCorners = []
        cell.clipsToBounds = true
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) // Обычные отступы для разделителя

        // Скругление первой ячейки
        if indexPath.row == 0 {
            cell.layer.cornerRadius = cornerRadius
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) // Разделитель остается видимым
        }

        // Скругление последней ячейки
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.layer.cornerRadius = cornerRadius
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        }
    }
}
