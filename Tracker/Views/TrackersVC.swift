import UIKit
import CoreData

final class TrackersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    private var categories: [TrackerCategoryCoreData] = []
    private var filteredCategories: [TrackerCategoryCoreData] = []
    private var trackerRecords: [TrackerRecordCoreData] = []
    private var currentSelectedTracker: TrackerCoreData?
    private var currentDate: Date = Date()
    private var selectedIndexPath: IndexPath?
    
    
    private let addTrackerButton = UIButton()
    private let trackersLabel = UILabel()
    private let emptyFieldStarImage = UIImageView()
    private let emptyFieldLabel = UILabel()
    private let locale = Locale(identifier: "ru_RU")
    private let context = CoreDataStack.shared.persistentContainer.viewContext
    
    
     var ifTrackerPinned: Bool = false
    private var datePickerHeightConstraint: NSLayoutConstraint?
    private var categoriesCollectionViewHeight: NSLayoutConstraint?
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YY"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    private var isChecked = false
    
    var selectedDate: Date = Date()
    
    private lazy var viewModel = TrackersViewModel(trackerStore: trackerStore)
    
    private lazy var trackerStore: TrackerStore = {
        let store = TrackerStore()
        store.delegate = self
        return store
    }()
    
    private lazy var trackerCategoryStore:  TrackerCategoryStore = {
        let store = TrackerCategoryStore()
        return store
    }()
    
     lazy var categoriesCollectionView: UICollectionView = {
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
        viewModel.onTrackersUpdate = { [weak self] trackers in
            self?.categoriesCollectionView.reloadData()
        }
        print("✅ safeAreaInsets.top = \(view.safeAreaInsets.top)")
    }
    
    private func setupInitialUI() {
        datePicker.maximumDate = Date()
        updateUI()
        view.backgroundColor = UIColor(named: CustomColor.mainBackgroundColor.rawValue)
        let uiElements = [addTrackerButton, categoriesCollectionView, trackersLabel, searchBar, emptyFieldStarImage, emptyFieldLabel, dateButton, datePicker]
        uiElements.forEach {$0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        configureLabel(trackersLabel, text: "Трекеры", fontSize: 34, weight: .bold, color: .textColor)
        configureLabel(emptyFieldLabel, text: "Что будем отслеживать?", fontSize: 12, weight: .regular, color: .textColor)
        trackersLabel.textAlignment = .left
        addTrackerButton.setImage(UIImage(named: "addTrackerButton"), for: .normal)
        addTrackerButton.addTarget(self, action: #selector(addTrackerButtonTapped), for: .touchUpInside)
        emptyFieldStarImage.image = UIImage(named: "dizzyStar")
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            dateButton.heightAnchor.constraint(equalToConstant: 34),
            dateButton.widthAnchor.constraint(equalToConstant: 77),
            dateButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            dateButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),

            datePicker.centerXAnchor.constraint(equalTo: dateButton.centerXAnchor),
            datePicker.centerYAnchor.constraint(equalTo: dateButton.centerYAnchor),

            addTrackerButton.heightAnchor.constraint(equalToConstant: 19),
            addTrackerButton.widthAnchor.constraint(equalToConstant: 18),
            addTrackerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 18),
            addTrackerButton.bottomAnchor.constraint(equalTo: trackersLabel.safeAreaLayoutGuide.topAnchor, constant: -13),
            
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
 
            if weekDays.contains(" ") {
                return !hasEverBeenCompleted || isCompleted
            } else {
                return weekDays.contains(selectedWeekday)
            }
        }
        
        let sortedTrackers = filteredTrackers.sorted {
            ($0.category?.sortOrder ?? 0) < ($1.category?.sortOrder ?? 0)
        }
        
        
        let trackerIDs = sortedTrackers.compactMap { $0.id }
        trackerStore.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "id IN %@", trackerIDs)

        do {
            try trackerStore.fetchedResultsController.performFetch()
            categoriesCollectionView.reloadData()
            updateUI()
            print("📌 Трекеры отфильтрованы через FRC")
        } catch {
            print("❌ Ошибка при фильтрации трекеров: \(error.localizedDescription)")
        }
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
    
    @objc private func addTrackerButtonTapped() {
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
        let hasVisibleTrackers = categoriesCollectionView.numberOfSections > 0 && (0..<categoriesCollectionView.numberOfSections).contains { section in
            categoriesCollectionView.numberOfItems(inSection: section) > 0
        }

        emptyFieldLabel.isHidden = hasVisibleTrackers
        emptyFieldStarImage.isHidden = hasVisibleTrackers
        categoriesCollectionView.isHidden = !hasVisibleTrackers
    }
    
    func getSelectedDate() -> Date {
        return selectedDate
    }

    private func createContextMenu(for indexPath: IndexPath) -> UIMenu {

        let tracker = self.trackerStore.fetchedResultsController.object(at: indexPath)
        let isPinned = tracker.category?.title == "Закреплённые"
        let pinTitle = isPinned ? "Открепить" : "Закрепить"
        let pinAction = UIAction(title: pinTitle, image: nil) { _ in
            if isPinned {
                if let originalTitle = tracker.originalCategoryTitle {
                    let allCategories = self.trackerCategoryStore.fetchCategories()
                    if let originalCategory = allCategories.first(where: { $0.title == originalTitle }) {
                        tracker.category = originalCategory
                        tracker.originalCategoryTitle = nil
                    }
                }
            } else {
                tracker.originalCategoryTitle = tracker.category?.title
                if let pinnedCategory = self.trackerCategoryStore.getOrCreatePinnedCategory() {
                    tracker.category = pinnedCategory
                }
            }

            do {
                try CoreDataStack.shared.context.save()
                self.updateVisibleTrackers(for: self.selectedDate)
            } catch {
                print("❌ Ошибка при закреплении/откреплении трекера: \(error)")
            }
        }
           
        let editAction = UIAction(title: EditAction.edit.rawValue, image: nil) { _ in
            let editHabitVC = EditHabitViewController()
            let editIrregularVC = EditIrregularEventViewController()
            
            let tracker = self.trackerStore.fetchedResultsController.object(at: indexPath)
            
            if let weekDays = tracker.weekDays as? [String], weekDays == [" "] {
                editIrregularVC.trackerToEdit = tracker
                
                let navigationController = UINavigationController(rootViewController: editIrregularVC)
                navigationController.modalPresentationStyle = .automatic
                self.present(navigationController, animated: true)
            } else {
                
                editHabitVC.trackerToEdit = tracker
                
                let navigationController = UINavigationController(rootViewController: editHabitVC)
                navigationController.modalPresentationStyle = .automatic
                self.present(navigationController, animated: true)
            }
        }
           
           let deleteAction = UIAction(title: EditAction.delete.rawValue, image: nil) { _ in
               self.viewModel.deleteTracker(at: indexPath)
               
           }
           return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
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
        return trackerStore.fetchAllTrackers().first(where: { $0.id == trackerID })
    }
}

