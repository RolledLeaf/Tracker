

import UIKit

final class TrackersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NewHabitViewControllerDelegate {
    
    
    
    private let plusButton = UIButton()
    private let trackersLabel = UILabel()
    private let emptyFieldStarImage = UIImageView()
    private let emptyFieldLabel = UILabel()
    
    
    private var datePickerHeightConstraint: NSLayoutConstraint?
    
    var categories: [TrackerCategory] = []
    var filteredCategories: [TrackerCategory] = []
    var trackerRecords: [TrackerRecord] = []
    var currentDate: Date = Date()
    var currentSelectedTracker: Tracker?
    
    
    
    private let categoriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 9
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
       
        updateVisibleTrackers(for: datePicker.date)
    }
    
    private func setupDefaultCategories() {
        let defaultTracker1 = Tracker(id: 1, name: "Уборка", color: .collectionBlue3, emoji: "🙂", daysCount: 1, weekDays: [ "Mon", "Wed"])
        let defaultTracker2 = Tracker(id: 2, name: "Стирка", color: .collectionPink12, emoji: "😻", daysCount: 3, weekDays: ["Fri"])
        let defaultTracker3 = Tracker(id: 3, name: "Зарядка", color: .collectionDarkPurple10, emoji: "❤️", daysCount: 4, weekDays: ["Sat"])
        let defaultTraker4 = Tracker(id: 4, name: "Подготовка к сноуборду", color: .collectionViolet6, emoji: "😈", daysCount: 5, weekDays: ["Tue", "Wed", "Thu", "Fri", "Sat"])
        let defaultTracker5 = Tracker(id: 5, name: "Подготовка лыжам", color: .collectionOrange2, emoji: "🥶", daysCount: 2, weekDays: ["Tue", "Fri", "Sat"])
        let defaultTracker6 = Tracker(id: 6, name: "Работа в саду", color: .collectionGreen18, emoji: "🌺", daysCount: 2, weekDays: ["Tue", "Wed", "Thu", "Fri", "Sun"])
        
        let defaultCategory = TrackerCategory(title: "Стандартная", tracker: [defaultTracker1, defaultTracker2, defaultTracker3])
        let newCategory = TrackerCategory(title: "Новая категория", tracker: [defaultTraker4, defaultTracker5, defaultTracker6])
        
        categories.append(defaultCategory)
        categories.append(newCategory)
    }
    
    func reloadCategoryData() {
        categoriesCollectionView.reloadData()
        
    }
    
    //функциональность метода под вопросом
    func didCreateTracker(_ tracker: Tracker, _ category: TrackerCategory) {
        
        categories.append(category)
        
        print("Вызван метод didCreateTracker и добавлена категория \(category)")
        reloadCategoryData()
    }
    
    private func currentDateFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter.string(from: Date())
    }
    
    private func updateVisibleTrackers(for selectedDate: Date) {
        let calendar = Calendar.current
        let weekdaySymbols = calendar.shortWeekdaySymbols
        let selectedWeekdayIndex = calendar.component(.weekday, from: selectedDate) - 1
        let selectedWeekday = weekdaySymbols[selectedWeekdayIndex]

        filteredCategories = categories.map { category in
            let filteredTrackers = category.tracker.filter { $0.weekDays.contains(selectedWeekday) }
            return TrackerCategory(title: category.title, tracker: filteredTrackers)
        }.filter { !$0.tracker.isEmpty } // Убираем пустые категории

        categoriesCollectionView.reloadData()
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        updateVisibleTrackers(for: sender.date)
    }
    
    private func getDayWord(for count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        
        if remainder10 == 1 && remainder100 != 11 {
            return "день"
        } else if remainder10 >= 2 && remainder10 <= 4 && (remainder100 < 10 || remainder100 >= 20) {
            return "дня"
        } else {
            return "дней"
        }
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
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
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
            categoriesCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 34),
            categoriesCollectionView.heightAnchor.constraint(equalToConstant: 1200),
            
            
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
            
            searchBar.trailingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
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
        
        categoriesCollectionView.delegate = self
        searchBar.delegate = self
    }
    
    
    
    @objc private func plusButtonTapped() {
        let createHabitVC = CreateHabitTypeViewController()
        createHabitVC.delegate = self
        let navigationController = UINavigationController(rootViewController: createHabitVC)
        navigationController.modalPresentationStyle = .automatic
        present(navigationController, animated: true)
    }
    
  
    
}

extension TrackersViewController: TrackerCellDelegate {
    func getTrackerByID(_ trackerID: Int) -> Tracker? {
        for category in categories {
            if let tracker = category.tracker.first(where: { $0.id == trackerID }) {
                return tracker
            }
        }
        return nil
    }
    
