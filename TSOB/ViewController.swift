//
//  ViewController.swift
//  TSOB
//
//  Created by Martin Gabriel on 06.06.18.
//  Copyright © 2018 Martin Gabriel. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var pickerDataSource = [blockchain]()
    var audioPlayer: AVAudioPlayer!
    var isPlaying: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        
        // init data source
        pickerDataSource.append(blockchain(name: "BTC first block", id: 1, url: "https://chain.api.btc.com/v3/block/1/tx"))
        pickerDataSource.append(blockchain(name: "BTC last block", id: 2, url: "https://chain.api.btc.com/v3/block/latest/tx"))
        
        // defaults
        self.playButton.isHidden = false
        self.stopButton.isHidden = true
        self.loading.isHidden = true
        
        // init player and init first sound
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            let firstSound = pickerDataSource[0]
            prepareAudioFromSelectedBlockchain(block: firstSound)
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = pickerDataSource[row].Name
        return NSAttributedString(string: string, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
    }

    @IBAction func playTouch(_ sender: Any) {
        if (!isPlaying) {
            audioPlayer.play()
            isPlaying = true
            playButton.isHidden = true
            stopButton.isHidden = false
        }
    }
    
    @IBAction func stopTouch(_ sender: Any) {
        if (isPlaying) {
            audioPlayer.stop()
            isPlaying = false
            playButton.isHidden = false
            stopButton.isHidden = true
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        let volumeSlider = (MPVolumeView().subviews.filter { NSStringFromClass($0.classForCoder) == "MPVolumeSlider" }.first as! UISlider)
        volumeSlider.setValue(slider.value, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row].Name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let block = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        prepareAudioFromSelectedBlockchain(block: block)
    }
    
    func prepareAudioFromSelectedBlockchain(block: blockchain)
    {
        let queue = DispatchQueue(label: "DownloadQueue")
        
        queue.async {
            do {
                // animate loading
                DispatchQueue.main.async {
                    self.animateLoading(active: true)
                }
                
                // download data and prepare audioplayer
                let sound = block.getAudioFileFromUrl()
                self.audioPlayer = try AVAudioPlayer(data: sound!)
                self.audioPlayer.prepareToPlay()
                
                // stop animating loading
                DispatchQueue.main.async {
                    self.animateLoading(active: false)
                }
                
                // player active
                if (self.isPlaying) {
                    self.audioPlayer.play()
                }
            } catch let error as NSError {
                print(error.debugDescription)
                print(block.Name)
            }
        }
    }
    
    func animateLoading(active state: Bool) {
        self.playButton.isUserInteractionEnabled = !state
        self.loading.isHidden = !state
        
        // animate
        state ? self.loading.startAnimating() : self.loading.stopAnimating()
    }
}


