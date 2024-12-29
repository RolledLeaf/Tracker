
import Foundation
import UIKit

final class TrackerViewController: UIViewController {
    
    
    private let plusButton = UIButton()
    private let trackersLabel = UILabel()
    private let emptyFieldStarImage = UIImageView()
    private let emptyFieldLabel = UILabel()
    
    private let searchBar: UISearchBar = {
          let searchBar = UISearchBar()
          searchBar.placeholder = "Что будем искать?"
          searchBar.searchBarStyle = .minimal
          searchBar.setImage(UIImage(systemName: "magnifyingglass.circle"), for: .search, state: .normal)
          return searchBar
      }()
    
    private lazy var dateButton: UIButton = {
           let button = UIButton(type: .system)
           button.setTitle(currentDateFormatted(), for: .normal)
           button.setTitleColor(.label, for: .normal)
           button.titleLabel?.font = .systemFont(ofSize: 16)
           button.addTarget(self, action: #selector(toggleCalendar), for: .touchUpInside)
           return button
       }()
    private lazy var datePicker: UIDatePicker = {
            let picker = UIDatePicker()
            picker.datePickerMode = .date
            picker.preferredDatePickerStyle = .inline
            picker.isHidden = true // Скрыт по умолчанию
            picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
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
       }

    
       @objc private func toggleCalendar() {
           UIView.animate(withDuration: 0.3) {
               self.datePicker.isHidden.toggle()
           }
       }
    
    
    
    private func configureLabel(_ label: UILabel, text: String, fontSize: CGFloat, weight: UIFont.Weight, color: CustomColors) {
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textColor = UIColor(named: color.rawValue)
    }
    
    private func setupInitialUI() {
        
        view.backgroundColor = UIColor(named: CustomColors.backgroundGray.rawValue)
        
        let uiElements = [plusButton, dateButton, trackersLabel, searchBar, emptyFieldStarImage, emptyFieldLabel]
        uiElements.forEach {$0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        configureLabel(trackersLabel, text: "Трекеры", fontSize: 34, weight: .bold, color: .textColor)
        configureLabel(emptyFieldLabel, text: "Что будем отслеживать?", fontSize: 12, weight: .regular, color: .textColor)
        plusButton.setImage(UIImage(named: "plusButton"), for: .normal)
        emptyFieldStarImage.image = UIImage(named: "dizzyStar")
        
        
        NSLayoutConstraint.activate([
            plusButton.heightAnchor.constraint(equalToConstant: 19),
            plusButton.widthAnchor.constraint(equalToConstant: 18),
            plusButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 18),
            plusButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 13),
            
            dateButton.heightAnchor.constraint(equalToConstant: 77),
            dateButton.widthAnchor.constraint(equalToConstant: 34),
            dateButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16),
            dateButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 5),
            
            trackersLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackersLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 88),
            
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchBar.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 7),
            
            emptyFieldStarImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyFieldStarImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyFieldStarImage.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 220),
            emptyFieldStarImage.widthAnchor.constraint(equalToConstant: 80),
            emptyFieldStarImage.heightAnchor.constraint(equalToConstant: 80)
            
            ])
            
    }
    
}
