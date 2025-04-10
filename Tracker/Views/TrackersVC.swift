import UIKit
import CoreData
import AppMetricaCore

final class TrackersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    private var categories: [TrackerCategoryCoreData] = []
    private var filteredCategories: [TrackerCategoryCoreData] = []
    private var trackerRecords: [TrackerRecordCoreData] = []
    private var currentSelectedTracker: TrackerCoreData?
    private var currentDate: Date = Date()
    private var selectedIndexPath: IndexPath?
    private var isFilterButtonMinimized = false
    private var filterButtonLeadingConstraint: NSLayoutConstraint!
    private var filterButtonTrailingConstraint: NSLayoutConstraint!
    private var filterButtonWidthConstraint: NSLayoutConstraint!
    
    
    private let addTrackerButton = UIButton()
    private let emptyFieldStarImage = UIImageView()
    private let nothingFoundImage = UIImageView()
    private let trackersLabel = UILabel()
    private let nothingFoundLabel = UILabel()
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
        searchBar.placeholder = NSLocalizedString("search", comment: "")
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
        button.setTitleColor(UIColor.custom(.pitchBlack), for: .normal)
        button.setTitle(currentDateFormatted(), for: .normal)
        button.backgroundColor = UIColor.custom(.dataGray)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return button
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor.custom(.textColor)
        button.layer.cornerRadius = 16
        button.setTitle(NSLocalizedString("filtersButtonTitle", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.custom(.toggleSwitchBlue)
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialUI()
        loadCategories()
        loadTrackerRecords()
        reloadCategoryData()
        
        updateVisibleTrackers(for: datePicker.date)
        viewModel.onTrackersUpdate = { [weak self] trackers in
            self?.categoriesCollectionView.reloadData()
        }
        viewModel.onFilterChanged = { [weak self] filter in
            guard let self = self else { return }
            if filter == .today {
                self.selectedDate = Date()
                self.datePicker.setDate(self.selectedDate, animated: true)
                self.dateButton.setTitle(self.currentDateFormatted(), for: .normal)
            }
            self.updateVisibleTrackers(for: self.selectedDate)
        }
    }
    
    private func setupInitialUI() {
        datePicker.maximumDate = Date()
        isCollectionVisible()
        view.backgroundColor = UIColor(named: CustomColor.mainBackgroundColor.rawValue)
        let uiElements = [addTrackerButton, categoriesCollectionView, trackersLabel, searchBar, emptyFieldStarImage, nothingFoundImage, nothingFoundLabel, emptyFieldLabel, dateButton, datePicker, filterButton]
        uiElements.forEach {$0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        configureLabel(trackersLabel, text: NSLocalizedString("trackersLabel", comment: ""), fontSize: 34, weight: .bold, color: .textColor)
        configureLabel(emptyFieldLabel, text: NSLocalizedString("emptyTrackerCollectionPlaceholder", comment: ""), fontSize: 12, weight: .regular, color: .textColor)
        configureLabel(nothingFoundLabel, text: NSLocalizedString("nothingFoundLabel", comment: ""), fontSize: 12, weight: .medium, color: .textColor)
        trackersLabel.textAlignment = .left
        
        
        addTrackerButton.setImage(UIImage(named: "addTrackerButton"), for: .normal)
        addTrackerButton.addTarget(self, action: #selector(addTrackerButtonTapped), for: .touchUpInside)
        
        emptyFieldStarImage.image = UIImage(named: "dizzyStar")
        nothingFoundImage.image = UIImage(named: "nothingFound")
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        filterButtonTrailingConstraint = filterButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -130)
       
        filterButtonLeadingConstraint = filterButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 130)
      
        
      
        
        NSLayoutConstraint.activate([
            dateButton.heightAnchor.constraint(equalToConstant: 34),
            dateButton.widthAnchor.constraint(equalToConstant: 77),
            dateButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            dateButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -5),

            datePicker.centerXAnchor.constraint(equalTo: dateButton.centerXAnchor),
            datePicker.centerYAnchor.constraint(equalTo: dateButton.centerYAnchor),

            addTrackerButton.heightAnchor.constraint(equalToConstant: 19),
            addTrackerButton.widthAnchor.constraint(equalToConstant: 18),
            addTrackerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 18),
            addTrackerButton.bottomAnchor.constraint(equalTo: trackersLabel.safeAreaLayoutGuide.topAnchor, constant: -10),
            
            categoriesCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoriesCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 34),
            categoriesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            
            
            trackersLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackersLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            
            searchBar.trailingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            searchBar.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 12),
            
            emptyFieldLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyFieldLabel.topAnchor.constraint(equalTo: emptyFieldStarImage.bottomAnchor, constant: 8),
            
            emptyFieldStarImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 402),
            emptyFieldStarImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyFieldStarImage.widthAnchor.constraint(equalToConstant: 80),
            emptyFieldStarImage.heightAnchor.constraint(equalToConstant: 80),
            
            nothingFoundImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 402),
            nothingFoundImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nothingFoundImage.widthAnchor.constraint(equalToConstant: 80),
            nothingFoundImage.heightAnchor.constraint(equalToConstant: 80),
            
            nothingFoundLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nothingFoundLabel.topAnchor.constraint(equalTo: nothingFoundImage.bottomAnchor, constant: 8),
            
            filterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            
            filterButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        filterButtonWidthConstraint = filterButton.widthAnchor.constraint(equalToConstant: 260)
        filterButtonWidthConstraint.isActive = false
        
        filterButtonLeadingConstraint = filterButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 130)
        filterButtonLeadingConstraint.isActive = true
        
        filterButtonTrailingConstraint =
        filterButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -130)
        filterButtonTrailingConstraint.isActive = true
        
        
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
        print("UpdateVisibleTrackers method called")
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "EEE"
        let selectedWeekday = formatter.string(from: selectedDate)

        let allTrackers = trackerStore.fetchAllTrackers()

        let filteredTrackers: [TrackerCoreData]

        switch viewModel.selectedFilter {
        case .all:
            filteredTrackers = allTrackers.filter { tracker in
                guard let weekDays = tracker.weekDays as? [String] else { return false }
                let isCompleted = trackerRecords.contains { $0.trackerID == tracker.id && $0.date?.isSameDay(as: selectedDate) == true }
                let hasEverBeenCompleted = trackerRecords.contains { $0.trackerID == tracker.id }
              
                print("called isCollectionVisible method for all trackers")
                return weekDays.contains(" ") ? !hasEverBeenCompleted || isCompleted : weekDays.contains(selectedWeekday)
                
            }
            
        case .today:
            filteredTrackers = allTrackers.filter { tracker in
                guard let weekDays = tracker.weekDays as? [String] else { return false }
                let isCompleted = trackerRecords.contains { $0.trackerID == tracker.id && $0.date?.isSameDay(as: selectedDate) == true }
                let hasEverBeenCompleted = trackerRecords.contains { $0.trackerID == tracker.id }
                
                print("called filteredCollectionVisible method for today trackers")
                return weekDays.contains(" ") ? !hasEverBeenCompleted || isCompleted : weekDays.contains(selectedWeekday)
            }
            
        case .completed:
            Analytics.logEvent(.filterCompletedActive)
            filteredTrackers = allTrackers.filter { tracker in
                trackerRecords.contains { $0.trackerID == tracker.id && $0.date?.isSameDay(as: selectedDate) == true }
            }
           
            print("called filteredCollectionVisible method for completed trackers")

        case .uncompleted:
            filteredTrackers = allTrackers.filter { tracker in
                guard let weekDays = tracker.weekDays as? [String] else { return false }
                let isCompleted = trackerRecords.contains { $0.trackerID == tracker.id && $0.date?.isSameDay(as: selectedDate) == true }
                let hasEverBeenCompleted = trackerRecords.contains { $0.trackerID == tracker.id }
                
                print("called filteredCollectionVisible method for uncompleted trackers")
                if weekDays.contains(" ") {
                    return !hasEverBeenCompleted
                } else {
                    return !isCompleted
                }
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
            isCollectionVisible()
            print("📌 Трекеры отфильтрованы через FRC")
        } catch {
            print("❌ Ошибка при фильтрации трекеров: \(error.localizedDescription)")
        }
    }
 
    private func getSelectedWeekday() -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "E"
        return formatter.string(from: datePicker.date)
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
        Analytics.logEvent(.addTrackerButtonTapped)
    }
    
    @objc private func filterButtonTapped() {
        if isFilterButtonMinimized == true  {
            guard isFilterButtonMinimized else { return }
            
            isFilterButtonMinimized = false
            self.filterButtonWidthConstraint.isActive = false
            self.filterButtonLeadingConstraint.isActive = true
            UIView.animate(withDuration: 0.3) {
                self.filterButton.setTitle(NSLocalizedString("filtersButtonTitle", comment: ""), for: .normal)
                self.filterButton.setImage(UIImage(systemName: ""), for: .normal)
                
                self.filterButtonLeadingConstraint.constant = 130
                self.filterButtonTrailingConstraint.constant = -130
             
               
                self.view.layoutIfNeeded()
            }
        } else {
            
            view.endEditing(true)
            let filterVC = FiltersViewController()
            filterVC.onFilterSelected = { [weak self] filter in
                self?.viewModel.selectedFilter = filter
            }
            present(filterVC, animated: true)
        }
    }
    
    @objc private func handleSwipeRight(_ gesture: UISwipeGestureRecognizer) {
        guard !isFilterButtonMinimized else { return }

        isFilterButtonMinimized = true

        UIView.animate(withDuration: 0.3) {
            self.filterButton.setTitle("", for: .normal)
            self.filterButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
            self.filterButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
    
            self.filterButtonTrailingConstraint.constant = 20
            self.filterButtonLeadingConstraint.isActive = false
            self.filterButtonWidthConstraint.isActive = true
            self.filterButtonWidthConstraint.constant = 40
            
            
            
            self.view.layoutIfNeeded()
        }
    }
    
    private func configureLabel(_ label: UILabel, text: String, fontSize: CGFloat, weight: UIFont.Weight, color: CustomColor) {
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textColor = UIColor(named: color.rawValue)
    }
    
    private func isCollectionVisible() {
        let hasVisibleTrackers = categoriesCollectionView.numberOfSections > 0 &&
            (0..<categoriesCollectionView.numberOfSections).contains { section in
                categoriesCollectionView.numberOfItems(inSection: section) > 0
            }

        switch viewModel.selectedFilter {
        case .all:
            // Показываем "Что будем отслеживать?" только если трекеров нет
            emptyFieldLabel.isHidden = hasVisibleTrackers
            emptyFieldStarImage.isHidden = hasVisibleTrackers
            nothingFoundLabel.isHidden = true
            nothingFoundImage.isHidden = true
            filterButton.isHidden = !hasVisibleTrackers
        default:
            // Показываем "Ничего не найдено" только если трекеров нет
            emptyFieldLabel.isHidden = true
            emptyFieldStarImage.isHidden = true
            nothingFoundLabel.isHidden = hasVisibleTrackers
            nothingFoundImage.isHidden = hasVisibleTrackers
            filterButton.isHidden = false
        }

        
        categoriesCollectionView.isHidden = !hasVisibleTrackers
    }
    
   
    func getSelectedDate() -> Date {
         selectedDate
    }

    private func createContextMenu(for indexPath: IndexPath) -> UIMenu {

        let tracker = self.trackerStore.fetchedResultsController.object(at: indexPath)
        let isPinned = tracker.category?.title == NSLocalizedString("pinned", comment: "")
        let pinTitle = isPinned ? NSLocalizedString("pin", comment: "") : NSLocalizedString("unpin", comment: "")
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
           
        let editAction = UIAction(title: NSLocalizedString("contextMenuEdit", comment: ""), image: nil) { _ in
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
           
           let deleteAction = UIAction(title: NSLocalizedString("contextMenuDelete", comment: ""), image: nil) { _ in
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
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
                return nil
            }

            // Возвращаем UIViewController с backgroundContainer как view
            let previewController = UIViewController()
            let snapshot = cell.snapshotView(of: cell.backgroundContainer)
            previewController.view = UIView(frame: snapshot.bounds)
            previewController.view.addSubview(snapshot)
            snapshot.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                snapshot.topAnchor.constraint(equalTo: previewController.view.topAnchor),
                snapshot.bottomAnchor.constraint(equalTo: previewController.view.bottomAnchor),
                snapshot.leadingAnchor.constraint(equalTo: previewController.view.leadingAnchor),
                snapshot.trailingAnchor.constraint(equalTo: previewController.view.trailingAnchor)
            ])
            previewController.preferredContentSize = snapshot.bounds.size
            previewController.view.layer.cornerRadius = 16
            previewController.view.clipsToBounds = true
            return previewController
        }, actionProvider: { _ in
            return self.createContextMenu(for: indexPath)
        })
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
            nothingFoundImage.isHidden =  true
            nothingFoundLabel.isHidden = true
            categoriesCollectionView.isHidden = false
            return
        }
        let trackerIDs = filteredTrackers.compactMap { $0.id }
        if trackerIDs.isEmpty {
            nothingFoundImage.isHidden = false
            nothingFoundLabel.isHidden = false
            categoriesCollectionView.isHidden = true
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

extension UIView {
    func snapshotView(of subview: UIView) -> UIView {
        let renderer = UIGraphicsImageRenderer(bounds: subview.bounds)
        let image = renderer.image { ctx in
            subview.drawHierarchy(in: subview.bounds, afterScreenUpdates: true)
        }
        let imageView = UIImageView(image: image)
        imageView.frame = subview.bounds
        return imageView
    }
}
