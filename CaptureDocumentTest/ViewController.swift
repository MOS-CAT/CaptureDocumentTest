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

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
	
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
	private let visionSequenceHandler = VNSequenceRequestHandler()
	private var lastObservation: VNDetectedObjectObservation?
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// make the camera appear on the screen
		self.cameraView.layer.addSublayer(self.cameraLayer)
		
		// register to receive buffers from the camera
		let videoOutput = AVCaptureVideoDataOutput()
		videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
		self.captureSession.addOutput(videoOutput)
		
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

	
	// MARK: AVCaptureVideoDataOutputSampleBufferDelegate
	
	
	func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		guard
			// get the CVPixelBuffer out of the CMSampleBuffer
			let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
			// make sure that there is a previous observation we can feed into the request
			let lastObservation = self.lastObservation
		else {
			return
		}
		
		// create the request
		let request = VNTrackObjectRequest(detectedObjectObservation: lastObservation, completionHandler: nil)
		// set the accuracy to high
		// this is slower, but it works a lot better
		request.trackingLevel = .accurate
		
		// perform the request
		do {
			try self.visionSequenceHandler.perform([request], on: pixelBuffer)
		} catch {
			print("Throws: \(error)")
		}
	}

}

