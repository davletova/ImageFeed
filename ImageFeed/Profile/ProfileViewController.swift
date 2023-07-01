//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 16.05.2023.
//

import UIKit
import Kingfisher
import WebKit

class ProfileViewController: UIViewController {
    var profile: Profile?
    
    private var animationLayers = Set<CALayer>()
    private let gradientChangeAnimation = CABasicAnimation()
    private let cornerRadiusForLabelGradient = 9
    private let gradientChangeAnimationKey = "locationsChange"
    
    private var profileImageServiceObserver: NSObjectProtocol?
    private let noneAvatarImage = UIImage(named: "person.crop.circle.fill") ?? UIImage(systemName: "person.crop.circle.fill")
    
    @IBOutlet var userName: UILabel!
    @IBOutlet var userLogin: UILabel!
    @IBOutlet var userDescription: UILabel!
    
    @IBOutlet var userAvatar: UIImageView!
    @IBOutlet var logout: UIButton!
    
    @objc private func didLogout() {
        OAuth2TokenStorage.removeAccessToken()
        CookieCleaner.clean()
        
        goToSplash()
    }
    
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
        
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        
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
        
        let userAvatarFrame = CGRect(x: 0, y: 0, width: 70, height: 70)
        
        let userAvatarGradient = createGradient(frame: userAvatarFrame, cornerRadius: 35)
        
        animationLayers.insert(userAvatarGradient)
        userAvatar.layer.addSublayer(userAvatarGradient)
        userAvatarGradient.add(gradientChangeAnimation, forKey: gradientChangeAnimationKey)
    }
    
    private func addUserName() {
        let label = UILabel()
        
        label.text =  ""
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 23.0)
        
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)
        
        label.topAnchor.constraint(equalTo: userAvatar.bottomAnchor, constant: 8).isActive = true
        label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        
        userName = label
        
        let userNameGradientFrame = CGRect(x: 0, y: 0, width: 200, height: 20)
        let userNameGradient = createGradient(frame: userNameGradientFrame, cornerRadius: cornerRadiusForLabelGradient)
        
        animationLayers.insert(userNameGradient)
        userName.layer.addSublayer(userNameGradient)
        userNameGradient.add(gradientChangeAnimation, forKey: gradientChangeAnimationKey)
    }
    
    private func addUserLogin() {
        let label = UILabel()
        
        label.text = ""
        label.textColor = UIColor(named: "YP Gray") ?? .gray
        label.font = UIFont.boldSystemFont(ofSize: 13.0)
        
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)
        
        label.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8).isActive = true
        label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        
        userLogin = label
        
        let userLoginGradientFrame = CGRect(x: 0, y: 25, width: 70, height: 20)
        let userLoginGradient = createGradient(frame: userLoginGradientFrame, cornerRadius: cornerRadiusForLabelGradient)
        
        animationLayers.insert(userLoginGradient)
        userLogin.layer.addSublayer(userLoginGradient)
        userLoginGradient.add(gradientChangeAnimation, forKey: gradientChangeAnimationKey)
    }
    
    private func addUserDescription() {
        let label = UILabel()
        label.text = ""
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 13.0)
        
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)
        
        label.topAnchor.constraint(equalTo: userLogin.bottomAnchor, constant: 8).isActive = true
        label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
            
        userDescription = label
        
        let userDescriptionGradientFrame = CGRect(x: 0, y: 50, width: 170, height: 20)
        let userDescriptionGradient = createGradient(frame: userDescriptionGradientFrame, cornerRadius: cornerRadiusForLabelGradient)
        
        animationLayers.insert(userDescriptionGradient)
        userDescription.layer.addSublayer(userDescriptionGradient)
        userDescriptionGradient.add(gradientChangeAnimation, forKey: gradientChangeAnimationKey)
       
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
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    for g in self.animationLayers {
                        g.removeFromSuperlayer()
                    }

                    self.userName.text = self.profile?.name ?? ""
                    self.userLogin.text = self.profile?.login ?? ""
                    self.userDescription.text = self.profile?.description ?? ""
                case .failure(let error):
                    self.userAvatar.image = self.noneAvatarImage
                    print(error)
                }
            }
        }
    }
    
    private func goToSplash() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let splashViewController = storyboard.instantiateInitialViewController() else {
            assertionFailure("Что-то пошло не так")
            return
        }
        
        splashViewController.modalPresentationStyle = .fullScreen
        self.present(splashViewController, animated: true)
    }
    
    private func createGradient(frame: CGRect, cornerRadius: Int) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = CGFloat(cornerRadius)
        gradient.masksToBounds = true
        
        return gradient
    }
}
