//
//  KeyboardView.swift
//  CustomKeyboard
//
//  Created by BH on 2022/07/12.
//

import UIKit

protocol KeyboardViewDismissible: NSObject {
    
    func dismissKeyboardViewController(reviewContents: String)
    
}

final class KeyboardView: UIView {

    // MARK: - UIProperties

    private lazy var keyboardKeyHeight = (self.bounds.height *
                                          Style.keyboardContentsViewRatio /
                                          Style.numberOfStackView *
                                          Style.keyboardKeyHeightRatio)
    private lazy var keyboardKeyWidth = self.bounds.width * Style.keyboardKeyWidthRatio

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = Text.textLabelPlaceHolder
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.numberOfLines = .zero
        return label
    }()

    private lazy var keyboardContentsView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()

    private lazy var keyboardFirstLineStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private lazy var keyboardSecondLineStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private lazy var keyboardThirdLineStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private lazy var shiftKeyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray2
        button.layer.cornerRadius = Style.keyboardKeyCornerRaidus

        button.setImage(Style.shiftKeyImage, for: .normal)
        button.setImage(Style.shiftFilledKeyImage, for: .selected)
        button.tintColor = .black

        button.addTarget(
            nil,
            action: #selector(shiftButtonTouched(_:)),
            for: .touchUpInside
        )

        button.heightAnchor.constraint(equalToConstant: keyboardKeyHeight) .isActive  = true
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        return button
    }()

    private lazy var deleteKeyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray2
        button.layer.cornerRadius = Style.keyboardKeyCornerRaidus
        button.setImage(Style.deleteKeyImage, for: .normal)
        button.tintColor = .black
        
        button.addTarget(
            nil,
            action: #selector(deleteKeyButtonTouched(_:)),
            for: .touchUpInside
        )
        
        button.heightAnchor.constraint(equalToConstant: keyboardKeyHeight) .isActive  = true
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        return button
    }()

    private lazy var numberKeyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray2
        button.layer.cornerRadius = Style.keyboardKeyCornerRaidus
        button.setTitleColor(.black, for: .normal)
        button.setTitle(Text.functionKey, for: .normal)

        button.heightAnchor.constraint(equalToConstant: keyboardKeyHeight).isActive  = true
        button.widthAnchor.constraint(
            equalToConstant: self.bounds.width * Style.functionKeyWidthRatio
        ).isActive = true
        
        return button
    }()

    private lazy var spaceKeyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.cornerRadius = Style.keyboardKeyCornerRaidus
        button.setTitleColor(.black, for: .normal)
        button.setTitle(Text.spaceKey, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
        
        button.addTarget(nil, action: #selector(spaceKeyButtonTouched(_:)), for: .touchUpInside)

        button.heightAnchor.constraint(equalToConstant: keyboardKeyHeight) .isActive  = true
        button.widthAnchor.constraint(
            equalToConstant: self.bounds.width * Style.spaceKeyWdithRatio
        ).isActive = true

        return button
    }()

    private lazy var returnKeyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray2
        button.layer.cornerRadius = Style.keyboardKeyCornerRaidus
        button.setTitleColor(.black, for: .normal)
        button.setImage(Style.returnKeyImage, for: .normal)
        button.tintColor = .black
        
        button.addTarget(nil, action: #selector(returnButtonTouched(_:)), for: .touchUpInside)

        button.heightAnchor
            .constraint(equalToConstant:keyboardKeyHeight).isActive  = true
        button.widthAnchor.constraint(
            equalToConstant: self.bounds.width * Style.functionKeyWidthRatio
        ).isActive = true
        return button
    }()

    private lazy var keyboardFourthLineStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = Style.basicPadding
        return stackView
    }()
    
    // MARK: - Properties

    private var toBeConvertedButtons = [UIButton]()
    weak var delegate: KeyboardViewDismissible?
    let keyboardAutomata = KeyboardAutomata()

    // MARK: - LifeCycles

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    @available(*, unavailable, message: "This initializer is not available.")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
    }

    // MARK: - objc Methods

    @objc func keyboardButtonTouched(_ sender: UIButton) {
        guard let contents = sender.titleLabel?.text else {
            return
        }
        keyboardAutomata.insert(contents)
        textLabel.text = keyboardAutomata.outputToDisplay
    }

    @objc func shiftButtonTouched(_ sender: UIButton) {
        sender.isSelected.toggle()
        toBeConvertedButtons.forEach {
            $0.isSelected.toggle()
        }
    }
    
    @objc func spaceKeyButtonTouched(_ sender: UIButton) {
        keyboardAutomata.space()
        textLabel.text = keyboardAutomata.outputToDisplay
    }
    
    @objc func deleteKeyButtonTouched(_ sender: UIButton) {
        keyboardAutomata.delete()
        textLabel.text = keyboardAutomata.outputToDisplay
    }
    
    @objc func returnButtonTouched(_ sender: UIButton) {
        guard let contents = textLabel.text else {
            return
        }
        delegate?.dismissKeyboardViewController(reviewContents: contents)
        keyboardAutomata.reset()
    }

}

