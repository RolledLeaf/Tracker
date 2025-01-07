
import Foundation
import UIKit

final class TrackersViewController: UIViewController, UICollectionViewDataSource {
    
    
    
    
    private let plusButton = UIButton()
    private let trackersLabel = UILabel()
    private let emptyFieldStarImage = UIImageView()
    private let emptyFieldLabel = UILabel()
    
    private var datePickerHeightConstraint: NSLayoutConstraint?
    var categories: [TrackerCategory]?
    var completedTrackers: [TrackerRecord]?
   
    
    
    private let habbitsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 167, height: 148)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Что будем искать?"
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
    
    private func setupInitialUI() {
      
        if let completedTrackers = completedTrackers, completedTrackers.isEmpty {
            emptyFieldLabel.isHidden = false
            emptyFieldStarImage.isHidden = false
            habbitsCollectionView.isHidden = true
        } else {
            emptyFieldStarImage.isHidden = true
            emptyFieldLabel.isHidden = true
            habbitsCollectionView.isHidden = false
        }
        
        view.backgroundColor = UIColor(named: CustomColors.backgroundGray.rawValue)
        
        let uiElements = [plusButton, dateButton, habbitsCollectionView, trackersLabel, searchBar, emptyFieldStarImage, emptyFieldLabel, datePicker]
        uiElements.forEach {$0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        configureLabel(trackersLabel, text: "Трекеры", fontSize: 34, weight: .bold, color: .textColor)
        configureLabel(emptyFieldLabel, text: "Что будем отслеживать?", fontSize: 12, weight: .regular, color: .textColor)
        plusButton.setImage(UIImage(named: "plusButton"), for: .normal)
        emptyFieldStarImage.image = UIImage(named: "dizzyStar")
        
        
        datePickerHeightConstraint = datePicker.heightAnchor.constraint(equalToConstant: 0)
        if let datePickerHeightConstraint = datePickerHeightConstraint {
            NSLayoutConstraint.activate([
                // Остальные ограничения...
                
                datePicker.topAnchor.constraint(equalTo: dateButton.bottomAnchor, constant: 8),
                datePicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                datePickerHeightConstraint // Активируем ограничение высоты
            ])
        }
        
        NSLayoutConstraint.activate([
            
            habbitsCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            habbitsCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            habbitsCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 24),
            
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
        
        habbitsCollectionView.dataSource = self
        
        habbitsCollectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return completedTrackers?.count ?? 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as? TrackerCell else {
            fatalError("Unable to dequeue TrackerCell")
        }
        
        // Безопасно извлекаем массив completedTrackers
        guard let completedTrackers = completedTrackers else {
            print("Warning: completedTrackers is nil")
               habbitsCollectionView.isHidden = true
               return UICollectionViewCell()
        }
        
        // Извлекаем трекер
        let trackerRecord = completedTrackers[indexPath.row]
        let tracker = trackerRecord.executedTracker
        
        // Считаем количество выполнений трекера
        let completedCount = completedTrackers.filter { $0.executedTracker.id == tracker.id }.count
        
        // Конфигурируем ячейку
        cell.configure(with: tracker, completedCount: completedCount)
        
        return cell
    }
    
}
