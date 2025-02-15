import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    
    func updateSubtitle (for title: String, with subtitle: String?)
}

final class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ScheduleTableCellDelegate {
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.custom(.textColor)
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.text = "Расписание"
        return label
    }()
    
    private lazy var weekDaysTable: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        tableView.rowHeight = 75
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor.custom(.createButtonTextColor), for: .normal)
        button.backgroundColor = UIColor.custom(.createButtonColor)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }()
    
    private let weekDays: [String] = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    
    
    //English localization
    private let weekDayOrder = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let weekDayAbbreviations: [String: String] = [
        "Понедельник": "Пн",
        "Вторник": "Вт",
        "Среда": "Ср",
        "Четверг": "Чт",
        "Пятница": "Пт",
        "Суббота": "Сб",
        "Воскресенье": "Вс"
    ]
    
    /*
     // Russian localization
     private let weekDayOrder = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вск"]
     private let weekDayAbbreviations: [String: String] = [
     "Понедельник": "Пн",
     "Вторник": "Вт",
     "Среда": "Ср",
     "Четверг": "Чт",
     "Пятница": "Пт",
     "Суббота": "Сб",
     "Воскресенье": "Вск"
     ]
     */
    private var selectedWeekDays: [String] = []
    private var tempSelectedWeekDays: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        if let savedDays = UserDefaults.standard.array(forKey: "selectedWeekDays") as? [String] {
            selectedWeekDays = savedDays
            tempSelectedWeekDays = savedDays
        }
        weekDaysTable.reloadData()
        view.backgroundColor = UIColor(named: CustomColor.mainBackgroundColor.rawValue)
    }
    
    private func setupViews() {
        
        let uiElements = [titleLabel, weekDaysTable, doneButton]
        uiElements.forEach { view.addSubview($0) }
        uiElements.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        let tableHeight = CGFloat(weekDays.count) * weekDaysTable.rowHeight
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.widthAnchor.constraint(equalToConstant: 97),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            weekDaysTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            weekDaysTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            weekDaysTable.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            weekDaysTable.widthAnchor.constraint(equalToConstant: 150),
            weekDaysTable.heightAnchor.constraint(equalToConstant: tableHeight),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        weekDaysTable.delegate = self
        weekDaysTable.dataSource = self
        weekDaysTable.register(ScheduleTableCell.self, forCellReuseIdentifier: ScheduleTableCell.identifier)
    }
    
    private func getSortedSelectedWeekDays() -> String {
        if selectedWeekDays.count == weekDays.count {
            return "Ежедневно"
        } else {
            let sortedAbbreviations = selectedWeekDays.sorted {
                let index1 = weekDayOrder.firstIndex(of: weekDayAbbreviations[$0] ?? "") ?? 0
                let index2 = weekDayOrder.firstIndex(of: weekDayAbbreviations[$1] ?? "") ?? 0
                return index1 < index2
            }.compactMap { weekDayAbbreviations[$0] }
            
            return sortedAbbreviations.joined(separator: ", ")
        }
    }
    
    @objc private func doneButtonTapped() {
        print("Schedule done button ")
        print("Завершено. Переданные дни недели: \(tempSelectedWeekDays)")
        selectedWeekDays = tempSelectedWeekDays
        let sortedWeekDaysString = getSortedSelectedWeekDays()
        delegate?.updateSubtitle(for: "Расписание", with: sortedWeekDaysString)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableCell.identifier) as? ScheduleTableCell else {
            return UITableViewCell()
        }
        
        let day = weekDays[indexPath.row]
        let isOn = selectedWeekDays.contains(day)
        cell.configure(with: day, isOn: isOn)
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius: CGFloat = 16
        
        cell.layer.cornerRadius = 0
        cell.layer.maskedCorners = []
        cell.clipsToBounds = true
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) // Обычные отступы для разделителя
        
        if indexPath.row == 0 {
            cell.layer.cornerRadius = cornerRadius
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) // Разделитель остается видимым
        }
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.layer.cornerRadius = cornerRadius
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        }
    }
    
    func didChangeSwitchState(isOn: Bool, forDay day: String) {
        if isOn {
            if !tempSelectedWeekDays.contains(day) {
                tempSelectedWeekDays.append(day)
            }
        } else {
            
            if let index = tempSelectedWeekDays.firstIndex(of: day) {
                tempSelectedWeekDays.remove(at: index)
            }
        }
    }
    
}
