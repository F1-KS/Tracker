import UIKit

protocol ConfigureScheduleViewControllerDelegate: AnyObject {
    func didConfigure(schedule: Set<WeekDays>)
}

final class ConfigureScheduleViewController: UIViewController {

    private let switchTable: UITableView = {
        let table = UITableView(frame: .zero)

        table.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.identifier)
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.isScrollEnabled = false
        table.layer.masksToBounds = true
        table.layer.cornerRadius = 16
        table.heightAnchor.constraint(equalToConstant: 525).isActive = true
        return table
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .custom)

        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "ypGray")
        button.isEnabled = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        return button
    }()

    private var schedule: Set<WeekDays> = []
    private var switches: Array<SwitchOptions> = []

    weak var delegate: ConfigureScheduleViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        switchTable.dataSource = self
        switchTable.delegate = self

        appendSwitches()
        setupNavigationBar()
        makeViewLayout()
    }

    @objc private func didTapDoneButton() {
        delegate?.didConfigure(schedule: schedule)
    }

    private func appendSwitches() {
        switches.append(contentsOf: [
            SwitchOptions(weekDays: .monday, name: "Понедельник", isOn: schedule.contains(.monday)),
            SwitchOptions(weekDays: .tuesday, name: "Вторник", isOn: schedule.contains(.tuesday)),
            SwitchOptions(weekDays: .wednesday, name: "Среда", isOn: schedule.contains(.wednesday)),
            SwitchOptions(weekDays: .thursday, name: "Четверг", isOn: schedule.contains(.thursday)),
            SwitchOptions(weekDays: .friday, name: "Пятница", isOn: schedule.contains(.friday)),
            SwitchOptions(weekDays: .saturday, name: "Суббота", isOn: schedule.contains(.saturday)),
            SwitchOptions(weekDays: .sunday, name: "Воскресенье", isOn: schedule.contains(.sunday)),
            ])
    }

    private func setupNavigationBar() {
        let titleAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(named: "ypBlackDay"),
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes as [NSAttributedString.Key : Any]
        navigationController?.navigationBar.topItem?.title = "Расписание"
    }

    private func makeViewLayout() {
        view.backgroundColor = UIColor(named: "ypWhiteDay")
        view.addSubview(switchTable)
        view.addSubview(doneButton)
        switchTable.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            switchTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            switchTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            switchTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            ])
    }

    private func setDoneButtonState() {
        if schedule.isEmpty {
            doneButton.backgroundColor = UIColor(named: "ypGray")
            doneButton.isEnabled = false
        } else {
            doneButton.backgroundColor = UIColor(named: "ypBlackDay")
            doneButton.isEnabled = true
        }
    }
}

extension ConfigureScheduleViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return switches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let switchCell = tableView
            .dequeueReusableCell(withIdentifier: SwitchTableViewCell.identifier, for: indexPath) as? SwitchTableViewCell
            else {
            preconditionFailure("Type cast error")
        }
        switchCell.delegate = self
        switchCell.configure(options: switches[indexPath.row])

        if indexPath.row == switches.count - 1 { // hide separator for last cell
            let centerX = switchCell.bounds.width / 2
            switchCell.separatorInset = UIEdgeInsets(top: 0, left: centerX, bottom: 0, right: centerX)
        }
        return switchCell
    }
}

extension ConfigureScheduleViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ConfigureScheduleViewController: SwitchTableViewCellDelegate {

    func didChangeState(isOn: Bool, for weekDays: WeekDays) {
        if isOn {
            schedule.insert(weekDays)
        } else {
            schedule.remove(weekDays)
        }
        setDoneButtonState()
    }
}