// MARK: - Keyboard button setting methods

extension KeyboardView {

    private func insertKeyboardKeys() {
        for char in "ㅂㅈㄷㄱㅅㅛㅕㅑㅐㅔ" {
            let key : UIButton!
            key = makeKeyboardButtons(contents: "\(char)")
            keyboardFirstLineStackView.addArrangedSubview(key)
        }

        for char in "ㅁㄴㅇㄹㅎㅗㅓㅏㅣ" {
            let key = makeKeyboardButtons(contents: "\(char)")
            keyboardSecondLineStackView.addArrangedSubview(key)
        }

        for char in "ㅋㅌㅊㅍㅠㅜㅡ" {
            let key = makeKeyboardButtons(contents: "\(char)")
            keyboardThirdLineStackView.addArrangedSubview(key)
        }

        for i in [numberKeyButton, spaceKeyButton, returnKeyButton] {
            keyboardFourthLineStackView.addArrangedSubview(i)
        }
    }

    private func checkToBeConverted(contents: String) -> Bool {
        let toBeConvertedToDoubleCharacter = ["ㅂ", "ㅈ", "ㄷ", "ㄱ", "ㅅ", "ㅐ", "ㅔ"]
        let isDoubleCharacter = toBeConvertedToDoubleCharacter.contains(contents)

        return isDoubleCharacter
    }

    private func convertToDouble(contents: String) -> String {
        switch contents {
        case "ㅂ":
            return "ㅃ"
        case "ㅈ":
            return "ㅉ"
        case "ㄷ":
            return "ㄸ"
        case "ㄱ":
            return "ㄲ"
        case "ㅅ":
            return "ㅆ"
        case "ㅐ":
            return "ㅒ"
        case "ㅔ":
            return "ㅖ"
        default:
            return contents
        }
    }

