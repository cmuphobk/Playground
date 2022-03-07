import UIKit

final class ViewController: UIViewController {
    
    private let grapView = GraphView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white.withAlphaComponent(0.95)
        
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.title = "Redraw"
        button.addTarget(self, action: #selector(redraw(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        grapView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(button)
        view.addSubview(grapView)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            grapView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            grapView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            grapView.heightAnchor.constraint(equalToConstant: 200.0),
            grapView.widthAnchor.constraint(equalToConstant: 200.0)
        ])
    }
    
    @objc
    private func redraw(_ sender: UIButton) {
        let count = arc4random() % 10 + 1
        var parts: [GraphView.Part] = []
        for _ in 0..<count {
            parts.append(
                GraphView.Part(color: .random, value: CGFloat(arc4random() % 100 + 1))
            )
        }
        grapView.parts = parts
        grapView.mode = Bool.random() ? .pie : .donut(lineWidth: CGFloat(arc4random() % 30))
    }
}

extension CGFloat {
    static var random: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(
           red: .random,
           green: .random,
           blue: .random,
           alpha: 1.0
        )
    }
}
