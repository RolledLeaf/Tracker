import UIKit

final class HabitCreationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource {
  
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.layer.cornerRadius = 16
        textField.font = .systemFont(ofSize: 17, weight: .medium)
        textField.textColor = UIColor.custom(.textFieldGray)
        textField.backgroundColor = UIColor.custom(.backgroundGray)
        textField.textAlignment = .left
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
           textField.leftView = paddingView
           textField.leftViewMode = .always

        return textField
    }()
    
    private let categoryAndScheduleTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CategoryAndScheduleTableViewCell.self, forCellReuseIdentifier: CategoryAndScheduleTableViewCell.identifier) //регистрация по ячейке
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    private let emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 32, height: 38)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.identifier)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let colorsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ColorsCollectionViewCell.self, forCellWithReuseIdentifier: ColorsCollectionViewCell.identifier)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let createTrackerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 10
        return button
    }()
    
  
    
    
    private let tableViewOptions = ["Категория", "Расписание"]
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    private let trackerCollectionColors: [CollectionColors] = [.collectionRed1, .collectionOrange2, .collectionPurple4, .collectionLightGreen5, .collectionViolet6, .collectionBeige7, .collectionLightBlue8, .collectionJadeGreen9, .collectionDarkPurple10, .collectionCarrotOrange11, .collectionPink12, .collectionLightBrick13, .collectionSemiblue14, .collectionLightPurple15, .collectionDarkViolet16, .collectionPalePurple17, .collectionGreen18]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
    }
    
    
    private func setupViews() {
        
        let buttonsStackView = UIStackView(arrangedSubviews: [ createTrackerButton, cancelButton])
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 8
        buttonsStackView.distribution = .fillEqually
        
        
        let UIelements = [titleLabel, trackerNameTextField, categoryAndScheduleTableView, emojiCollectionView, colorsCollectionView, buttonsStackView]
        
        UIelements.forEach { view.addSubview($0) }
        
        UIelements.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -32),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            trackerNameTextField.widthAnchor.constraint(equalToConstant: 343),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            trackerNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            trackerNameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            categoryAndScheduleTableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            categoryAndScheduleTableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emojiCollectionView.topAnchor.constraint(equalTo: categoryAndScheduleTableView.bottomAnchor, constant: 32),
            emojiCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emojiCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            colorsCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 34),
            colorsCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            colorsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            colorsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            colorsCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)])
            
            
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojis.count
        } else if collectionView == colorsCollectionView {
            return trackerCollectionColors.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.identifier, for: indexPath) as? EmojiCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(with: emojis[indexPath.item])
            return cell
        } else if collectionView == colorsCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorsCollectionViewCell.identifier, for: indexPath) as? ColorsCollectionViewCell else {
                        return UICollectionViewCell()
                    }
            // Пробуем извлечь цвет, если не получается — используем дефолтный цвет
               guard let color = trackerCollectionColors[indexPath.item].uiColor else {
                   cell.configure(with: .gray)  // дефолтный цвет
                   return cell
               }
                
            // Настроим ячейку, передав цвет
                cell.configure(with: color)
                return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == colorsCollectionView {
            let selectedColor = trackerCollectionColors[indexPath.item]
            print("Selected color: \(selectedColor)")
            // Обработайте выбор цвета
        } else if collectionView == emojiCollectionView {
            let selectedEmoji = emojis[indexPath.item]
            print("Selected emoji: \(selectedEmoji)")
            // Обработайте выбор цвета
        }
    }
    
    
    //Настройки таблицы
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryAndScheduleTableViewCell.identifier, for: indexPath) as? CategoryAndScheduleTableViewCell else {
        return UITableViewCell()
    }
    
    let titles = ["Категория", "Расписание"]
    cell.configure(with: titles[indexPath.row])
    return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            if indexPath.row == 0 {
                // Действие для "Категория"
            } else if indexPath.row == 1 {
                // Действие для "Расписание"
            }
        }
}
