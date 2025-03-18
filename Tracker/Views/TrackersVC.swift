import UIKit
import CoreData

final class TrackersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    private var categories: [TrackerCategoryCoreData] = []
    private  var filteredCategories: [TrackerCategoryCoreData] = []
    private var trackerRecords: [TrackerRecordCoreData] = []
    private var currentSelectedTracker: TrackerCoreData?
    private var currentDate: Date = Date()
    private var selectedIndexPath: IndexPath?
    
    
    private let plusButton = UIButton()
    private let trackersLabel = UILabel()
    private let emptyFieldStarImage = UIImageView()
    private let emptyFieldLabel = UILabel()
    private let locale = Locale(identifier: "ru_RU")
    private let context = CoreDataStack.shared.persistentContainer.viewContext
    
    private var datePickerHeightConstraint: NSLayoutConstraint?
    private var categoriesCollectionViewHeight: NSLayoutConstraint?
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YY"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    var selectedDate: Date = Date()
    
    private lazy var trackerStore: TrackerStore = {
        let store = TrackerStore()
        store.delegate = self
        return store
    }()
    
    private lazy var trackerCategoryStore:  TrackerCategoryStore = {
        let store = TrackerCategoryStore()
        return store
    }()
    
    private lazy var categoriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 9
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.setImage(UIImage(systemName: "magnifyingglass"), for: .search, state: .normal)
        searchBar.layer.cornerRadius = 10
        searchBar.searchBarStyle = .minimal
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor.custom(.backgroundGray)
            textField.layer.cornerRadius = 10
            textField.clipsToBounds = true
        }
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = if #available(iOS 15.0, *) {
            UIBarButtonItem(image: UIImage(systemName: "keyboard.chevron.compact.down"), style: .done, target: searchBar, action: #selector(UIResponder.resignFirstResponder)) }
        else {
            UIBarButtonItem(image: UIImage(systemName: "keyboard"), style: .done, target: searchBar, action: #selector(UIResponder.resignFirstResponder))
        }
        toolbar.items = [flexSpace, doneButton]
        searchBar.inputAccessoryView = toolbar
        return searchBar
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        picker.backgroundColor = UIColor.custom(.backgroundGray)
        picker.locale = Locale(identifier: "ru_RU")
        picker.isHidden = false
        picker.alpha = 0.015
        return picker
    }()
    
    private lazy var dateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor.custom(.textColor), for: .normal)
        button.setTitle(currentDateFormatted(), for: .normal)
        button.backgroundColor = UIColor.custom(.backgroundGray)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialUI()
        loadCategories()
        loadTrackerRecords()
        reloadCategoryData()
        updateUI()
        updateVisibleTrackers(for: datePicker.date)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let navView = navigationController?.view {
            navView.addSubview(plusButton)
            navView.addSubview(dateButton)
            navView.addSubview(datePicker)
            
            plusButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                dateButton.heightAnchor.constraint(equalToConstant: 34),
                dateButton.widthAnchor.constraint(equalToConstant: 77),
                dateButton.trailingAnchor.constraint(equalTo: navView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                dateButton.topAnchor.constraint(equalTo: navView.safeAreaLayoutGuide.topAnchor, constant: 5),
                
                datePicker.centerXAnchor.constraint(equalTo: dateButton.centerXAnchor),
                datePicker.centerYAnchor.constraint(equalTo: dateButton.centerYAnchor),
                
                plusButton.heightAnchor.constraint(equalToConstant: 19),
                plusButton.widthAnchor.constraint(equalToConstant: 18),
                plusButton.leadingAnchor.constraint(equalTo: navView.safeAreaLayoutGuide.leadingAnchor, constant: 18),
                plusButton.topAnchor.constraint(equalTo: navView.safeAreaLayoutGuide.topAnchor, constant: 5),
            ])
        }
    }
    
    private func loadCategories() {
        categories = trackerCategoryStore.fetchAllTrackerCategories()
        filteredCategories = categories
    }
    
    private func reloadCategoryData() {
        categoriesCollectionView.reloadData()
    }
    
    private func fetchAllCategories() {
        let fetchedCategories = trackerCategoryStore.fetchAllTrackerCategories()
        print("Запрошены категории. Получены следующие категории: \(fetchedCategories)")
        filteredCategories = fetchedCategories
    }
    
    private func loadCategoriesAndTrackers() {
        categories = trackerCategoryStore.fetchAllTrackerCategories()
        print("Fetched categories: \(categories.count)")
    }
    
    private func loadTrackerRecords() {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        do {
            trackerRecords = try context.fetch(fetchRequest)
            print("📌 Загружено \(trackerRecords.count) выполненных трекеров из Core Data")
        } catch {
            print("❌ Ошибка загрузки выполненных трекеров: \(error)")
            trackerRecords = []
        }
    }
    
    private func updateVisibleTrackers(for selectedDate: Date) {
        print("📌 Вызван метод updateVisibleTrackers для даты \(selectedDate)")
        
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "EEE"
        let selectedWeekday = formatter.string(from: selectedDate)
        let allTrackers = trackerStore.fetchAllTrackers()
        let filteredTrackers = allTrackers.filter { tracker in
            guard let weekDays = tracker.weekDays as? [String] else { return false }
            
            let isCompleted = trackerRecords.contains { $0.trackerID == tracker.id && $0.date?.isSameDay(as: selectedDate) == true }
            let hasEverBeenCompleted = trackerRecords.contains { $0.trackerID == tracker.id }
            
            print("🔹 Трекер \(tracker.name ?? "Без имени") нерегулярный? \(weekDays.contains(" ") ? "Да" : "Нет"). Выполнен в этот день? \(isCompleted ? "✅ Да" : "❌ Нет"). Когда-либо выполнялся? \(hasEverBeenCompleted ? "📅 Да" : "📅 Нет")")
            
            if weekDays.contains(" ") {
                return !hasEverBeenCompleted || isCompleted
            } else {
                return weekDays.contains(selectedWeekday)
            }
        }
        
        filteredCategories = trackerCategoryStore.fetchAllTrackerCategories().compactMap { category in
            let trackersInCategory = filteredTrackers.filter { $0.category == category }
            return trackersInCategory.isEmpty ? nil : category
        }
        print("📌 Отфильтрованных категорий: \(filteredCategories.count)")
        reloadCategoryData()
    }
    
    private func removeTime(from date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: date)
    }
    
    private func getSelectedWeekday() -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "E"
        return formatter.string(from: datePicker.date)
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
    
    private func getFormattedDate() -> String {
        return dateFormatter.string(from: selectedDate)
    }
    
    private func currentDateFormatted() -> String {
        let formatter = dateFormatter
        
        return formatter.string(from: currentDate)
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        print("dateChange method is called")
        print("Выбрана дата: \(sender.date)")
        let formatter = dateFormatter
        selectedDate = sender.date
        
        let formattedDate = formatter.string(from: sender.date)
        dateButton.setTitle(formattedDate, for: .normal)
        updateUI()
        reloadCategoryData()
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        updateVisibleTrackers(for: sender.date)
    }
    
    @objc private func plusButtonTapped() {
        view.endEditing(true)
        let createHabitVC = CreateHabitTypeViewController()
        createHabitVC.delegate = self
        let navigationController = UINavigationController(rootViewController: createHabitVC)
        navigationController.modalPresentationStyle = .automatic
        present(navigationController, animated: true)
    }
    
    private func configureLabel(_ label: UILabel, text: String, fontSize: CGFloat, weight: UIFont.Weight, color: CustomColor) {
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textColor = UIColor(named: color.rawValue)
    }
    
    private func updateUI() {
        let categoryFetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        do {
            let categoriesFromDataBase = try CoreDataStack.shared.context.fetch(categoryFetchRequest)
            let hasTrackers = !categoriesFromDataBase.isEmpty
            
            emptyFieldLabel.isHidden = hasTrackers
            emptyFieldStarImage.isHidden = hasTrackers
            categoriesCollectionView.isHidden = !hasTrackers
            
            categories = categoriesFromDataBase
        } catch {
            print("Ошибка извлечения категорий из БД: \(error.localizedDescription)")
        }
    }
    
    private func setupInitialUI() {
        datePicker.maximumDate = Date()
        updateUI()
        view.backgroundColor = UIColor(named: CustomColor.mainBackgroundColor.rawValue)
        let uiElements = [plusButton, categoriesCollectionView, trackersLabel, searchBar, emptyFieldStarImage, emptyFieldLabel, datePicker, dateButton]
        uiElements.forEach {$0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        configureLabel(trackersLabel, text: "Трекеры", fontSize: 34, weight: .bold, color: .textColor)
        configureLabel(emptyFieldLabel, text: "Что будем отслеживать?", fontSize: 12, weight: .regular, color: .textColor)
        trackersLabel.textAlignment = .left
        plusButton.setImage(UIImage(named: "plusButton"), for: .normal)
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        emptyFieldStarImage.image = UIImage(named: "dizzyStar")
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            
            categoriesCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoriesCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 34),
            categoriesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            
            
            trackersLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackersLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            
            searchBar.trailingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            searchBar.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 12),
            
            emptyFieldLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyFieldLabel.topAnchor.constraint(equalTo: emptyFieldStarImage.bottomAnchor, constant: 8),
            
            emptyFieldStarImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 402),
            emptyFieldStarImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyFieldStarImage.widthAnchor.constraint(equalToConstant: 80),
            emptyFieldStarImage.heightAnchor.constraint(equalToConstant: 80)
            
        ])
        
        categoriesCollectionView.dataSource = self
        categoriesCollectionView.register(CategoriesCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoriesCollectionHeaderView.identifier)
        
        categoriesCollectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        
        categoriesCollectionView.delegate = self
        searchBar.delegate = self
    }
    
    func getSelectedDate() -> Date {
        return selectedDate
    }
}

