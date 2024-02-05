//
//  ViewController.swift
//  SimpleClock
//
//  Created by Micah Moore on 2/4/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var timerPicker: UIDatePicker!
    @IBOutlet weak var liveClockLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var startStopButton: UIButton!
    
    var countdownTimer: Timer?
    var backgroundTimer: Timer?
    var audioPlayer: AVAudioPlayer?
    
    // Safely load the UIImage and handle nil using optional chaining
    var backgroundAMImage: UIImage? {
        return UIImage(named: "backgroundAM.jpeg")
    }
    var backgroundPMImage: UIImage? {
        return UIImage(named: "backgroundPM.jpeg")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioPlayer()
        setupTimers()
        updateBackground()
    }
    
    deinit {
        countdownTimer?.invalidate()
        backgroundTimer?.invalidate()
    }
    
    func setupAudioPlayer() {
        if let soundURL = Bundle.main.url(forResource: "alarm", withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error: Could not load the audio file.")
            }
        }
    }
    
    @IBAction func timerButtonTapped(_ sender: UIButton) {
        if sender.title(for: .normal) == "Stop Music" {
            audioPlayer?.stop()
            sender.setTitle("Start Timer", for: .normal)
            timerPicker.isEnabled = true
        } else {
            let selectedDuration = timerPicker.countDownDuration
            startCountdownTimer(duration: selectedDuration)
            sender.setTitle("Stop Timer", for: .normal)
            timerPicker.isEnabled = false
        }
    }
    
    func startCountdownTimer(duration: TimeInterval) {
        countdownTimer?.invalidate()

        let endTime = Date().addingTimeInterval(duration)
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateCountdownLabel(endTime: endTime)
        }
    }
    
    func updateCountdownLabel(endTime: Date) {
        let currentTime = Date()
        let remainingTime = endTime.timeIntervalSince(currentTime)
        if remainingTime <= 0 {
            countdownTimer?.invalidate()
            countdownLabel.text = "00:00:00"
            audioPlayer?.play()
            startStopButton.setTitle("Stop Music", for: .normal)
            timerPicker.isEnabled = true
        } else {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.zeroFormattingBehavior = .pad
            countdownLabel.text = formatter.string(from: remainingTime)
        }
    }
    
    func setupTimers() {
        backgroundTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateClockAndBackground), userInfo: nil, repeats: true)
        
        updateClockAndBackground()
    }
    
    @objc func updateClockAndBackground() {
        updateClockLabel()
        updateBackground()
    }
    
    func updateClockLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss"
        liveClockLabel.text = dateFormatter.string(from: Date())
    }
    
    func updateBackground() {
        let hour = Calendar.current.component(.hour, from: Date())
        if let imageView = backgroundImageView {
            imageView.image = hour < 12 ? backgroundAMImage : backgroundPMImage
        } else {
            print("backgroundImageView is nil.")
        }
    }
}
