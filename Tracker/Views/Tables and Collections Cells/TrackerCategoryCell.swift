import UIKit

final class TrackerCategoryCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate {

    
    static let reuseIdentifier = "TrackerCategoryCell"
    
    private var trackers: [Tracker] = []
 
    private var trackersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 167, height: 148)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        trackersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(trackersCollectionView)
        trackersCollectionView.isPrefetchingEnabled = true
     
        NSLayoutConstraint.activate([
            trackersCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackersCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor) 
        ])
        
        trackersCollectionView.dataSource = self
        trackersCollectionView.delegate = self
        
        trackersCollectionView.register(TrackerCollectionCell.self, forCellWithReuseIdentifier: TrackerCollectionCell.reuseIdentifier)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = trackersCollectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionCell.reuseIdentifier, for: indexPath) as? TrackerCollectionCell else {
            return UICollectionViewCell()
        }
        let tracker = trackers[indexPath.item]
        
        cell.configure(with: tracker)
               return cell
        
    }
    
    func configure(with tracker: [Tracker]) {
        self.trackers = tracker
            trackersCollectionView.reloadData()
        }
    
}
