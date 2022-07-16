//
//  KeyboardView.swift
//  CustomKeyboard
//
//  Created by yc on 2022/07/12.
//

import UIKit

class KeyboardView: UIView {
    let viewModel: KeyboardViewModel
    
    var sejongState: SejongState = .writeInitialState
    var currentJungsung: Jungsung? = nil
    var currentLastJongsung: Jongsung? = nil
    var isShift = false
    
    let topLetterValues: [Any] = [
        Chosung.ㅂ,Chosung.ㅈ,Chosung.ㄷ,Chosung.ㄱ,Chosung.ㅅ,
        Jungsung.ㅛ,Jungsung.ㅕ,Jungsung.ㅑ,Jungsung.ㅐ,Jungsung.ㅔ
    ]
    let middleLetterValues:[Any] = [
        Chosung.ㅁ,Chosung.ㄴ,Chosung.ㅇ,Chosung.ㄹ,Chosung.ㅎ,
        Jungsung.ㅗ,Jungsung.ㅓ,Jungsung.ㅏ,Jungsung.ㅣ
    ]
    let lastLetterValues:[Any] = [
        Chosung.ㅋ,Chosung.ㅌ,Chosung.ㅊ,Chosung.ㅍ,
        Jungsung.ㅠ,Jungsung.ㅜ,Jungsung.ㅡ
    ]

    private lazy var shiftButton: UIButton = {
        let button = UIButton()
        button.setupUtilButton(
            "shift",
            target: self,
            action: #selector(didTapShift)
        )
        return button
    }()
    private lazy var spaceButton: UIButton = {
        let button = UIButton()
        button.setupUtilButton(
            "space",
            target: self,
            action: #selector(didTapSpace)
        )
        return button
    }()
    private lazy var returnButton: UIButton = {
        let button = UIButton()
        button.setupUtilButton(
            "return",
            target: self,
            action: #selector(didTapReturn)
        )
        return button
    }()
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setupUtilButton(
            "Back",
            target: self,
            action: #selector(didTapBack)
        )
        return button
    }()
    

    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 6.0
        configureButton(topLetterValues, stackView: stackView)
        return stackView
    }()
    private lazy var midStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 6.0
        
        configureButton(middleLetterValues, stackView: stackView)
        return stackView
    }()

    private lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 6.0
        configureButton(lastLetterValues, stackView: stackView)
        return stackView
    }()

    init(viewModel: KeyboardViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupLayout()
        
        //Binding
        bindShiftMode()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeShiftMode(_ bool: Bool) {
        topStackView
            .arrangedSubviews
            .compactMap {
                $0 as? KeyboardButton
            }
            .forEach {
                $0.isShift = bool
            }
    }
    
    func bindShiftMode() {
        viewModel.isShift.bind { isShift in
            self.isShift = isShift
            self.changeShiftMode(isShift)
        }
    }
    
}

// MARK: - @objc Methods
private extension KeyboardView {
    @objc func didTapKeyboardButton(_ sender: KeyboardButton) {
        let buffer = (sender.chosung, sender.jungsung, sender.jongsung)
        viewModel.didTapKeyboardButton(buffer: buffer)
    }
    
    @objc func didTapSpace() {
        viewModel.value.append(" ")
        sejongState = .writeInitialState
    }
    @objc func didTapShift() {
        debugPrint("didTapShift")
        isShift = !isShift
        viewModel.isShift.value = isShift
        changeShiftMode(isShift)
    }
    @objc func didTapReturn() {
        debugPrint("didTapReturn")
        viewModel.returnButtonTapped.value = true
    }
    @objc func didTapBack() {
        viewModel.value.unicodeScalars.removeLast()
    }
}

// MARK: - Methods
private extension KeyboardView {}

// MARK: - UI Methods
private extension KeyboardView {
    func setupLayout() {
        [
            topStackView,
            midStackView,
            bottomStackView,
            shiftButton,
            spaceButton,
            returnButton,
            backButton
        ].forEach {
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            topStackView.topAnchor.constraint(equalTo: self.topAnchor,constant: 8),
            topStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            midStackView.topAnchor.constraint(equalTo: topStackView.bottomAnchor,constant: 8),
            midStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            bottomStackView.topAnchor.constraint(equalTo: midStackView.bottomAnchor,constant: 8),
            bottomStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),

            shiftButton.leadingAnchor.constraint(equalTo: topStackView.leadingAnchor),
            shiftButton.topAnchor.constraint(equalTo: spaceButton.topAnchor),
            shiftButton.widthAnchor.constraint(lessThanOrEqualToConstant: 60.0),

            spaceButton.leadingAnchor.constraint(equalTo: shiftButton.trailingAnchor, constant: 6),
            spaceButton.topAnchor.constraint(equalTo: bottomStackView.bottomAnchor, constant: 10),
            spaceButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),

            returnButton.leadingAnchor.constraint(equalTo: spaceButton.trailingAnchor, constant: 6),
            returnButton.topAnchor.constraint(equalTo: spaceButton.topAnchor),
            returnButton.trailingAnchor.constraint(equalTo: topStackView.trailingAnchor),
            returnButton.widthAnchor.constraint(lessThanOrEqualToConstant: 60.0),
            backButton.topAnchor.constraint(equalTo: returnButton.bottomAnchor)
        ])
    }
    
    func configureButton(_ letters: [Any], stackView: UIStackView) {
        letters.forEach { letterValue in
            if let value = letterValue as? Chosung {
                let button = KeyboardButton(
                    type: .text,
                    text: value.description,
                    chosung: value,
                    jongsung: value.jongsung
                )
                button.addTarget(
                    self,
                    action: #selector(didTapKeyboardButton(_:)),
                    for: .touchUpInside
                )
                stackView.addArrangedSubview(button)
            }
            
            if let value = letterValue as? Jungsung {
                let button = KeyboardButton(
                    type: .text,
                    text: value.description,
                    jungsung: value
                )
                button.addTarget(
                    self,
                    action: #selector(didTapKeyboardButton(_:)),
                    for: .touchUpInside
                )
                stackView.addArrangedSubview(button)
            }
        }
    }
}
