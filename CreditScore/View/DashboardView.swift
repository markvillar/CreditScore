//
//  DashboardView.swift
//  CreditScore
//
//  Created by Mark on 31/10/2019.
//  Copyright © 2019 CreditScore. All rights reserved.
//

import UIKit

class DashboardView: UIViewController {
    
    //MARK: - Property declarations
    
    let circularShapeLayer = CAShapeLayer()
    let animationDuration: Double = 2
    
    var animationStartDate: Date?
    var displayLink: CADisplayLink?
    
    var dashboardViewModel: DashBoardViewModel? {
        didSet {
            maximumCreditScoreTextLabel.text = "out of \(String(format: "%.0f", dashboardViewModel?.maximumScore ?? 0))"
            scoreLabel.text = String(format:"%.0f", dashboardViewModel?.score ?? "0")
            setupDisplayLink()
            scoreUpdate()
        }
    }
    
    let creditScoreTextLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.text = "Your credit score is"
        textLabel.textAlignment = .center
        textLabel.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }()
    
    let scoreLabel: UILabel = {
        let score = UILabel()
        score.text = "0"
        score.textAlignment = .center
        score.font = UIFont.systemFont(ofSize: 85, weight: .thin)
        score.textColor = UIColor(named: "Yellow")
        score.translatesAutoresizingMaskIntoConstraints = false
        return score
    }()
    
    let maximumCreditScoreTextLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.text = "out of 0"
        textLabel.textAlignment = .center
        textLabel.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }()
    
    //MARK: - Method declarations
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
        setupNavigation()
        setupDoughnutProgressBarTrack()
        setupDoughnutProgressBar()
        setupScoreLabel()
        setupDisplayLink()
        setupGestureRecogniser()
        
        animationStartDate = Date()
        view.backgroundColor = .white
    }
    
    @objc func refresh() {
        animationStartDate = Date()
        fetchData()
    }
    
    @objc func animateScoreProgressBar() {
        
        guard dashboardViewModel != nil else { return }
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = dashboardViewModel?.progressBarValue
        animation.duration = animationDuration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        circularShapeLayer.add(animation, forKey: "circularAnimation")
    }
    
    func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(scoreUpdate))
        
        if let displayLink = displayLink {
            displayLink.add(to: .main, forMode: .default)
        }
    }
    
    ///This method is called every screen refresh
    @objc func scoreUpdate() {
        
        guard dashboardViewModel != nil && animationStartDate != nil else { return }
        
        let now = Date()
        let elapsedTime = now.timeIntervalSince(animationStartDate!)
        
        if elapsedTime > animationDuration {
            self.scoreLabel.text = String(format: "%.0f", dashboardViewModel!.score)
            displayLink?.invalidate()
            displayLink = nil
            animationStartDate = nil
        } else {
            let percentage = elapsedTime / animationDuration
            let value = 0 + percentage * (dashboardViewModel!.score  - 0)
            self.scoreLabel.text = String(format:"%.0f", value)
        }
    }
    
    func setupGestureRecogniser() {
        let gestureTap = UITapGestureRecognizer(target: self, action: #selector(refresh))
        view.addGestureRecognizer(gestureTap)
    }
    
    fileprivate func fetchData() {
        
        //Remove previously retrieved data should the user do a refresh
        dashboardViewModel = nil
        
        Service.shared.fetchAccount(url: "https://5lfoiyb0b3.execute-api.us-west-2.amazonaws.com/prod/mockcredit/values") { [weak self] dashboardViewModel, error in
            
            //Check if there is any error in fetching
            if let error = error {
                print(error)
                return
            }
            
            //Set the new retrieved data and start animating the doughnut bar
            self?.dashboardViewModel = dashboardViewModel
            self?.animateScoreProgressBar()
        }
    }
    
}

// MARK: - Setup code and constraints

extension DashboardView {
    
    fileprivate func setupNavigation() {
        navigationItem.title = "Dashboard"
        
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundColor = .black
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }
    
    fileprivate func setupDoughnutProgressBarTrack() {
        let centerPoint = view.center
        
        let circularTrackLayer = CAShapeLayer()
        
        circularTrackLayer.strokeColor = UIColor.black.cgColor
        circularTrackLayer.fillColor = UIColor.clear.cgColor
        circularTrackLayer.lineWidth = 2
        circularTrackLayer.lineCap = .round
        
        let circlPath = UIBezierPath(arcCenter: centerPoint, radius: 160, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        
        circularTrackLayer.path = circlPath.cgPath
        
        view.layer.addSublayer(circularTrackLayer)
    }
    
    fileprivate func setupDoughnutProgressBar() {
        let centerPoint = view.center
        
        circularShapeLayer.strokeColor = UIColor.orange.cgColor
        circularShapeLayer.fillColor = UIColor.clear.cgColor
        circularShapeLayer.lineWidth = 4
        circularShapeLayer.lineCap = .round
        circularShapeLayer.strokeEnd = 0
        
        let circlePath = UIBezierPath(arcCenter: centerPoint, radius: 150, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        
        circularShapeLayer.path = circlePath.cgPath
        
        view.layer.addSublayer(circularShapeLayer)
    }
    
    fileprivate func setupScoreLabel() {
        view.addSubview(scoreLabel)
        view.addSubview(creditScoreTextLabel)
        view.addSubview(maximumCreditScoreTextLabel)
        
        NSLayoutConstraint.activate([
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            creditScoreTextLabel.bottomAnchor.constraint(equalTo: scoreLabel.topAnchor, constant: -5),
            creditScoreTextLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            maximumCreditScoreTextLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 5),
            maximumCreditScoreTextLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
    }
    
}