    private func makeKeyboardButtons(contents: String) -> UIButton {
        let button = UIButton()
        button.setTitle(contents, for: .normal)
        if checkToBeConverted(contents: contents) {
            let doubleCharacter = convertToDouble(contents: contents)
            button.setTitle(doubleCharacter, for: .selected)
            button.setTitle(doubleCharacter, for: Style.selectedAndHighlighted)
            toBeConvertedButtons.append(button)
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(nil, action: #selector(keyboardButtonTouched(_:)), for: .touchUpInside)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title3)
        button.layer.cornerRadius = Style.keyboardKeyCornerRaidus

        button.heightAnchor.constraint(equalToConstant: keyboardKeyHeight) .isActive  = true
        button.widthAnchor.constraint(equalToConstant: keyboardKeyWidth).isActive = true

        return button
    }
}

// MARK: - View setting methods

extension KeyboardView {

    private func setupView() {
        self.backgroundColor = .white
        insertKeyboardKeys()

        [textLabel,
         keyboardContentsView].forEach {
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        [keyboardFirstLineStackView,
         keyboardSecondLineStackView,
         keyboardThirdLineStackView,
         keyboardFourthLineStackView,
         shiftKeyButton,
         deleteKeyButton].forEach {
            keyboardContentsView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    private func setupConstraints() {
        setupConstraintsOfTextLabel()
        setupConstraintsOfKeyboardContentsView()
        setupConstraintsOfShiftButton()
        setupConstraintsOfDeleteButton()
        setupConstraintsOfKeyboardFirstLineStackView()
        setupConstraintsOfKeyboardSecondLineStackView()
        setupConstraintsOfKeyboardThirdLineStackView()
        setupConstraintsOfKeyboardFourthLineStackView()
    }

    private func setupConstraintsOfTextLabel() {
        let textLabelHeightAutoLayout = textLabel.heightAnchor.constraint(
            equalToConstant: Style.textLabelHeight
        )
        textLabelHeightAutoLayout.priority = Style.textLabelPriority

        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.leadingAnchor,
                constant: Style.basicPadding
            ),
            textLabel.trailingAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.trailingAnchor,
                constant: -Style.basicPadding
            ),
            textLabel.topAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.topAnchor,
                constant: Style.basicPadding
            ),
            textLabel.bottomAnchor.constraint(
                lessThanOrEqualTo: keyboardContentsView.safeAreaLayoutGuide.topAnchor,
                constant: -Style.basicPadding
            ),
            textLabelHeightAutoLayout
        ])
    }

    private func setupConstraintsOfKeyboardContentsView() {
        NSLayoutConstraint.activate([
            keyboardContentsView.leadingAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.leadingAnchor
            ),
            keyboardContentsView.trailingAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.trailingAnchor
            ),
            keyboardContentsView.bottomAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.bottomAnchor
            ),
            keyboardContentsView.heightAnchor.constraint(
                equalToConstant: self.frame.height * Style.keyboardContentsViewRatio
            )
        ])
    }

    private func setupConstraintsOfShiftButton() {
        NSLayoutConstraint.activate([
            shiftKeyButton.leadingAnchor.constraint(
                equalTo: keyboardFirstLineStackView.safeAreaLayoutGuide.leadingAnchor
            ),
            shiftKeyButton.centerYAnchor.constraint(
                equalTo: keyboardThirdLineStackView.safeAreaLayoutGuide.centerYAnchor
            )
        ])
    }

    private func setupConstraintsOfDeleteButton() {
        NSLayoutConstraint.activate([
            deleteKeyButton.trailingAnchor.constraint(
                equalTo: keyboardFirstLineStackView.safeAreaLayoutGuide.trailingAnchor
            ),
            deleteKeyButton.centerYAnchor.constraint(
                equalTo: keyboardThirdLineStackView.safeAreaLayoutGuide.centerYAnchor
            )
        ])
    }

    private func setupConstraintsOfKeyboardFirstLineStackView() {
        NSLayoutConstraint.activate([
            keyboardFirstLineStackView.leadingAnchor.constraint(
                equalTo: keyboardContentsView.safeAreaLayoutGuide.leadingAnchor,
                constant: Style.keyboardPadding
            ),
            keyboardFirstLineStackView.trailingAnchor.constraint(
                equalTo: keyboardContentsView.safeAreaLayoutGuide.trailingAnchor,
                constant: -Style.keyboardPadding
            ),
            keyboardFirstLineStackView.topAnchor.constraint(
                equalTo: keyboardContentsView.safeAreaLayoutGuide.topAnchor
            ),
            keyboardFirstLineStackView.heightAnchor.constraint(
                equalTo: keyboardContentsView.safeAreaLayoutGuide.heightAnchor,
                multiplier: Style.horizontalStackViewHeightRatio
            )
        ])
    }

    private func setupConstraintsOfKeyboardSecondLineStackView() {
        NSLayoutConstraint.activate([
            keyboardSecondLineStackView.widthAnchor.constraint(
                equalTo: keyboardContentsView.safeAreaLayoutGuide.widthAnchor,
                multiplier: Style.secondStackViewWidthRatio
            ),
            keyboardSecondLineStackView.centerXAnchor.constraint(
                equalTo: keyboardContentsView.safeAreaLayoutGuide.centerXAnchor
            ),
            keyboardSecondLineStackView.topAnchor.constraint(
                equalTo: keyboardFirstLineStackView.safeAreaLayoutGuide.bottomAnchor
            ),
            keyboardSecondLineStackView.heightAnchor.constraint(
                equalTo: keyboardContentsView.safeAreaLayoutGuide.heightAnchor,
                multiplier: Style.horizontalStackViewHeightRatio
            )
        ])
    }

    private func setupConstraintsOfKeyboardThirdLineStackView() {
        NSLayoutConstraint.activate([
            keyboardThirdLineStackView.centerXAnchor.constraint(
                equalTo: keyboardContentsView.safeAreaLayoutGuide.centerXAnchor
            ),
            keyboardThirdLineStackView.topAnchor.constraint(
                equalTo: keyboardSecondLineStackView.safeAreaLayoutGuide.bottomAnchor
            ),
            keyboardThirdLineStackView.heightAnchor.constraint(
                equalTo: keyboardContentsView.safeAreaLayoutGuide.heightAnchor,
                multiplier: Style.horizontalStackViewHeightRatio
            ),
            keyboardThirdLineStackView.leadingAnchor.constraint(
                lessThanOrEqualTo: shiftKeyButton.safeAreaLayoutGuide.trailingAnchor,
                constant: Style.basicPadding
            ),
            keyboardThirdLineStackView.trailingAnchor.constraint(
                lessThanOrEqualTo: deleteKeyButton.safeAreaLayoutGuide.leadingAnchor,
                constant: -Style.basicPadding
            ),
        ])
    }

    private func setupConstraintsOfKeyboardFourthLineStackView() {
        NSLayoutConstraint.activate([
            keyboardFourthLineStackView.leadingAnchor.constraint(
                equalTo: keyboardFirstLineStackView.safeAreaLayoutGuide.leadingAnchor
            ),
            keyboardFourthLineStackView.trailingAnchor.constraint(
                equalTo: keyboardFirstLineStackView.safeAreaLayoutGuide.trailingAnchor
            ),
            keyboardFourthLineStackView.topAnchor.constraint(
                equalTo: keyboardThirdLineStackView.safeAreaLayoutGuide.bottomAnchor
            ),
            keyboardFourthLineStackView.heightAnchor.constraint(
                equalTo: keyboardContentsView.safeAreaLayoutGuide.heightAnchor,
                multiplier: Style.horizontalStackViewHeightRatio
            )
        ])
    }

}

