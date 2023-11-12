import UIKit

final class TrackersViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Трекеры"
        label.textColor = UIColor(named: "ypBlackDay")
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.addTarget(self, action: #selector(didChangeSelectedDate), for: .valueChanged)
        return picker
    }()
    
    private lazy var searchField: UISearchTextField = {
        let field = UISearchTextField()
        
        field.placeholder = "Поиск"
        field.heightAnchor.constraint(equalToConstant: 36).isActive = true
        field.addTarget(self, action: #selector(didChangeSearchText), for: .editingChanged)
        return field
    }()
    
    private let placeholderImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "Image1"))
        
        image.widthAnchor.constraint(equalToConstant: 80).isActive = true
        image.heightAnchor.constraint(equalTo: image.widthAnchor).isActive = true
        return image
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Что будем отслеживать?"
        label.textColor = UIColor(named: "ypBlackDay")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let placeholderErrorImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "Image2"))
        
        image.widthAnchor.constraint(equalToConstant: 80).isActive = true
        image.heightAnchor.constraint(equalTo: image.widthAnchor).isActive = true
        return image
    }()
    
    private let placeholderErrorLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Ничего не найдено"
        label.textColor = UIColor(named: "ypBlackDay")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let trackerCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        collection.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier
        )
        collection.register(
            TrackerCollectionViewHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCollectionViewHeader.identifier
        )
        return collection
    }()
    
    private let widthParameters = CollectionParameters(cellsNumber: 2, leftInset: 16, rightInset: 16, interCellSpacing: 10)
    
    private var categories: Array<TrackerCategoryStruct> = [
        TrackerCategoryStruct(
            title: "Домашний уют",
            trackers: [
                TrackerStruct(
                    id: UUID(),
                    name: "Поливать растения",
                    color: UIColor(named: "ypColorSelection5")!,
                    emoji: "😪",
                    schedule: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
                )
            ]
        )
    ]
    
    private var visibleCategories: Array<TrackerCategoryStruct> = []
    private var completedRecords: Array<TrackerRecordStruct> = []
    private var selectedDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackerCollection.dataSource = self
        trackerCollection.delegate = self
        makeViewLayout()
        handTapHiddenKeyboard()
        navigationBar()
        visibleCategories.append(contentsOf: categories)
        didChangeSelectedDate()
    }
    
    private func isMatchRecord(model: TrackerRecordStruct, with trackerID: UUID) -> Bool {
        return model.trackerID == trackerID && Calendar.current.isDate(model.completionDate, inSameDayAs: selectedDate)
    }
    
    @objc private func didTapAddButton() {
        let createTrackerController = CreateTrackerViewController()
        createTrackerController.delegate = self
        present(UINavigationController(rootViewController: createTrackerController), animated: true)
    }
    
    private func navigationBar() {
        let addButton = UIBarButtonItem(
            image: UIImage(named: "plus"),
            style: .plain,
            target: self,
            action: #selector(didTapAddButton)
        )
        navigationController?.navigationBar.topItem?.setLeftBarButton(addButton, animated: false)
        navigationController?.navigationBar.tintColor = UIColor(named: "ypBlackDay")
    }
    
    private func makeViewLayout() {
        view.backgroundColor = UIColor(named: "ypWhiteDay")
        
        let headerStack = makeHeaderStack()
        
        view.addSubview(headerStack)
        view.addSubview(trackerCollection)
        view.addSubview(placeholderImage)
        view.addSubview(placeholderLabel)
        view.addSubview(placeholderErrorImage)
        view.addSubview(placeholderErrorLabel)
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        trackerCollection.translatesAutoresizingMaskIntoConstraints = false
        placeholderImage.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderErrorImage.translatesAutoresizingMaskIntoConstraints = false
        placeholderErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerCollection.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 10),
            trackerCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackerCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackerCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderImage.centerXAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderErrorImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderErrorImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            placeholderErrorLabel.centerXAnchor.constraint(equalTo: placeholderErrorImage.centerXAnchor),
            placeholderErrorLabel.topAnchor.constraint(equalTo: placeholderErrorImage.bottomAnchor, constant: 8)
        ])
        
        placeholderImage.isHidden = true
        placeholderLabel.isHidden = true
        placeholderErrorImage.isHidden = true
        placeholderErrorLabel.isHidden = true
    }
    
    private func makeHeaderStack() -> UIStackView {
        let hStack = UIStackView()
        
        hStack.axis = .horizontal
        hStack.distribution = .equalSpacing
        hStack.addArrangedSubview(titleLabel)
        hStack.addArrangedSubview(datePicker)
        
        let vStack = UIStackView()
        
        vStack.axis = .vertical
        vStack.spacing = 8
        vStack.addArrangedSubview(hStack)
        vStack.addArrangedSubview(searchField)
        return vStack
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let trackerCell = collectionView
            .dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell
        else {
            preconditionFailure("Failed to cast UICollectionViewCell as TrackerCollectionViewCell")
        }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let isCompleted = completedRecords.contains { isMatchRecord(model: $0, with: tracker.id) }
        let completedDays = completedRecords.filter { $0.trackerID == tracker.id }.count
        
        trackerCell.delegate = self
        trackerCell.configure(model: tracker, at: indexPath, isCompleted: isCompleted, completedDays: completedDays)
        
        return trackerCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let trackerHeader = collectionView
            .dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerCollectionViewHeader.identifier, for: indexPath) as? TrackerCollectionViewHeader
        else {
            preconditionFailure("Failed to cast UICollectionReusableView as TrackerCollectionViewHeader")
        }
        trackerHeader.configure(model: visibleCategories[indexPath.section])
        return trackerHeader
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - widthParameters.widthInsets
        let cellWidth = availableWidth / CGFloat(widthParameters.cellsNumber)
        return CGSize(width: cellWidth, height: 132)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: widthParameters.leftInset, bottom: 8, right: widthParameters.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        let targetSize = CGSize(width: collectionView.bounds.width, height: 42)
        
        return headerView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .required)
    }
}

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    
    func finishedTracker(with id: UUID, at indexPath: IndexPath) {
        guard selectedDate <= Date() else {
            return
        }
        completedRecords.append(TrackerRecordStruct(trackerID: id, completionDate: selectedDate))
        trackerCollection.reloadItems(at: [indexPath])
    }
    
    func unfinishedTracker(with id: UUID, at indexPath: IndexPath) {
        completedRecords.removeAll { isMatchRecord(model: $0, with: id) }
        trackerCollection.reloadItems(at: [indexPath])
    }
}

