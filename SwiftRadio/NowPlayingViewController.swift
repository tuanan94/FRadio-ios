//
//  NowPlayingViewController.swift
//  Swift Radio
//
//  Created by Matthew Fecher on 7/22/15.
//  Copyright (c) 2015 MatthewFecher.com. All rights reserved.
//

import UIKit
import MediaPlayer

//*****************************************************************
// Protocol
// Updates the StationsViewController when the track changes
//*****************************************************************

protocol NowPlayingViewControllerDelegate: class {
    func songMetaDataDidUpdate(_ track: Track)
    func artworkDidUpdate(_ track: Track)
    func trackPlayingToggled(_ track: Track)
}

//*****************************************************************
// NowPlayingViewController
//*****************************************************************

class NowPlayingViewController: UIViewController {
    
    @IBOutlet weak var albumHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var albumImageView: SpringImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var songLabel: SpringLabel!
    @IBOutlet weak var stationDescLabel: UILabel!
    @IBOutlet weak var volumeParentView: UIView!
    @IBOutlet weak var slider = UISlider()
    
    @objc var currentStation: RadioStation!
    @objc var downloadTask: URLSessionDownloadTask?
    @objc var iPhone4 = false
    @objc var justBecameActive = false
    @objc var newStation = true
    @objc var nowPlayingImageView: UIImageView!
    @objc var radioPlayer: AVPlayer!
    var track: Track!
    @objc var mpVolumeSlider = UISlider()
    
    weak var delegate: NowPlayingViewControllerDelegate?
    
    //*****************************************************************
    // MARK: - ViewDidLoad
    //*****************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup current station
        let name      = "In development"
        let streamURL = "http://139.162.100.116:8000/abc.m3u"
        let imageURL  = ""
        let desc      = "Short description"
        let longDesc  = "Long description"
        
        let station = RadioStation(name: name, streamURL: streamURL, imageURL: imageURL, desc: desc, longDesc: longDesc)
        self.currentStation = station
        
        
        // Setup handoff functionality - GH
        //        setupUserActivity()
        
        // Set AlbumArtwork Constraints
        optimizeForDeviceSize()
        
        // Set View Title
        self.title = currentStation.stationName
        
        // Create Now Playing BarItem
        createNowPlayingAnimation()
        
        setUpPlayer()
        
