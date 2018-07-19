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

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    let downloadQueue = DispatchQueue(label: "DownloadQueue")
    
    var pickerDataSource = [Blockchain]()
    var audioPlayer: AVAudioPlayer!
    var audioPlayerData: Data?
    var isPlayingActive: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        
        // init data source
        pickerDataSource.append(BtcBlockchain(name: "BTC last block", id: 1, url: "https://chain.api.btc.com/v3/block/"))
        
        // default states
        playButton.isHidden = false
        stopButton.isHidden = true
        loading.isHidden = true
        
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
    
    /// Play button touch
    @IBAction func playTouch(_ sender: Any) {
        if (!isPlayingActive) {
            playAudioAndPrepareNext()
            
            isPlayingActive = true
            playButton.isHidden = true
            stopButton.isHidden = false
        }
    }
    
    /// Stop button touch
    @IBAction func stopTouch(_ sender: Any) {
        if (isPlayingActive) {
            if let player = audioPlayer {
                player.stop()
            }
            
            isPlayingActive = false
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
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = pickerDataSource[row].Name
        return NSAttributedString(string: string, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
    }
    
    /// Load audio from blockchain url and prepare player for playing
    func prepareAudioFromSelectedBlockchain(block: Blockchain)
    {
        downloadQueue.async {
            // animate loading
            DispatchQueue.main.async {
                self.animateLoading(active: true)
            }
            
            // download data and prepare audioplayer
            if let sound = block.GetAudioFileFromUrl() {
                // store data from url
                self.audioPlayerData = sound
                
                // stop animating loading
                DispatchQueue.main.async {
                    self.animateLoading(active: false)
                }
                
                // player active
                //if (self.isPlayingActive) {
                //    self.audioPlayer.play()
                //}
            } else {
                print("Cant load sound from url")
                // show error - cant load audio file from url
            }
        }
    }
    
    /// play audio from downloaded data and download next audio
    func playAudioAndPrepareNext() {
        do {
            if let data = audioPlayerData {
                audioPlayer = try AVAudioPlayer(data: data)
                audioPlayer.delegate = self
                audioPlayer.play()
                prepareAudioFromSelectedBlockchain(block: pickerDataSource[0])
            }
            
        } catch let error {
            print(error)
        }
    }
    
    /// audioplayer finish playing of audio - prepare next
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if (isPlayingActive) {
            playAudioAndPrepareNext()
        }
    }
    
    /// Animate loading on screen
    func animateLoading(active state: Bool) {
        playButton.isUserInteractionEnabled = !state
        loading.isHidden = !state
        
        // animate
        state ? loading.startAnimating() : loading.stopAnimating()
    }
}


