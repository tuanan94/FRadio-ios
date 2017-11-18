import UIKit
import AVFoundation
import Firebase
import FirebaseDatabase
import NotificationBannerSwift
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
    let streamUrl = "http://fradio.site:8000/default.m3u"
    var ref: DatabaseReference!
    static var notification: String!
    
    static var isPlaying = false;
    override func viewDidLoad() {
        super.viewDidLoad()
        if (NowPlayingViewController.isPlaying){
            self.playButton.setImage(#imageLiteral(resourceName: "btn-pause"), for: UIControlState.normal)
        }else{
            play()
        }
        reformButton()
        self.setupFirebase()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.displayNotification()
    }
    private func displayNotification(){
        if NowPlayingViewController.notification == nil {
            return
        }
        switch NowPlayingViewController.notification {
        case "success":
            let banner = NotificationBanner(title: "Successfully!!", subtitle: "Thank you, your song will be played soon", style: .success)
            banner.show()
            NowPlayingViewController.notification = nil
            break
        case "fail":
            let banner = NotificationBanner(title: "Some thing went wrong", subtitle: "I will investigate this case asap", style: .danger)
            banner.show()
            NowPlayingViewController.notification = nil
            break;
        default: break
            // Do nothing
        }
    }
    
    private func setupFirebase(){
        if (FirebaseApp.app() == nil){
            FirebaseApp.configure()
        }
        ref = Database.database().reference(fromURL: "https://fradio-firebase.firebaseio.com/current")
        ref.removeAllObservers()
        ref.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            let videoTitle = postDict["title"] as? String
            if (videoTitle == nil){
                self.songLabel.text = "waiting new song..."
            }else{
                self.songLabel.text = videoTitle
            }
            print("a")
        })
        
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
        if #available(iOS 10.0, *) {
            NowPlayingViewController.radioPlayer.automaticallyWaitsToMinimizeStalling = true
        } else {
            // Fallback on earlier versions
        }
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
