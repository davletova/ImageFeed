//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 16.05.2023.
//

import UIKit
import Kingfisher

class ProfileViewController: UIViewController {
    var profile: Profile?
    
    private var profileImageServiceObserver: NSObjectProtocol?
    private let noneAvatarImage = UIImage(named: "person.crop.circle.fill") ?? UIImage(systemName: "person.crop.circle.fill")
    
    @IBOutlet var userName: UILabel!
    @IBOutlet var userLogin: UILabel!
    @IBOutlet var userDescription: UILabel!
    
    @IBOutlet var userAvatar: UIImageView!
    @IBOutlet var logout: UIButton!
    
    @objc private func didLogout() { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.DidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        
        profile = ProfileService.shared.profile
        
        view.backgroundColor = UIColor(named: "YP Black")
        
        addUserAvatar()
        
        addUserName()
        
        addUserLogin()
        
        addUserDescription()
        
        addButtonLogout()
        
        updateAvatar()
    }
}

extension ProfileViewController {
    private func addUserAvatar() {
        let imageView = UIImageView(image: noneAvatarImage)
        imageView.tintColor = .gray
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        
        userAvatar = imageView
    }
    
    private func addUserName() {
        let label = UILabel()
        
        label.text = profile?.name ?? ""
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 23.0)
        
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)
        
        label.topAnchor.constraint(equalTo: userAvatar.bottomAnchor, constant: 8).isActive = true
        label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        
        userName = label
    }
    
    private func addUserLogin() {
        let label = UILabel()
        label.text = profile?.login ?? ""
        label.textColor = UIColor(named: "YP Gray") ?? .gray
        label.font = UIFont.boldSystemFont(ofSize: 13.0)
        
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)
        
        label.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8).isActive = true
        label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        
        userLogin = label
    }
    
    private func addUserDescription() {
        let label = UILabel()
        label.text = profile?.description ?? ""
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 13.0)
        
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)
        
        label.topAnchor.constraint(equalTo: userLogin.bottomAnchor, constant: 8).isActive = true
        label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
            
        userDescription = label
    }
    
    private func addButtonLogout() {
        let buttonImage = UIImage(named: "logout") ?? UIImage(systemName: "ipad.and.arrow.forward")!
    
        let button = UIButton.systemButton(with: buttonImage, target: nil, action: #selector(didLogout))
        button.tintColor = UIColor(named: "YP Red") ?? .red
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(button)
        
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        button.centerYAnchor.constraint(equalTo: userAvatar.centerYAnchor).isActive = true
        
        logout = button
    }
}

extension ProfileViewController {
    private func updateAvatar() {
        let profileImageURL = ProfileImageService.shared.avatarURL
        
        guard let url = URL(string: profileImageURL) else { return }
        
        let processor = RoundCornerImageProcessor(cornerRadius: userAvatar.frame.size.width / 2)
        
        userAvatar.kf.setImage(with: url,
                               placeholder: noneAvatarImage,
                               options: [.processor(processor)]
                               
        ) { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                self.userAvatar.image = self.noneAvatarImage
                print(error)
            }
        }
    }
}
