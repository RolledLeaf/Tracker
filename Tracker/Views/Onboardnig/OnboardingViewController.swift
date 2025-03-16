import UIKit


final class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate  {
    
    lazy var pages: [UIViewController] = {
        
        let firstPage = UIViewController()
        firstPage.view.backgroundColor = .systemBlue
        
        let imageView1: UIImageView = {
            let imageView = UIImageView(image: UIImage(named: OnbordingImage.firstPage.rawValue))
            imageView.contentMode = .scaleAspectFill
            imageView.translatesAutoresizingMaskIntoConstraints = false
            firstPage.view.addSubview(imageView)
            return imageView
        }()
        
        let textLabel: UILabel = {
            let label = UILabel()
            label.text = "Отслеживайте только \n то, что хотите"
            label.numberOfLines = 0
            label.textColor = UIColor.custom(.createButtonColor)
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            firstPage.view.addSubview(label)
            return label
        }()
        
        NSLayoutConstraint.activate([
            imageView1.topAnchor.constraint(equalTo: firstPage.view.topAnchor),
            imageView1.bottomAnchor.constraint(equalTo: firstPage.view.bottomAnchor),
            imageView1.trailingAnchor.constraint(equalTo: firstPage.view.safeAreaLayoutGuide.trailingAnchor),
            imageView1.leadingAnchor.constraint(equalTo: firstPage.view.safeAreaLayoutGuide.leadingAnchor),
            
            textLabel.trailingAnchor.constraint(equalTo: firstPage.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textLabel.leadingAnchor.constraint(equalTo: firstPage.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textLabel.bottomAnchor.constraint(equalTo: firstPage.view.bottomAnchor, constant: -270)
        ])
            
        
        let secondPage = UIViewController()
        secondPage.view.backgroundColor = .systemRed
        
        let imageView2: UIImageView = {
            let imageView = UIImageView(image: UIImage(named: OnbordingImage.secondPage.rawValue))
            imageView.contentMode = .scaleAspectFill
            imageView.translatesAutoresizingMaskIntoConstraints = false
            secondPage.view.addSubview(imageView)
            return imageView
        }()
        
        let textLabel2: UILabel = {
            let label = UILabel()
            label.text = "Даже если это \n не литры воды и йога"
            label.numberOfLines = 0
            label.textColor = UIColor.custom(.createButtonColor)
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            secondPage.view.addSubview(label)
            return label
        }()
        
        NSLayoutConstraint.activate([
            imageView2.topAnchor.constraint(equalTo: secondPage.view.topAnchor),
            imageView2.bottomAnchor.constraint(equalTo: secondPage.view.bottomAnchor),
            imageView2.trailingAnchor.constraint(equalTo: secondPage.view.safeAreaLayoutGuide.trailingAnchor),
            imageView2.leadingAnchor.constraint(equalTo: secondPage.view.safeAreaLayoutGuide.leadingAnchor),
            
            textLabel2.trailingAnchor.constraint(equalTo: secondPage.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textLabel2.leadingAnchor.constraint(equalTo: secondPage.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textLabel2.bottomAnchor.constraint(equalTo: secondPage.view.bottomAnchor, constant: -270)
        ])
        
        return [firstPage, secondPage]
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = UIColor.custom(.createButtonColor)
        pageControl.pageIndicatorTintColor = adjustAlpha(UIColor.custom(.createButtonColor) ?? .backgroundGray, to: 0.3)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let firstViewController = pages.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        setupPageControl()
        setupFinishButton()
    }
    
    private func setupPageControl() {
        view.addSubview(pageControl)
                
                NSLayoutConstraint.activate([
                    pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -161),
                    pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
                ])
    }
    
    private func setupFinishButton() {
        let finishButton = UIButton(type: .system)
        finishButton.setTitle("Вот это технологии!", for: .normal)
        finishButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        finishButton.setTitleColor(UIColor.custom(.createButtonTextColor), for: .normal)
        finishButton.backgroundColor = UIColor.custom(.createButtonColor)
        finishButton.layer.cornerRadius = 16
        
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        finishButton.addTarget(self, action: #selector(finishOnboarding), for: .touchUpInside)
        view.addSubview(finishButton)
        
        NSLayoutConstraint.activate([
            finishButton.widthAnchor.constraint(equalToConstant: 335),
            finishButton.heightAnchor.constraint(equalToConstant: 60),
            finishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            finishButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            
        ])
    }
    
    @objc private func finishOnboarding() {
        
        if let windowScene = view.window?.windowScene {
            let tabBarVC = TabBarController()
            windowScene.windows.first?.rootViewController = tabBarVC
            windowScene.windows.first?.makeKeyAndVisible()
        }
    }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
                return nil
            }
            
            let previousIndex = viewControllerIndex - 1
            guard previousIndex >= 0 else {
                return nil
            }
            
            return pages[previousIndex]
            
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
                return nil
            }
            
            let nextIndex = viewControllerIndex + 1
            
            guard nextIndex < pages.count else {
                return nil
            }
            
            return pages[nextIndex]
        }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
                   let currentIndex = pages.firstIndex(of: currentViewController) {
                    pageControl.currentPage = currentIndex
            }
        }
    }
        
    