extension TrackersViewController: TrackerCategoryCellDelegate {
    func trackerExecution(_ cell: TrackerCell, didTapDoneButtonFor trackerID: UUID, selectedDate: Date) {
        let context = CoreDataStack.shared.context
        guard let tracker = getTrackerByID(trackerID) else {
            print("❌ Ошибка: не найден трекер \(trackerID)")
            return
        }
        
        if let existingRecordIndex = trackerRecords.firstIndex(where: { $0.trackerID == trackerID && $0.date?.isSameDay(as: selectedDate) == true }) {
            let existingRecord = trackerRecords[existingRecordIndex]
            context.delete(existingRecord)
            trackerRecords.remove(at: existingRecordIndex)
            tracker.daysCount -= 1
            print("🗑 Удалена запись выполнения для трекера \(trackerID) на \(selectedDate)")
        } else {
            let newRecord = TrackerRecordCoreData(context: context)
            newRecord.trackerID = trackerID
            newRecord.date = selectedDate
            trackerRecords.append(newRecord)
            tracker.daysCount += 1
            print("✅ Добавлена запись выполнения для трекера \(trackerID) на \(selectedDate)")
        }
        
        do {
            try context.save()
            updateVisibleTrackers(for: selectedDate)
        } catch {
            print("❌ Ошибка при обновлении записи выполнения: \(error)")
        }
    }
    
