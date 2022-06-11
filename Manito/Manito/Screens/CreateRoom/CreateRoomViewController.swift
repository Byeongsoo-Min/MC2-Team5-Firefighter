//
//  CreateRoomViewController.swift
//  Manito
//
//  Created by SHIN YOON AH on 2022/06/09.
//

import UIKit
import SnapKit

class CreateRoomViewController: BaseViewController {

    // MARK: - Property
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "방 생성하기"
        label.font = .font(.regular, ofSize: 34)
        return label
    }()
    
    lazy var closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        btn.tintColor = .lightGray
        btn.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        return btn
    }()
    
    // 방 제목입력 뷰
    lazy var createView : UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    lazy var roomsNameTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor.subBackgroundGrey
        let attributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont(name: AppFontName.regular.rawValue, size: 18)!
        ]
        tf.attributedPlaceholder = NSAttributedString(string: "방 이름을 적어주세요", attributes:attributes)
        tf.layer.cornerRadius = 10
        tf.layer.masksToBounds = true
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.textAlignment = .center
        return tf
    }()
    
    lazy var roomsTextLimit : UILabel = {
        let label = UILabel()
        label.text = "0/8"
        label.font = .font(.regular, ofSize: 20)
        return label
    }()
    
    lazy var nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("다음", for: .normal)
        btn.titleLabel?.font = .font(.regular, ofSize: 20)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.mainRed
        btn.layer.cornerRadius = 30
        btn.addTarget(self, action: #selector(didTapnextButoon), for: .touchUpInside)
        return btn
    }()
    
    // 방 인원수 입력 뷰
    lazy var personView : UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()
    
    let peronsViewLabel: UILabel = {
        let label = UILabel()
        label.text = "최대 참여 인원을 설정해 주세요"
        label.font = .font(.regular, ofSize: 18)
        return label
    }()
    
    let backView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.strokeYello.cgColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func render() {

        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(66)
            $0.left.equalTo(view).inset(16)
        }
        
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(9)
            $0.right.equalTo(view).inset(16)
            $0.width.height.equalTo(44)
        }

        view.addSubview(createView)
        createView.snp.makeConstraints {
            $0.top.equalTo(titleLabel).inset(66)
            $0.left.right.equalTo(view).inset(16)
            $0.bottom.equalTo(view).inset(200)
        }
        
        configureRoomsTitle()
        
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints {
            $0.left.right.equalTo(view).inset(16)
            $0.bottom.equalTo(view).inset(57)
            $0.height.equalTo(60)
        }
        
        view.addSubview(personView)
        personView.snp.makeConstraints {
            $0.top.equalTo(titleLabel).inset(66)
            $0.left.right.equalTo(view).inset(16)
            $0.bottom.equalTo(view).inset(200)
        }
        
        configureRoomsPerson()
    }
    
    override func configUI() {
        super.configUI()
    }
    
    // MARK: - Selectors
    @objc func didTapCloseButton(){
        print("ttaapp")
    }
    
    @objc func didTapnextButoon(){
        print("tap")
    }
    

    // MARK: - Configure

    func configureRoomsTitle(){

        createView.addSubview(roomsNameTextField)
        roomsNameTextField.snp.makeConstraints {
            $0.top.equalTo(createView)
            $0.left.right.equalTo(createView)
            $0.height.equalTo(60)
        }
        
        createView.addSubview(roomsTextLimit)
        roomsTextLimit.snp.makeConstraints {
            $0.top.equalTo(roomsNameTextField.snp.bottom).inset(-10)
            $0.right.equalTo(createView)
        }
    }
    
    func configureRoomsPerson(){
        
        personView.addSubview(peronsViewLabel)
        peronsViewLabel.snp.makeConstraints {
            $0.top.equalTo(personView)
            $0.left.right.equalTo(personView)
            
        }
        
        personView.addSubview(backView)
        backView.snp.makeConstraints {
            $0.top.equalTo(peronsViewLabel.snp.bottom).inset(-36)
            $0.left.right.equalTo(personView)
            $0.height.equalTo(140)
        }
        
        
        
    }
    
    // MARK: - Navigation


}