private let mockCategory: Array<String> = [
    "Важное",
    "Радостные мелочи",
    "Самочувствие",
    "Внимательность",
    "Спорт"
]

extension TrackersViewController: CreateTrackerViewControllerDelegate {
    
    func didCreateNewTracker(model: TrackerStruct) {
        let categoryNumber = Int.random(in: 0..<mockCategory.count)
        categories.append(
            TrackerCategoryStruct(
                title: mockCategory[categoryNumber],
                trackers: [model]
            )
        )
        didChangeSelectedDate()
        dismiss(animated: true)
    }
}

private extension TrackersViewController {
    
    @objc func didChangeSelectedDate() {
        presentedViewController?.dismiss(animated: false)
        selectedDate = datePicker.date
        didChangeSearchText()
    }
    
    @objc func didChangeSearchText() {
        updateVisibleTrackers()
        guard let searchText = searchField.text,
              !searchText.isEmpty
        else {
            return
        }
        var searchedCategories: Array<TrackerCategoryStruct> = []
        for category in visibleCategories {
            var searchedTrackers: Array<TrackerStruct> = []
            
            for tracker in category.trackers {
                if tracker.name.localizedCaseInsensitiveContains(searchText) {
                    searchedTrackers.append(tracker)
                }
            }
            if !searchedTrackers.isEmpty {
                searchedCategories.append(TrackerCategoryStruct(title: category.title, trackers: searchedTrackers))
            }
        }
        visibleCategories = searchedCategories
        visibleCategories.isEmpty ? showErrorPlaceholder() : hideErrorPlaceholder()
        hidePlaceholder()
        trackerCollection.reloadData()
    }
    
    func updateVisibleTrackers() {
        visibleCategories = []
        
        for category in categories {
            var visibleTrackers: Array<TrackerStruct> = []
            
            for tracker in category.trackers {
                guard let weekDay = WeekDays(rawValue: calculateWeekDayNumber(for: selectedDate)),
                      tracker.schedule.contains(weekDay)
                else {
                    continue
                }
                visibleTrackers.append(tracker)
            }
            if !visibleTrackers.isEmpty {
                visibleCategories.append(TrackerCategoryStruct(title: category.title, trackers: visibleTrackers))
            }
        }
        visibleCategories.isEmpty ? showPlaceholder() : hidePlaceholder()
        hideErrorPlaceholder()
        trackerCollection.reloadData()
    }
    
    func calculateWeekDayNumber(for date: Date) -> Int {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let weekDay = calendar.component(.weekday, from: date)
        let daysWeek = 7
        return (weekDay - calendar.firstWeekday + daysWeek) % daysWeek + 1
    }
    
    func showPlaceholder() {
        placeholderImage.isHidden = false
        placeholderLabel.isHidden = false
    }
    
    func hidePlaceholder() {
        placeholderImage.isHidden = true
        placeholderLabel.isHidden = true
    }
    
    func showErrorPlaceholder() {
        placeholderErrorImage.isHidden = false
        placeholderErrorLabel.isHidden = false
    }
    
    func hideErrorPlaceholder() {
        placeholderErrorImage.isHidden = true
        placeholderErrorLabel.isHidden = true
    }
}