    func getTrackerByID(_ trackerID: UUID) -> TrackerCoreData? {
        for category in filteredCategories {
            if let tracker = category.tracker?.first(where: { ($0 as AnyObject).id == trackerID }) {
                return tracker as? TrackerCoreData
            }
        }
        return nil
    }
}

extension TrackersViewController {
    private func getTrackers(for indexPath: IndexPath) -> [TrackerCoreData] {
        guard let category = trackerCategoryStore.getCategory(at: indexPath) else {
            print("❌ Категория не найдена для секции \(indexPath.section)")
            return []
        }
        
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@", category)
        
        do {
            let trackers = try context.fetch(fetchRequest)
            print("📌 Загружены трекеры для категории '\(category.title ?? "Без названия")': \(trackers.map { $0.name })")
            return trackers
        } catch {
            print("❌ Ошибка загрузки трекеров: \(error)")
            return []
        }
    }
    
    
    func didChangeContent() {
        reloadCategoryData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].tracker?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = categoriesCollectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCell else {
            fatalError("Cannot dequeue TrackerCell")
        }
        
        let category = filteredCategories[indexPath.section]
        guard let tracker = category.tracker?.allObjects[indexPath.item] as? TrackerCoreData else {
            print("❌ Ошибка: не найден трекер в секции \(indexPath.section), строка \(indexPath.row)")
            return UICollectionViewCell()
        }
        
