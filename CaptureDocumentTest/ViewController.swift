//
//  ViewController.swift
//  CaptureDocumentTest
//
//  Created by Masahiro Kaneko on 2018/02/25.
//  Copyright © 2018年 MOSCAT. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController {
	
	// cameraView
	@IBOutlet private weak var cameraView: UIView!
	
	private lazy var cameraLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
	private lazy var captureSession: AVCaptureSession = {
		let session = AVCaptureSession()
		session.sessionPreset = AVCaptureSession.Preset.photo
		guard
			let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
			let input = try? AVCaptureDeviceInput(device: backCamera) else {
			return session
		}
		session.addInput(input)
		return session
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// make the camera appear on the screen
		self.cameraView.layer.addSublayer(self.cameraLayer)
		
		// begin the session
		self.captureSession.startRunning()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		// make sure the layer is the correct size
		self.cameraLayer.frame = self.cameraView.bounds
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

