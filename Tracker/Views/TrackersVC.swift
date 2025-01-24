
import Foundation
import UIKit

final class TrackersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NewHabitViewControllerDelegate {

    
    
    private let plusButton = UIButton()
    private let trackersLabel = UILabel()
    private let emptyFieldStarImage = UIImageView()
    private let emptyFieldLabel = UILabel()
    
    private var datePickerHeightConstraint: NSLayoutConstraint?
    var categories: [TrackerCategory] = []
    var trackers: [Tracker] = []
    var completedTrackers: [TrackerRecord]?
    var currentDate: Date = Date()
    
    
    
    private let categoriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 343, height: 400)  //Высота ячейки должна быть динамичской
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 40
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.backgroundColor = UIColor.custom(.backgroundGray)
        searchBar.searchBarStyle = .minimal
        searchBar.setImage(UIImage(systemName: "magnifyingglass"), for: .search, state: .normal)
        searchBar.layer.cornerRadius = 10
        
        return searchBar
    }()
    
    private lazy var dateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(currentDateFormatted(), for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = UIColor.custom(.dataGray)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(toggleCalendar), for: .touchUpInside)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        if #available(iOS 14.0, *) {
            picker.preferredDatePickerStyle = .inline
        } else {
            
            picker.datePickerMode = .date
        }
        picker.isHidden = true // Скрыт по умолчанию
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        picker.backgroundColor = UIColor.custom(.backgroundGray)
        return picker
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialUI()
    
        setupDefaultCategories()
        
        reloadCategoryData()
        updateUI()
    }
    
    private func setupDefaultCategories() {
            let defaultTracker1 = Tracker(id: 1, name: "Уборка", color: .collectionBlue3, emoji: "🙂", daysCount: 1, weekDays: ["Вт", "Ср", "Чт", "СБ"])
            let defaultTracker2 = Tracker(id: 2, name: "Стирка", color: .collectionPink12, emoji: "😻", daysCount: 3, weekDays: ["Пт"])
            let defaultTracker3 = Tracker(id: 3, name: "Зарядка", color: .collectionDarkPurple10, emoji: "❤️", daysCount: 4, weekDays: ["Сб"])
            let defaultTraker4 = Tracker(id: 4, name: "Подготовка к сноуборду", color: .collectionViolet6, emoji: "😈", daysCount: 5, weekDays: ["Вт", "Ср", "Чт", "Пт", "Сб"])
            let defaultTracker5 = Tracker(id: 5, name: "Подготовка лыжам", color: .collectionOrange2, emoji: "🥶", daysCount: 2, weekDays: ["Вт", "Пт", "Сб"])
            let defaultTracker6 = Tracker(id: 6, name: "Работа в саду", color: .collectionGreen18, emoji: "🌺", daysCount: 2, weekDays: ["Вт", "Ср", "Чт", "Пт", "Сб"])
            
            let defaultCategory = TrackerCategory(title: "Default", tracker: [defaultTracker1, defaultTracker2, defaultTracker3])
            let newCategory = TrackerCategory(title: "New Category", tracker: [defaultTraker4, defaultTracker5, defaultTracker6])
            
            categories.append(defaultCategory)
            categories.append(newCategory)
        }
    
    func reloadCategoryData() {
            // Ваш код для обновления UI, например, перезагрузка таблицы
        categoriesCollectionView.reloadData()
        
        }
    
    private func currentDateFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter.string(from: Date())
    }
    
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        let selectedDate = formatter.string(from: sender.date)
        dateButton.setTitle(selectedDate, for: .normal)
        // После выбора скрываем календарь
        UIView.animate(withDuration: 0.3, animations: {
            self.datePickerHeightConstraint?.constant = 0 // Убираем высоту
            self.view.layoutIfNeeded() // Перестраиваем интерфейс
        }, completion: { _ in
            self.datePicker.isHidden = true // Скрываем календарь
        })
    }
    
    
    @objc private func toggleCalendar() {
        let isHidden = datePicker.isHidden
        datePicker.isHidden = false // Отключаем скрытие, чтобы анимация была видна
        
        UIView.animate(withDuration: 0.3, animations: {
            self.datePickerHeightConstraint?.constant = isHidden ? 330 : 0 // Указываем высоту
            self.view.layoutIfNeeded() // Перестраиваем интерфейс
        }, completion: { _ in
            self.datePicker.isHidden = !isHidden // Скрываем после анимации, если нужно
        })
    }
    
    
    
    private func configureLabel(_ label: UILabel, text: String, fontSize: CGFloat, weight: UIFont.Weight, color: CustomColors) {
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textColor = UIColor(named: color.rawValue)
    }
    
    
    private func updateUI() {
        let hasTrackers = !(categories.isEmpty)
        emptyFieldLabel.isHidden = hasTrackers
        emptyFieldStarImage.isHidden = hasTrackers
        categoriesCollectionView.isHidden = !hasTrackers
    }
    
    private func setupInitialUI() {
        updateUI()
        
        view.backgroundColor = UIColor(named: CustomColors.backgroundGray.rawValue)
        
        let uiElements = [plusButton, dateButton, categoriesCollectionView, trackersLabel, searchBar, emptyFieldStarImage, emptyFieldLabel, datePicker]
        uiElements.forEach {$0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        configureLabel(trackersLabel, text: "Трекеры", fontSize: 34, weight: .bold, color: .textColor)
        configureLabel(emptyFieldLabel, text: "Что будем отслеживать?", fontSize: 12, weight: .regular, color: .textColor)
        plusButton.setImage(UIImage(named: "plusButton"), for: .normal)
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        emptyFieldStarImage.image = UIImage(named: "dizzyStar")
        
        
        datePickerHeightConstraint = datePicker.heightAnchor.constraint(equalToConstant: 0)
        if let datePickerHeightConstraint = datePickerHeightConstraint {
            NSLayoutConstraint.activate([
                
                datePicker.topAnchor.constraint(equalTo: dateButton.bottomAnchor, constant: 8),
                datePicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                datePickerHeightConstraint
            ])
        }
        
        NSLayoutConstraint.activate([
            
            categoriesCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoriesCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 64),
            categoriesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            categoriesCollectionView.heightAnchor.constraint(equalToConstant: 1200), //поменять на динамический
            
            plusButton.heightAnchor.constraint(equalToConstant: 19),
            plusButton.widthAnchor.constraint(equalToConstant: 18),
            plusButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 18),
            plusButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 13),
            
            dateButton.heightAnchor.constraint(equalToConstant: 34),
            dateButton.widthAnchor.constraint(equalToConstant: 77),
            dateButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            dateButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            
            trackersLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackersLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            
            searchBar.widthAnchor.constraint(equalToConstant: 343),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchBar.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 12),
            
            emptyFieldLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyFieldLabel.topAnchor.constraint(equalTo: emptyFieldStarImage.bottomAnchor, constant: 8),
            
            emptyFieldStarImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyFieldStarImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyFieldStarImage.widthAnchor.constraint(equalToConstant: 80),
            emptyFieldStarImage.heightAnchor.constraint(equalToConstant: 80)
            
        ])
        
        categoriesCollectionView.dataSource = self
        
        categoriesCollectionView.register(CategoriesCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoriesCollectionHeaderView.identifier)
        
        
        categoriesCollectionView.register(TrackerCategoryCell.self, forCellWithReuseIdentifier: TrackerCategoryCell.reuseIdentifier)
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("Number of sections: \(categories.count)")
       return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return categories.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          guard let cell = categoriesCollectionView.dequeueReusableCell(withReuseIdentifier: TrackerCategoryCell.reuseIdentifier, for: indexPath) as? TrackerCategoryCell else {
            print("Не удалось создать ячейку")
              return UICollectionViewCell()
        }
           let category = categories[indexPath.item]
                    cell.configure(with: category)
           
        return cell
       }
    

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        print("Requested supplementary view for kind: \(kind), section: \(indexPath.section)")
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: CategoriesCollectionHeaderView.identifier,
                for: indexPath
              ) as? CategoriesCollectionHeaderView else {
            return UICollectionReusableView()
        }
        
        let category = categories[indexPath.section]
        header.configure(with: category.title)
        
        return header
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 150, height: 18)
    }
    
    @objc private func plusButtonTapped() {
        let createHabitVC = CreateHabitTypeViewController()
        createHabitVC.delegate = self
        let navigationController = UINavigationController(rootViewController: createHabitVC)
        navigationController.modalPresentationStyle = .automatic
        present(navigationController, animated: true)
    }
    
    func didCreateTracker(_ tracker: Tracker) {
          
        trackers.append(tracker)
            
        categoriesCollectionView.reloadData()
        }
    
}
