//
//  ViewController.swift
//  AR-Ruler
//
//  Created by Azure May Burmeister on 3/31/20.
//  Copyright © 2020 Azure May Burmeister. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()

        sceneView.session.run(configuration)
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    //MARK: - Dot Rendering Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 {
            clearDots()
        }
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitResult = hitTestResults.last {
                addDot(at: hitResult)
            }
        }
    }
    
    private func addDot(at location: ARHitTestResult) {
        
        let dataRow = location.worldTransform.columns.3
        let dot = SCNSphere(radius: 0.005)
        dot.firstMaterial?.diffuse.contents = UIColor.red
        let dotNode = SCNNode(geometry: dot)
        dotNode.position = SCNVector3(dataRow.x, dataRow.y, dataRow.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    //MARK: - Calculation Methods
    
    private func calculate() {
//        distance = √ ((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
        let start = dotNodes[0]
        let end = dotNodes[1]
        let distance = sqrt(
            pow(end.position.x - start.position.x, 2) +
            pow(end.position.y - start.position.y, 2) +
            pow(end.position.z - start.position.z, 2)
        )
        let inInches = abs(distance * 39.3701)
        displayText(String(inInches), at: end.position)
    }
    
    //MARK: - Display Text
    
    private func displayText(_ length: String, at position: SCNVector3) {
        let textGeometry = SCNText(string: length, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.blue
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.005, position.z)
        textNode.scale = SCNVector3(0.005, 0.005, 0.005)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    //MARK: - Remove Dot Methods
    
    @IBAction func rewindTapped(_ sender: UIBarButtonItem) {
        if let dot = dotNodes.last {
            dot.removeFromParentNode()
            dotNodes.removeLast()
            textNode.removeFromParentNode()
        }
    }
    
    @IBAction func refreshTapped(_ sender: UIBarButtonItem) {
        clearDots()
    }
    
    private func clearDots() {
        for dot in dotNodes {
            dot.removeFromParentNode()
        }
        dotNodes.removeAll()
        textNode.removeFromParentNode()
    }
}
