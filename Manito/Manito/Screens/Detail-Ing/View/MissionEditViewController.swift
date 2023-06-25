//
//  MissionEditViewController.swift
//  Manito
//
//  Created by Mingwan Choi on 2023/06/19.
//

import UIKit

import SnapKit

protocol MissionEditDelegate: AnyObject {
    func didChangeMission(mission: String)
}

final class MissionEditViewController: BaseViewController {
    
    // MARK: - property
    
    let mission: String
    let roomId: String
    private let missionEditService: MissionEditAPI = MissionEditAPI(apiService: APIService())
    private weak var delegate: MissionEditDelegate?
    
    // MARK: - component
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = CACornerMask(arrayLiteral: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        view.backgroundColor = .darkGrey004
        return view
    }()
    private lazy var missionTextField: UITextField = {
        let textField = UITextField()
        let attributes = [
            NSAttributedString.Key.font : UIFont.font(.regular, ofSize: 18)
        ]
        textField.backgroundColor = .darkGrey002
        textField.attributedPlaceholder = NSAttributedString(string: self.mission, attributes:attributes)
        textField.font = .font(.regular, ofSize: 18)
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.cgColor
        textField.textAlignment = .center
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.becomeFirstResponder()
        textField.delegate = self
        return textField
    }()
    private let missionMaxLengthLabel: UILabel = {
        let label = UILabel()
        label.text = "0/18"
        label.font = .font(.regular, ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    // MARK: - init
    
    init(mission: String, roomId: String) {
        self.mission = mission
        self.roomId = roomId
        super.init()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupGesture()
        self.setupNotificationCenter()
    }
    
    // MARK: - override
    
    override func configureUI() {
        super.configureUI()
        self.view.backgroundColor = .darkGrey001.withAlphaComponent(0.5)
    }
    
    override func setupLayout() {
        self.view.addSubview(self.backgroundView)
        self.backgroundView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(-5)
            $0.height.equalTo(120)
        }
        
        self.backgroundView.addSubview(self.missionTextField)
        self.missionTextField.snp.makeConstraints {
            $0.top.equalToSuperview().inset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(60)
        }
        
        self.backgroundView.addSubview(self.missionMaxLengthLabel)
        self.missionMaxLengthLabel.snp.makeConstraints {
            $0.top.equalTo(self.missionTextField.snp.bottom).offset(4)
            $0.trailing.equalTo(self.missionTextField.snp.trailing)
        }
    }
    
    // MARK: - func
    
    func setDelegate(_ delegate: DetailingViewController) {
        self.delegate = delegate
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    private func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func didChangedTextField(_ text: String) {
        guard !text.isEmpty else {
            self.dismiss(animated: true)
            return
        }
        self.makeRequestAlert(title: TextLiteral.missionEditViewControllerChangeMissionAlertTitle,
                              message: TextLiteral.missionEditViewControllerChangeMissionAlertMessage,
                              okTitle: TextLiteral.change,
                              okStyle: .default,
                              okAction: { [weak self] _ in
            guard let missionText = self?.missionTextField.text else { return }
            self?.patchEditMission(mission: missionText) { result in
                switch result {
                case .success(let mission):
                    DispatchQueue.main.async {
                        self?.delegate?.didChangeMission(mission: mission)
                        self?.dismiss(animated: true)
                    }
                case .failure:
                    print("error")
                }
            }
        })
    }
    
    // MARK: - selector
    
    @objc
    private func dismissViewController() {
        self.dismiss(animated: true)
    }
    
    @objc private func keyboardWillShow(notification:NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.2, animations: {
                self.backgroundView.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height + 30)
            })
        }
    }
    
    @objc private func keyboardWillHide(notification:NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundView.transform = .identity
        })
    }
    
    // MARK: - network
    
    private func patchEditMission(mission: String, completionHandler: @escaping ((Result<String, NetworkError>) -> Void)) {
        Task {
            do {
                let data = try await self.missionEditService.patchEditMission(roomId: self.roomId,
                                                                              body: MissionDTO(mission: mission))
                if let data {
                    completionHandler(.success(data.mission))
                } else {
                    completionHandler(.failure(.unknownError))
                }
            }
        }
    }
}

extension MissionEditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.missionTextField.endEditing(true)
        guard let text = textField.text else { return true }
        self.didChangedTextField(text)
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if text.count > 18 {
            let endIndex = text.index(text.startIndex, offsetBy: 18)
            let fixedText = text[text.startIndex..<endIndex]
            textField.text = fixedText + " "
            
            DispatchQueue.main.async {
                self.missionTextField.text = String(fixedText)
            }
        }
        guard text.count <= 18 else { return }
        self.missionMaxLengthLabel.text = "\(text.count)/18"
    }
}
