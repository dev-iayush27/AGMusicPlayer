# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'
use_modular_headers!

def core_pods
  #Keyboard Management
  pod 'IQKeyboardManagerSwift'
  
  #Disk
  pod 'Disk'
end

def ui_pods
  #Toast alert
  pod 'Toast-Swift'
  
  #Asynchronous image download and cache
  pod 'SDWebImage'
end

def rx_pods
  # Networking
  pod 'Alamofire'
  pod 'Moya/RxSwift'
  
  # Model
  pod 'ModelMapper'
  
  # Rx
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxGesture'
end


target 'AGMusicPlayer' do
  core_pods
  ui_pods
  rx_pods
end
