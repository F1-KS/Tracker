import UIKit

final class SettingTableViewCell: UITableViewCell {
    
    static let identifier = "SettingTableViewCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = UIColor(named: "ypBlackDay")
        label.font = .systemFont(ofSize: 17, weight: .regular)
        
        return label
    }()
    
    private let accessoryImage: UIImageView = {
        return UIImageView(image: UIImage(named: "Icon"))
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeViewLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(options: SettingOptions) {
        nameLabel.text = options.name
    }
    
    //FIXMI: - на sprint_15 проверить весь проект и разделить UI элементы и констрейнты на два разных метода, например, addSubviews() и setupConstraints().
    
    private func makeViewLayout() {
        contentView.backgroundColor = UIColor(named: "ypBackgroundDay")
        contentView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        contentView.addSubview(nameLabel)
        contentView.addSubview(accessoryImage)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        accessoryImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            accessoryImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            accessoryImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