        // Notification for when app becomes active
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NowPlayingViewController.didBecomeActiveNotificationReceived),
                                               name: NSNotification.Name(rawValue: "UIApplicationDidBecomeActiveNotification"),
                                               object: nil)
        
        // Notification for AVAudioSession Interruption (e.g. Phone call)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NowPlayingViewController.sessionInterrupted(_:)),
                                               name: NSNotification.Name.AVAudioSessionInterruption,
                                               object: AVAudioSession.sharedInstance())
        
        // Check for station change
        if newStation {
            track = Track()
            stationDidChange()
        } else {
            updateLabels()
            albumImageView.image = track.artworkImage
            
            if !track.isPlaying {
                pausePressed()
            } else {
                nowPlayingImageView.startAnimating()
            }
        }
        
        // Setup slider
        setupVolumeSlider()
    }
    
    @objc func didBecomeActiveNotificationReceived() {
        // View became active
        updateLabels()
        justBecameActive = true
    }
    
    deinit {
        // Be a good citizen
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "UIApplicationDidBecomeActiveNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
        resetPlayer()
    }
    
    //*****************************************************************
    // MARK: - Setup
    //*****************************************************************
    
    
    @objc func setUpPlayer(){
        radioPlayer = Player.radio
        radioPlayer.rate = 1
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.playerItemDidReachEnd),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: self.radioPlayer.currentItem
        )
        
    }
    
    @objc func resetPlayer(){
        if radioPlayer != nil {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.radioPlayer.currentItem)
        }
    }
    
    @objc func setupVolumeSlider() {
        // Note: This slider implementation uses a MPVolumeView
        // The volume slider only works in devices, not the simulator.
        volumeParentView.backgroundColor = UIColor.clear
        let volumeView = MPVolumeView(frame: volumeParentView.bounds)
        for view in volumeView.subviews {
            let uiview: UIView = view as UIView
            if (uiview.description as NSString).range(of: "MPVolumeSlider").location != NSNotFound {
                mpVolumeSlider = (uiview as! UISlider)
            }
        }
        
        let thumbImageNormal = UIImage(named: "slider-ball")
        slider?.setThumbImage(thumbImageNormal, for: UIControlState())
    }
    
    @objc func stationDidChange() {
        resetPlayer()
        
        guard let streamURL = URL(string: currentStation.stationStreamURL) else {
            if kDebugLog {
                print("Stream Error \(currentStation.stationStreamURL)")
            }
            return
        }
        
        let streamItem = CustomAVPlayerItem(url: streamURL)
        streamItem.delegate = self
        
        DispatchQueue.main.async {
            // prevent the player from "stalling"
            self.radioPlayer.replaceCurrentItem(with: streamItem)
            self.radioPlayer.play()
        }
        
        updateLabels("Loading Station...")
        
        print("stationDidChange \(currentStation.stationStreamURL)")
        
        // songLabel animate
        songLabel.animation = "flash"
        songLabel.repeatCount = 3
        songLabel.animate()
        
        track.isPlaying = true
    }
    
    //*****************************************************************
    // MARK: - Player Controls (Play/Pause/Volume)
    //*****************************************************************
    
    @IBAction func playPressed() {
        track.isPlaying = true
        playButtonEnable(false)
        stationDidChange()
        
        updateLabels()
        
        // songLabel Animation
        songLabel.animation = "flash"
        songLabel.animate()
        
        // Start NowPlaying Animation
        nowPlayingImageView.startAnimating()
        
        // Update StationsVC
        self.delegate?.trackPlayingToggled(self.track)
    }
    
    @IBAction func pausePressed() {
        track.isPlaying = false
        playButtonEnable()
        radioPlayer.pause()
        updateLabels("Station Paused...")
        nowPlayingImageView.stopAnimating()
        
        // Update StationsVC
        self.delegate?.trackPlayingToggled(self.track)
    }
    
    @IBAction func volumeChanged(_ sender:UISlider) {
        mpVolumeSlider.value = sender.value
    }
    
    @objc func togglePlayPause() {
        if track.isPlaying {
            pausePressed()
        } else {
            playPressed()
        }
    }
    
    //*****************************************************************
    // MARK: - UI Helper Methods
    //*****************************************************************
    
    @objc func optimizeForDeviceSize() {
        // Adjust album size to fit iPhone 4s, 6s & 6s+
        let deviceHeight = self.view.bounds.height
        
        if deviceHeight == 480 {
            iPhone4 = true
            albumHeightConstraint.constant = 106
            view.updateConstraints()
        } else if deviceHeight == 667 {
            albumHeightConstraint.constant = 230
            view.updateConstraints()
        } else if deviceHeight > 667 {
            albumHeightConstraint.constant = 260
            view.updateConstraints()
        }
    }
    
    @objc func updateLabels(_ statusMessage: String = "") {
        if statusMessage != "" {
            // There's a an interruption or pause in the audio queue
            songLabel.text = statusMessage
            artistLabel.text = currentStation.stationName
            
        } else {
            // Radio is (hopefully) streaming properly
            if track != nil {
                songLabel.text = track.title
                artistLabel.text = track.artist
            }
        }
        
        // Hide station description when album art is displayed or on iPhone 4
        if track.artworkLoaded || iPhone4 {
            stationDescLabel.isHidden = true
        } else {
            stationDescLabel.isHidden = false
            stationDescLabel.text = currentStation.stationDesc
        }
    }
    
    @objc func playButtonEnable(_ enabled: Bool = true) {
        if enabled {
            playButton.isEnabled = true
            pauseButton.isEnabled = false
            track.isPlaying = false
        } else {
            playButton.isEnabled = false
            pauseButton.isEnabled = true
            track.isPlaying = true
        }
    }
    
    @objc func createNowPlayingAnimation() {
        
        // Setup ImageView
        nowPlayingImageView = UIImageView(image: UIImage(named: "NowPlayingBars-3"))
        nowPlayingImageView.autoresizingMask = UIViewAutoresizing()
        nowPlayingImageView.contentMode = UIViewContentMode.center
        
        // Create Animation
        nowPlayingImageView.animationImages = AnimationFrames.createFrames()
        nowPlayingImageView.animationDuration = 0.7
        
        // Create Top BarButton
        let barButton = UIButton(type: UIButtonType.custom)
        barButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40);
        barButton.addSubview(nowPlayingImageView)
        nowPlayingImageView.center = barButton.center
        
        let barItem = UIBarButtonItem(customView: barButton)
        self.navigationItem.rightBarButtonItem = barItem
        
    }
    
    @objc func startNowPlayingAnimation() {
        DispatchQueue.main.async { [unowned self] in
            self.nowPlayingImageView.startAnimating()
        }
    }
    
    
    
    //*****************************************************************
    // MARK: - Segue
    //*****************************************************************
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "InfoDetail" {
            let infoController = segue.destination as! InfoDetailViewController
            infoController.currentStation = currentStation
        }
    }
    
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "InfoDetail", sender: self)
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        let songToShare = "I'm listening to \(track.title) on \(currentStation.stationName) via Swift Radio Pro"
        let activityViewController = UIActivityViewController(activityItems: [songToShare, track.artworkImage!], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    //*****************************************************************
    // MARK: - MPNowPlayingInfoCenter (Lock screen)
    //*****************************************************************
    
    @objc func updateLockScreen() {
        // Update notification/lock screen
        let albumArtwork = MPMediaItemArtwork(image: track.artworkImage!)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyArtist: track.artist,
            MPMediaItemPropertyTitle: track.title,
            MPMediaItemPropertyArtwork: albumArtwork
        ]
        
        // Configure playing control :
        
        //MPRemoteCommandCenter.sharedCommandCenter().previousTrackCommand.enabled = false
        //MPRemoteCommandCenter.sharedCommandCenter().nextTrackCommand.enabled = false
        MPRemoteCommandCenter.shared().playCommand.isEnabled = true
        MPRemoteCommandCenter.shared().playCommand.addTarget(self, action: #selector(playPressed))
        MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
        MPRemoteCommandCenter.shared().pauseCommand.addTarget(self, action: #selector(pausePressed))
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.isEnabled = true
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget(self, action: #selector(togglePlayPause))
    }
    
    override func remoteControlReceived(with receivedEvent: UIEvent?) {
        super.remoteControlReceived(with: receivedEvent)
        
        if receivedEvent!.type == UIEventType.remoteControl {
            
            switch receivedEvent!.subtype {
            case .remoteControlPlay:
                playPressed()
            case .remoteControlPause:
                pausePressed()
            default:
                break
            }
        }
    }
    
    //*****************************************************************
    // MARK: - AVAudio Sesssion Interrupted
    //*****************************************************************
    
    // Example code on handling AVAudio interruptions (e.g. Phone calls)
    @objc func sessionInterrupted(_ notification: Notification) {
        if let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber{
            if let type = AVAudioSessionInterruptionType(rawValue: typeValue.uintValue){
                if type == .began {
                    if kDebugLog {
                        print("interruption: began")
                    }
                    // Add your code here
                } else{
                    if kDebugLog {
                        print("interruption: ended")
                    }
                    // Add your code here
                }
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Handoff Functionality - GH
    //*****************************************************************
    //
    //    @objc func setupUserActivity() {
    //        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb ) //"com.graemeharrison.handoff.googlesearch" //NSUserActivityTypeBrowsingWeb
    //        userActivity = activity
    //        let url = "https://www.google.com/search?q=\(self.artistLabel.text!)+\(self.songLabel.text!)"
    //        let urlStr = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    //        let searchURL : URL = URL(string: urlStr!)!
    //        activity.webpageURL = searchURL
    //        userActivity?.becomeCurrent()
    //    }
    //
    override func updateUserActivityState(_ activity: NSUserActivity) {
        let url = "https://www.google.com/search?q=\(self.artistLabel.text!)+\(self.songLabel.text!)"
        let urlStr = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let searchURL : URL = URL(string: urlStr!)!
        activity.webpageURL = searchURL
        super.updateUserActivityState(activity)
    }
    
    
    //*****************************************************************
    // MARK: - Detect end of mp3 in case you're using a file instead of a stream
    //*****************************************************************
    
    @objc func playerItemDidReachEnd(){
        if kDebugLog {
            print("playerItemDidReachEnd")
        }
    }
}

//*****************************************************************
// MARK: - AVPlayerItem Delegate (for metadata)
//*****************************************************************

extension NowPlayingViewController: CustomAVPlayerItemDelegate {
    @objc func onMetaData(_ metaData: [AVMetadataItem]?) {
        if let metaDatas = metaData{
            startNowPlayingAnimation()
            let firstMeta: AVMetadataItem = metaDatas.first!
            let metaData = firstMeta.value as! String
            
            track.title = metaData
            
            DispatchQueue.main.async {
                if (self.radioPlayer.rate == 0 || self.radioPlayer.error != nil){
                    self.stationDidChange()
                }
                self.songLabel.text = self.track.title
                self.songLabel.animation = "zoomIn"
                self.songLabel.duration = 1.5
                self.songLabel.damping = 1
                self.songLabel.animate()
                
                //                self.artistLabel.text = self.track.artist
                //                self.songLabel.text = self.track.title
                
            }
        }
    }
}