        let trackerRecordsForTracker = trackerRecords.filter { $0.trackerID == tracker.id }
        
        cell.delegate = self
        cell.viewController = self
        cell.configure(with: tracker, trackerRecords: trackerRecordsForTracker)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        }
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
        
        let category = filteredCategories[indexPath.section]
        header.configure(with: category.title ?? "Без категории")
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 150, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionWidth = categoriesCollectionView.bounds.width
        
        let sectionInset = (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? .zero
        let minimumSpacing = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0
        let availableWidth = collectionWidth - sectionInset.left - sectionInset.right
        let cellWidth = (availableWidth - minimumSpacing) / 2
        let cellHeight: CGFloat = 148
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

extension Date {
    func isSameDay(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: otherDate)
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        updateUI()
        print("📌 Вызван метод didUpdate — обновляем данные")
        do {
            try trackerCategoryStore.fetchedResultsController.performFetch()
            reloadCategoryData()
        } catch {
            print("❌ Ошибка обновления данных: \(error)")
        }
    }
}

extension TrackersViewController: NewTrackerDelegate {
    func didCreateTracker(_ tracker: TrackerCoreData, _ category: TrackerCategoryCoreData) {
        do {
            try trackerCategoryStore.fetchedResultsController.performFetch()
            updateVisibleTrackers(for: datePicker.date)
            updateUI()
            print("📌 Трекер создан, обновляем коллекцию")
            reloadCategoryData()
        } catch {
            print("❌ Ошибка обновления FRC: \(error)")
        }
    }
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterTrackers(for: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    private func filterTrackers(for searchText: String) {
        let allTrackers = trackerStore.fetchAllTrackers()
        
        let dateFilteredTrackers = allTrackers.filter { tracker in
            guard let weekDays = tracker.weekDays as? [String] else { return false }
            
            let isCompleted = trackerRecords.contains { $0.trackerID == tracker.id && $0.date?.isSameDay(as: selectedDate) == true }
            let isRegular = !weekDays.contains(" ")
            
            return isRegular ? weekDays.contains(getSelectedWeekday()) : isCompleted
        }
        
        if searchText.isEmpty {
            updateVisibleTrackers(for: selectedDate)
        } else {
            let searchFilteredTrackers = dateFilteredTrackers.filter { tracker in
                tracker.name?.lowercased().contains(searchText.lowercased()) ?? false
            }
            
            filteredCategories = trackerCategoryStore.fetchAllTrackerCategories().compactMap { category in
                let trackersInCategory = searchFilteredTrackers.filter { $0.category == category }
                guard !trackersInCategory.isEmpty else { return nil }
                
                let filteredCategory = TrackerCategoryCoreData(context: context)
                filteredCategory.title = category.title
                filteredCategory.tracker = NSSet(array: trackersInCategory)
                return filteredCategory
            }
        }
        reloadCategoryData()
    }
}
