/*

import UIKit
import CoreData

final class TrackersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    var selectedDate: Date = Date()
    var categories: [TrackerCategory] = []
    var filteredCategories: [TrackerCategory] = []
    var trackerRecords: [TrackerRecord] = []
    var currentSelectedTracker: Tracker?
    var currentDate: Date = Date()
    var selectedIndexPath: IndexPath?
    
    private let plusButton = UIButton()
    private let trackersLabel = UILabel()
    private let emptyFieldStarImage = UIImageView()
    private let emptyFieldLabel = UILabel()
    private let locale = Locale(identifier: "ru_RU")
    
    
    private var datePickerHeightConstraint: NSLayoutConstraint?
    private var categoriesCollectionViewHeight: NSLayoutConstraint?
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
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
                plusButton.topAnchor.constraint(equalTo: navView.safeAreaLayoutGuide.topAnchor, constant: 13),
            ])
        }
    }
    
    private func reloadCategoryData() {
        categoriesCollectionView.reloadData()
    }
    
 private func updateVisibleTrackers(for selectedDate: Date) {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "EEE"
        
        let selectedWeekday = formatter.string(from: selectedDate) //
        
        filteredCategories = categories.map { category in
            let filteredTrackers = category.tracker.filter { tracker in
                if tracker.weekDays.contains(" ") {
                    return !trackerRecords.contains { $0.trackerID == tracker.id && !$0.date.isSameDay(as: selectedDate) }
                } else {
                    return tracker.weekDays.contains(selectedWeekday)
                }
            }
            return TrackerCategory(title: category.title, tracker: filteredTrackers)
        }.filter { !$0.tracker.isEmpty }
        
        reloadCategoryData()
    }
    
    private func filterCategoryByDate(_ category: TrackerCategory) -> TrackerCategory? {
        let selectedWeekday = getSelectedWeekday()
        let filteredTrackers = category.tracker.filter { tracker in
            tracker.weekDays.contains(selectedWeekday)
        }
        
        return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, tracker: filteredTrackers)
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
        let hasTrackers = !(categories.isEmpty)
        emptyFieldLabel.isHidden = hasTrackers
        emptyFieldStarImage.isHidden = hasTrackers
        categoriesCollectionView.isHidden = !hasTrackers
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

extension TrackersViewController: TrackerCategoryCellDelegate {
    func getTrackerByID(_ trackerID: Int) -> Tracker? {
        for category in categories {
            if let tracker = category.tracker.first(where: { $0.id == trackerID }) {
                return tracker
            }
        }
        return nil
    }
    /*
    func trackerExecution(_ cell: TrackerCell, didTapDoneButtonFor trackerID: Int, selectedDate: Date) {
        let calendar = Calendar.current
        
        let indexPath = selectedIndexPath
        categoriesCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        
        if let existingIndex = trackerRecords.firstIndex(where: { $0.trackerID == trackerID && calendar.isDate($0.date, inSameDayAs: selectedDate) }) {
            trackerRecords.remove(at: existingIndex)
            updateTrackerDaysCount(for: trackerID, isChecked: false)
            print("Удалена запись для трекера \(trackerID) на \(selectedDate)")
        } else {
            let newRecord = TrackerRecord(trackerID: trackerID, date: selectedDate)
            trackerRecords.append(newRecord)
            print("Добавлена запись для трекера \(trackerID) на \(selectedDate)")
            updateTrackerDaysCount(for: trackerID, isChecked: true)
        }
        if let indexPath = categoriesCollectionView.indexPath(for: cell),
           let tracker = getTrackerByID(trackerID) {
            
            categoriesCollectionView.performBatchUpdates({
                let isChecked = trackerRecords.contains(where: { $0.trackerID == trackerID && calendar.isDate($0.date, inSameDayAs: selectedDate) })
                
                cell.doneButton.setImage(UIImage(systemName: isChecked ? "checkmark" : "plus"), for: .normal)
                if let baseColor = UIColor.fromCollectionColor(tracker.color) {
                    cell.doneButtonContainer.backgroundColor = isChecked ? lightenColor(baseColor, by: 0.3) : baseColor
                } else {
                    cell.doneButtonContainer.backgroundColor = .gray
                }
                
                let daysCount = tracker.daysCount
                cell.daysCountLabel.text = getDayWord(for: daysCount)
                cell.daysNumberLabel.text = "\(tracker.daysCount)"
            }, completion: nil)
        }
    }
    */
    private func updateTrackerDaysCount(for trackerID: Int, isChecked: Bool) {
        if let categoryIndex = s.firstIndex(where: { category in
            category.tracker.contains(where: { $0.id == trackerID })
        }) {
            let category = categories[categoryIndex]
            
            if let trackerIndex = category.tracker.firstIndex(where: { $0.id == trackerID }) {
                let tracker = category.tracker[trackerIndex]
                let updatedDaysCount = tracker.daysCount + (isChecked ? 1 : -1)
                let updatedTracker = Tracker(
                    id: tracker.id,
                    name: tracker.name,
                    color: tracker.color,
                    emoji: tracker.emoji,
                    daysCount: max(0, updatedDaysCount),
                    weekDays: tracker.weekDays
                )
                var updatedTrackers = category.tracker
                updatedTrackers[trackerIndex] = updatedTracker
                let updatedCategory = TrackerCategory(title: category.title, tracker: updatedTrackers)
                
                var updatedCategories = categories
                updatedCategories[categoryIndex] = updatedCategory
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = categoriesCollectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        let category = filteredCategories[indexPath.section]
        let tracker = category.tracker[indexPath.item]
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
        let selectedTracker = filteredCategories[section].tracker[row]
        currentSelectedTracker = selectedTracker
        print("Выбран трекер: \(selectedTracker.name)")
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
        let category = categories[indexPath.section]
        header.configure(with: category.title)
        
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

extension TrackersViewController: NewHabitViewControllerDelegate, NewIrregularEventViewControllerDelegate {
    func didCreateIrregularEvent(_ tracker: Tracker, _ category: TrackerCategory) {
        if let existingCategoryIndex = categories.firstIndex(where: { $0.title == category.title }) {
            let existingCategory = categories[existingCategoryIndex]
            
            if !existingCategory.tracker.contains(where: { $0.name == tracker.name }) {
                let updatedCategory = TrackerCategory(title: existingCategory.title, tracker: existingCategory.tracker + [tracker])
                categories[existingCategoryIndex] = updatedCategory
                print("Добавлен новый трекер \(tracker.name) в существующую категорию \(category.title)")
            } else {
                print("Трекер \(tracker.name) уже существует в категории \(category.title), не добавляем повторно.")
            }
        } else {
            categories.append(category)
            print("Создана новая категория \(category.title) и добавлен трекер \(tracker.name)")
        }
        updateUI()
        updateVisibleTrackers(for: currentDate)
    }
    
    func didCreateTracker(_ tracker: Tracker, _ category: TrackerCategory) {
        // Ищем индекс существующей категории
        if let existingCategoryIndex = categories.firstIndex(where: { $0.title == category.title }) {
            let existingCategory = categories[existingCategoryIndex]
            
            if !existingCategory.tracker.contains(where: { $0.name == tracker.name }) {
                let updatedCategory = TrackerCategory(title: existingCategory.title, tracker: existingCategory.tracker + [tracker])
                categories[existingCategoryIndex] = updatedCategory
                print("Добавлен новый трекер \(tracker.name) в существующую категорию \(category.title)")
            } else {
                print("Трекер \(tracker.name) уже существует в категории \(category.title), не добавляем повторно.")
            }
        } else {
            categories.append(category)
            print("Создана новая категория \(category.title) и добавлен трекер \(tracker.name)")
            
        }
        updateUI()
        updateVisibleTrackers(for: currentDate)
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
        let calendar = Calendar.current
        let dateFilteredCategories = categories.compactMap { category in
            let filteredTrackers = category.tracker.filter { tracker in
                let isRegular = !tracker.weekDays.contains(" ")
                let hasExecutionRecord = trackerRecords.contains { record in
                    record.trackerID == tracker.id && !calendar.isDate(record.date, inSameDayAs: selectedDate)
                }
                let isVisibleToday = isRegular
                ? filterCategoryByDate(category) != nil
                : !hasExecutionRecord || trackerRecords.contains { $0.trackerID == tracker.id && calendar.isDate($0.date, inSameDayAs: selectedDate) }
                
                return isVisibleToday
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, tracker: filteredTrackers)
        }
        
        if searchText.isEmpty {
            updateVisibleTrackers(for: selectedDate)
            reloadCategoryData()
        } else {
            filteredCategories = dateFilteredCategories.compactMap { category in
                let filteredTrackers = category.tracker.filter { tracker in
                    tracker.name.lowercased().contains(searchText.lowercased())
                }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, tracker: filteredTrackers)
            }
        }
        reloadCategoryData()
    }
}

extension Date {
    func isSameDay(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: otherDate)
    }
}


*/
