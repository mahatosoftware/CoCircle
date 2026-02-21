import google_mobile_ads

class ListTileNativeAdFactory: NSObject, FLTNativeAdFactory {
    func createNativeAd(_ nativeAd: GADNativeAd, customOptions: [AnyHashable : Any]?) -> GADNativeAdView? {
        let adView = GADNativeAdView()
        adView.backgroundColor = .systemGray6
        
        // Icon
        let iconView = UIImageView()
        adView.addSubview(iconView)
        adView.iconView = iconView
        iconView.image = nativeAd.icon?.image
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        // Headline
        let headlineLabel = UILabel()
        adView.addSubview(headlineLabel)
        adView.headlineView = headlineLabel
        headlineLabel.text = nativeAd.headline
        headlineLabel.font = .boldSystemFont(ofSize: 16)
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Body
        let bodyLabel = UILabel()
        adView.addSubview(bodyLabel)
        adView.bodyView = bodyLabel
        bodyLabel.text = nativeAd.body
        bodyLabel.font = .systemFont(ofSize: 12)
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Call to Action
        let ctaButton = UIButton(type: .system)
        adView.addSubview(ctaButton)
        adView.callToActionView = ctaButton
        ctaButton.setTitle(nativeAd.callToAction, for: .normal)
        ctaButton.titleLabel?.font = .systemFont(ofSize: 12)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 8),
            iconView.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 48),
            iconView.heightAnchor.constraint(equalToConstant: 48),
            
            headlineLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            headlineLabel.topAnchor.constraint(equalTo: adView.topAnchor, constant: 8),
            headlineLabel.trailingAnchor.constraint(equalTo: ctaButton.leadingAnchor, constant: -8),
            
            bodyLabel.leadingAnchor.constraint(equalTo: headlineLabel.leadingAnchor),
            bodyLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 4),
            bodyLabel.trailingAnchor.constraint(equalTo: headlineLabel.trailingAnchor),
            bodyLabel.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -8),
            
            ctaButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -8),
            ctaButton.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
            ctaButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
        
        adView.nativeAd = nativeAd
        return adView
    }
}