    func trackerCell(_ cell: TrackerCategoryCell, didTapDoneButtonFor trackerID: Int) {
        let currentDate = Date()
        let calendar = Calendar.current

        if let existingIndex = trackerRecords.firstIndex(where: { $0.trackerID == trackerID && calendar.isDate($0.date, inSameDayAs: currentDate) }) {
            // Удаляем запись
            trackerRecords.remove(at: existingIndex)
            updateTrackerDaysCount(for: trackerID, isChecked: false)
            print("Удалена запись для трекера \(trackerID)")
            
        } else {
            // Добавляем новую запись
            let newRecord = TrackerRecord(trackerID: trackerID, date: currentDate)
            trackerRecords.append(newRecord)
            print("Добавлена запись: \(newRecord)")
            updateTrackerDaysCount(for: trackerID, isChecked: true)
        }

        // Определяем актуальное состояние (true — трекер активен, false — удалён)
        let isChecked = trackerRecords.contains(where: { $0.trackerID == trackerID && calendar.isDate($0.date, inSameDayAs: currentDate) })

        // Обновляем UI ячейки через модель данных
        if let indexPath = categoriesCollectionView.indexPath(for: cell),
           let tracker = getTrackerByID(trackerID) {

            categoriesCollectionView.performBatchUpdates({
                cell.doneButton.setImage(UIImage(systemName: isChecked ? "checkmark" : "plus"), for: .normal)
                if let baseColor = UIColor.fromCollectionColor(tracker.color) {
                    cell.doneButtonContainer.backgroundColor = isChecked ? lightenColor(baseColor, by: 0.3) : baseColor
                } else {
                    cell.doneButtonContainer.backgroundColor = .gray
                }
                let daysCount = tracker.daysCount
                cell.daysCountLabel.text = getDayWord(for: daysCount)
                cell.daysNumberLabel.text = "\(tracker.daysCount)" // Обновляем значение дней
               }, completion: nil)
        }
    }
    
    private func updateTrackerDaysCount(for trackerID: Int, isChecked: Bool) {
        if let categoryIndex = categories.firstIndex(where: { category in
            category.tracker.contains(where: { $0.id == trackerID })
        }) {
            let category = categories[categoryIndex]
            
            if let trackerIndex = category.tracker.firstIndex(where: { $0.id == trackerID }) {
                let tracker = category.tracker[trackerIndex]
                
                // Обновляем количество дней
                let updatedDaysCount = tracker.daysCount + (isChecked ? 1 : -1)
                
                // Создаём новый обновлённый трекер
                let updatedTracker = Tracker(
                    id: tracker.id,
                    name: tracker.name,
                    color: tracker.color,
                    emoji: tracker.emoji,
                    daysCount: max(0, updatedDaysCount),
                    weekDays: tracker.weekDays
                )
                
                // Создаём новый массив трекеров с обновлённым трекером
                var updatedTrackers = category.tracker
                updatedTrackers[trackerIndex] = updatedTracker
                
                // Создаём новую категорию с обновлённым массивом трекеров
                let updatedCategory = TrackerCategory(title: category.title, tracker: updatedTrackers)
                
                // Создаём новый массив категорий с обновлённой категорией
                var updatedCategories = categories
                updatedCategories[categoryIndex] = updatedCategory
                
                // Обновляем основной массив категорий
                categories = updatedCategories
            }
        }
    }
}


extension TrackersViewController {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let category = filteredCategories[section]
        return  category.tracker.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        // Определяем выбранный трекер из секции
        let selectedTracker = categories[section].tracker[row]
        
        // Сохраняем его в переменную
        currentSelectedTracker = selectedTracker
        
        print("Выбран трекер: \(selectedTracker.name)")
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            // Для первой секции
            return UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        } else {
            // Для всех остальных секций
            return UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = categoriesCollectionView.dequeueReusableCell(withReuseIdentifier: TrackerCategoryCell.reuseIdentifier, for: indexPath) as? TrackerCategoryCell else {
            return UICollectionViewCell()
        }
        
        let category = filteredCategories[indexPath.section]  // Получаем категорию для текущей секции
        let tracker = category.tracker[indexPath.item]  // Получаем трекер из этой категории
        
        // Получаем записи для данного трекера
        let trackerRecordsForTracker = trackerRecords.filter { $0.trackerID == tracker.id }
        cell.delegate = self
        // Настроим ячейку
        cell.configure(with: tracker, trackerRecords: trackerRecordsForTracker)
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Ширина коллекции
        let collectionWidth = categoriesCollectionView.bounds.width
        
        // Отступы (если они заданы в layout)
        let sectionInset = (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? .zero
        let minimumSpacing = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0
        
        // Доступное пространство для ячеек (убираем отступы секции)
        let availableWidth = collectionWidth - sectionInset.left - sectionInset.right
        
        // Ширина одной ячейки
        let cellWidth = (availableWidth - minimumSpacing) / 2
        
        // Высота ячейки (можете указать любую, в зависимости от контекста)
        let cellHeight: CGFloat = 148 // Например, фиксированная высота
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterTrackers(for: searchText)
    }
    
   
    
    private func filterTrackers(for searchText: String) {
        if searchText.isEmpty {
            filteredCategories = categories // Если строка пустая, показываем все
        } else {
            filteredCategories = categories.compactMap { category in
                let filteredTrackers = category.tracker.filter { tracker in
                    tracker.name.lowercased().contains(searchText.lowercased())
                }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, tracker: filteredTrackers)
            }
        }
        
        categoriesCollectionView.reloadData()
    }
}