// MARK: - NameSpaces

extension KeyboardView {

    private enum Text {
        static let textLabelPlaceHolder: String = "리뷰를 작성해 주세요.😆"
        static let functionKey: String = "123"
        static let spaceKey: String = "스페이스"
    }

    private enum Style {
        static let shiftKeyImage: UIImage? = .init(systemName: "shift")
        static let shiftFilledKeyImage: UIImage? = .init(systemName: "shift.fill")
        static let deleteKeyImage: UIImage? = .init(systemName: "delete.left")
        static let returnKeyImage: UIImage? = .init(systemName: "return")
        
        static let selectedAndHighlighted: UIControl.State = .init(
            rawValue: UIControl.State.selected.rawValue | UIControl.State.highlighted.rawValue
        )
        static let textLabelHeight: CGFloat = 30
        static let textLabelPriority: UILayoutPriority = .init(rawValue: 250)
        static let keyboardContentsViewRatio: Double = 0.3
        static let numberOfStackView: Double = 4.0
        static let keyboardKeyHeightRatio: Double = 0.8
        static let functionKeyWidthRatio: Double = 0.24
        static let spaceKeyWdithRatio: Double = 0.43
        static let horizontalStackViewHeightRatio: Double = 0.25
        static let secondStackViewWidthRatio: Double = 0.9
        static let keyboardKeyWidthRatio: CGFloat = 0.085
        static let keyboardKeyCornerRaidus: CGFloat = 5
        static let keyboardPadding: CGFloat = 5
        static let basicPadding: CGFloat = 10
    }

}