extension TrackersViewController {
    
    func didChangeContent() {
        reloadCategoryData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackerStore.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackerStore.numberOfRowsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = categoriesCollectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCell else {
            fatalError("Cannot dequeue TrackerCell")
        }

        let tracker = trackerStore.fetchedResultsController.object(at: indexPath)
        let trackerRecordsForTracker = trackerRecords.filter { $0.trackerID == tracker.id }

        cell.delegate = self
        cell.viewController = self
        cell.backgroundColor = .clear
        cell.configure(with: tracker, trackerRecords: trackerRecordsForTracker)
        

        return cell
    }
    
  
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return self.createContextMenu(for: indexPath)
        }
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

        let sectionTitle = trackerStore.getSectionTitle(for: indexPath.section)
        header.configure(with: sectionTitle)

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
        updateVisibleTrackers(for: selectedDate)
       
    }
}

extension TrackersViewController: NewTrackerDelegate {
    func didCreateTracker(_ tracker: TrackerCoreData, _ category: TrackerCategoryCoreData) {
       
        updateVisibleTrackers(for: selectedDate)
        print("Tracker \(tracker.name ?? "unnamed") created with categorySortOrder \(category.sortOrder)")
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
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "EEE"
        let selectedWeekday = formatter.string(from: selectedDate)

        let allTrackers = trackerStore.fetchAllTrackers()

        let filteredTrackers = allTrackers.filter { tracker in
            guard let name = tracker.name?.lowercased(),
                  let weekDays = tracker.weekDays as? [String] else { return false }

            let matchesName = name.contains(searchText.lowercased())
            let isCompleted = trackerRecords.contains { $0.trackerID == tracker.id && $0.date?.isSameDay(as: selectedDate) == true }
            let hasEverBeenCompleted = trackerRecords.contains { $0.trackerID == tracker.id }

            if weekDays.contains(" ") {
                return matchesName && (!hasEverBeenCompleted || isCompleted)
            } else {
                return matchesName && weekDays.contains(selectedWeekday)
            }
        }

        if searchText.isEmpty {
           updateVisibleTrackers(for: selectedDate)
            return
        }

        let trackerIDs = filteredTrackers.compactMap { $0.id }
        if trackerIDs.isEmpty {
            trackerStore.fetchedResultsController.fetchRequest.predicate = nil
        } else {
            trackerStore.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "id IN %@", trackerIDs)
        }

        do {
            try trackerStore.fetchedResultsController.performFetch()
            categoriesCollectionView.reloadData()
            print("🔎 Фильтрация по поиску выполнена через FRC")
        } catch {
            print("❌ Ошибка фильтрации трекеров по поиску: \(error)")
        }
    }
}
