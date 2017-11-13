import UIKit
import AVFoundation

class NowPlayingViewController: UIViewController {
    
    @IBOutlet weak var albumHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var albumImageView: SpringImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var songLabel: SpringLabel!
    @IBOutlet weak var stationDescLabel: UILabel!
    @IBOutlet weak var volumeParentView: UIView!
    
    @IBOutlet weak var recommendSong: UIButton!
    @objc var iPhone4 = false
    @objc var nowPlayingImageView: UIImageView!
    static var radioPlayer: AVPlayer!
    let streamUrl = "http://139.162.100.116:8000/abc.m3u"
    
    static var isPlaying = false;
    override func viewDidLoad() {
        super.viewDidLoad()
        if (NowPlayingViewController.isPlaying){
            self.playButton.setImage(#imageLiteral(resourceName: "btn-pause"), for: UIControlState.normal)
        }else{
            play()
        }
        reformButton()
    }
    
    private func reformButton(){
        recommendSong.layer.cornerRadius = 10;
        recommendSong.clipsToBounds = true;
        title = "FRadio"
    }
    
    
    @IBAction func playPausePress(_ sender: Any) {
        if (NowPlayingViewController.isPlaying){
            pause()
        } else {
            play()
        }
    }
    
    private func play(){
        NowPlayingViewController.radioPlayer = AVPlayer(url: URL.init(string: streamUrl)!);
        NowPlayingViewController.radioPlayer.play();
        self.playButton.setImage(#imageLiteral(resourceName: "btn-pause"), for: UIControlState.normal)
        NowPlayingViewController.isPlaying = true
    }
    private func pause(){
        NowPlayingViewController.radioPlayer.pause();
        NowPlayingViewController.radioPlayer = nil;
        self.playButton.setImage(#imageLiteral(resourceName: "btn-play") ,for: UIControlState.normal)
        NowPlayingViewController.isPlaying = false
    }
    
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
}
