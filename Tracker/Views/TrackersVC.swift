import UIKit
import CoreData



final class TrackersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
   
    
    
    var selectedDate: Date = Date()
    var categories: [TrackerCategoryCoreData] = []
    var filteredCategories: [TrackerCategoryCoreData] = []
    var trackerRecords: [TrackerRecordCoreData] = []
    var currentSelectedTracker: TrackerCoreData?
    var currentDate: Date = Date()
    var selectedIndexPath: IndexPath?
    
    private let trackerCategoryStore =  TrackerCategoryStore()
   
    private let plusButton = UIButton()
    private let trackersLabel = UILabel()
    private let emptyFieldStarImage = UIImageView()
    private let emptyFieldLabel = UILabel()
    private let locale = Locale(identifier: "ru_RU")
    private let context = CoreDataStack.shared.persistentContainer.viewContext
    
    var groupedTrackers: [String: [TrackerCoreData]] = [:]
    
  
    private var datePickerHeightConstraint: NSLayoutConstraint?
    private var categoriesCollectionViewHeight: NSLayoutConstraint?
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    private lazy var trackerStore: TrackerStore = {
        let store = TrackerStore()
        store.delegate = self
        return store
    }()
    
    private lazy var trackerRecordStore: TrackerRecordStore = {
        let store = TrackerRecordStore()
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
        reloadCategoryData()
        updateUI()
 
      //updateVisibleTrackers(for: datePicker.date)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchAllCategories()
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
                plusButton.topAnchor.constraint(equalTo: navView.safeAreaLayoutGuide.topAnchor, constant: 13),
            ])
        }
    }
    
    private func reloadCategoryData() {
        categoriesCollectionView.reloadData()
    }
    
    func fetchAllCategories() {
        let fetchedCategoies = trackerCategoryStore.fetchAllTrackerCategories()
        print("Запрошены категории. Получены следующие категории: \(fetchedCategoies)")
         filteredCategories = fetchedCategoies
        
    }
    
 
    
    func groupTrackersByCategory() {
     
        groupedTrackers.removeAll()
    }
    

    func loadCategoriesAndTrackers() {
        categories = trackerCategoryStore.fetchAllTrackerCategories()
        print("Fetched categories: \(categories.count)")
    }
    
    /*
    private func updateVisibleTrackers(for selectedDate: Date) {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "EEE"
        
        let selectedWeekday = formatter.string(from: selectedDate)
        
        let categoryFetchRequest: NSFetchRequest<TrackerCategory> = TrackerCategory.fetchRequest()
        
        do {
            let categories = try CoreDataStack.shared.context.fetch(categoryFetchRequest)
            
            var tempCategories: [TrackerCategory] = []
            
            for category in categories {
                let trackers = category.tracker?.allObjects as? [Tracker] ?? []
                var filteredTrackers: [Tracker] = []
                
                for tracker in trackers {
                    guard let trackerWeekDays = tracker.weekDays else { continue }
                    
                    guard let weekDaysArray = WeekDaysTransformer().transformedValue(trackerWeekDays) as? [String] else { continue }
                    
                    if weekDaysArray.contains(" ") {
                        if !trackerRecords.contains(where: { $0.trackerID == tracker.id && !($0.date?.isSameDay(as: selectedDate) ?? true) }) {
                            filteredTrackers.append(tracker)
                        }
                    } else {
                        if weekDaysArray.contains(selectedWeekday) {
                            filteredTrackers.append(tracker)
                        }
                    }
                }
                
                if !filteredTrackers.isEmpty {
                    let categoryWithFilteredTrackers = TrackerCategory()
                    tempCategories.append(categoryWithFilteredTrackers)
                }
            }
            
            filteredCategories = tempCategories
            
            reloadCategoryData()
            
        } catch {
            print("Failed to fetch categories: \(error)")
        }
    }
*/

    /*2
    private func filterCategoryByDate(_ category: TrackerCategory) -> TrackerCategory? {
        
    }
    
*/
    
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
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
    //    updateVisibleTrackers(for: sender.date)
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
    
    func getSelectedDate() -> Date {
        return selectedDate
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
        
        let selectedDateString = formatter.string(from: sender.date)
        let formattedDate = formatter.string(from: sender.date)
        dateButton.setTitle(formattedDate, for: .normal)
        updateUI()
        reloadCategoryData()
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
            let hasTrackers = !(categoriesFromDataBase.isEmpty)
            
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
    
    
    @objc private func plusButtonTapped() {
        view.endEditing(true)
        let createHabitVC = CreateHabitTypeViewController()
        createHabitVC.delegate = self
        let navigationController = UINavigationController(rootViewController: createHabitVC)
        navigationController.modalPresentationStyle = .automatic
        present(navigationController, animated: true)
    }
    
    
}

//3
extension TrackersViewController: TrackerCategoryCellDelegate {
    //5
    func trackerExecution(_ cell: TrackerCell, didTapDoneButtonFor trackerID: UUID, selectedDate: Date) {
        let calendar = Calendar.current
    }
    
  
    /* 4
    func getTrackerByID(_ trackerID: Int) -> Tracker? {
        
        let tracker = Tracker(context: CoreData)
        return tracker
    }
    */
   
   
}
    
    //6
    private func updateTrackerDaysCount(for trackerID: Int, isChecked: Bool) {
       
}

extension TrackersViewController {
    
    
    func getTrackers(for indexPath: IndexPath) -> [TrackerCoreData] {
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
        let sections = trackerStore.numberOfSections
        print("📌 Количество секций в коллекции: \(sections)")
        return sections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = trackerStore.numberOfRowsInSection(section)
        print("📌 В секции \(section) должно быть \(count) трекеров")
        return count
    }
    
  
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = categoriesCollectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCell else {
            fatalError("Cannot dequeue TrackerCell")
        }

        let tracker = trackerStore.tracker(at: indexPath)
        
        let trackerRecordsForTracker = trackerRecords.filter { $0.trackerID == tracker.id }
        
        cell.delegate = self
        cell.viewController = self
        cell.configure(with: tracker, trackerRecords: trackerRecordsForTracker)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        selectedIndexPath = indexPath
      
        print("Сохранённый indexPath:", indexPath)
        
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

        let category = trackerCategoryStore.getCategory(at: indexPath)
        header.configure(with: category?.title ?? "Без категории")

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



extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterTrackers(for: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    //??
    private func filterTrackers(for searchText: String) {
        reloadCategoryData()
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
            try trackerCategoryStore.fetchedResultsController.performFetch() // Принудительно обновляем FRC
            reloadCategoryData() // Полностью обновляем список
        } catch {
            print("❌ Ошибка обновления данных: \(error)")
        }
    }
}

extension TrackersViewController: newTrackerDelegate {
    func didCreateTracker(_ tracker: TrackerCoreData, _ category: TrackerCategoryCoreData) {
        do {
            try trackerCategoryStore.fetchedResultsController.performFetch() // Принудительно обновляем данные
            loadCategoriesAndTrackers() // Перезапрашиваем категории и трекеры
            print("📌 Трекер создан, обновляем коллекцию")
            reloadCategoryData() // Полностью перерисовываем список
        } catch {
            print("❌ Ошибка обновления FRC: \(error)")
        }
    }
}
