Pod::Spec.new do |s|
  s.name             = "Animeteor"
  s.version          = "1.0.4"
  s.summary          = "An animation library for iOS."
  s.description      = <<-DESC
                       Animeteor is an iOS animation library designed to make it easy to create complex animations without the need for Core Animation.
                       DESC
  s.homepage         = "https://github.com/trenskow/Animeteor"
  s.license          = { :type => "BSD 2-Clause", :file => "LICENSE" }

  s.author           = "Kristian Trenskow"
  s.social_media_url = "https://twitter.com/trenskow"

  s.platform         = :ios, "6.0"
  s.source           = { :git => "https://github.com/trenskow/Animeteor.git", :tag => "1.0.0" }

  s.source_files     = "Animeteor/*.{h,m}"

  s.public_header_files = "Animeteor/AMCurve.h", "Animeteor/AMFadeAnimation.h", "Animeteor/AMDirectAnimation.h", "Animeteor/AMInterpolatable.h", "Animeteor/CALayer+AnimeteorAdditions.h", "Animeteor/AMScaleAnimation.h", "Animeteor/AMOpacityAnimation.h", "Animeteor/UIView+AnimeteorAdditions.h", "Animeteor/AMAnimationGroup.h", "Animeteor/AMAnimatable.h", "Animeteor/AMRotateAnimation.h", "Animeteor/Animeteor.h", "Animeteor/AMAnimation.h", "Animeteor/NSNumber+AnimeteorAdditions.h", "Animeteor/NSValue+AnimeteorAdditions.h", "Animeteor/AMPositionAnimation.h", "Animeteor/AMLayerAnimation.h"
  
  s.framework  = "QuartzCore", "UIKit", "Foundation"
  s.requires_arc = true
end
