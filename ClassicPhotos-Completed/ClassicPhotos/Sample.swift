////
////  Sample.swift
////  ClassicPhotos
////
////  Created by Seyed Samad Gholamzadeh on 11/26/1395 AP.
////  Copyright © 1395 AP raywenderlich. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//class Sample: UIViewController {
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        //        DataService.ds.delegate = self
////        tableView.delegate = self
////        tableView.dataSource = self
//        
//        DataService.ds.getAllWeathers {
//            self.updateMainUI()
//        }
//    }
//    
//    func updateMainUI() {
////        currentWeatherTypeLabel.text = currentWeather.weatherType
////        tempLabel.text = "\(currentWeather.currentTemp)"
////        dateLabel.text = currentWeather.date
////        locationLabel.text = currentWeather.cityName
////        currentWeatherImg.image = UIImage(named: currentWeather.weatherType)
//    }
//    
//}
//
//
//
//
////
////  DataService.swift
////  weatherApp
////
////  Created by Keyhan on 2/12/17.
////  Copyright Â© 2017 Keyhan. All rights reserved.
////
//
//import Foundation
//
//protocol DataServiceDelegate: class {
//    func weatherLoaded()
//}
//
//class DataService {
//    
//    static let ds = DataService()
//    
//    weak var delegate: DataServiceDelegate?
//    
//    // GET current weather
//    
//    func getAllWeathers(completed: @escaping downloadComplete) {
//        let sessionConfig = URLSessionConfiguration.default
//        
//        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
//        
//        guard let url = URL(string: CURRENT_WEATHER_URL) else { return }
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        
//        let task = session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, err: Error?) -> Void in
//            if err == nil {
//                // Success
//                let statusCode = (response as! HTTPURLResponse).statusCode
//                print("URL Session Task Succeeded: HTTP \(statusCode)")
//                // Parse JSON data
//                if let data = data {
//                    CurrentWeather.parseWeatherData(data: data) {
//                        completed()
//                    }
//                    //self.delegate?.weatherLoaded()
//                }
//            } else {
//                // Failure
//                print("URL Session Task Failed: \(err!.localizedDescription)")
//            }
//        })
//        task.resume()
//        session.finishTasksAndInvalidate()
//        completed()
//    }
//}
//
//
////
////  CurrentWeather.swift
////  weatherApp
////
////  Created by Keyhan on 2/12/17.
////  Copyright Â© 2017 Keyhan. All rights reserved.
////
//
//import UIKit
//
//class CurrentWeather {
//    private var _cityName = ""
//    private var _date = ""
//    private var _weatherYype = ""
//    private var _currentTemp: Double = 0.0
//    
//    var cityName: String {
//        return _cityName
//    }
//    
//    var date: String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .long
//        dateFormatter.timeStyle = .none
//        let currentDate = dateFormatter.string(from: Date())
//        self._date = "Today, \(currentDate)"
//        return _date
//    }
//    
//    var weatherType: String {
//        return _weatherYype
//    }
//    
//    var currentTemp: Double {
//        return _currentTemp
//    }
//    
//    static func parseWeatherData(data: Data) {
//        
//        do {
//            let JSONResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
//            
//            // parse JSON data
//            if let dict = JSONResult as? Dictionary<String, AnyObject> {
//                
//                let newWeather = CurrentWeather()
//                
//                if let name = dict["name"] as? String {
//                    newWeather._cityName = name.capitalized
//                    
//                    print("KEYHAN: \(newWeather._cityName)")
//                }
//                
//                if let weather = dict["weather"] as? [Dictionary<String, AnyObject>] {
//                    if let main = weather[0]["main"] as? String {
//                        newWeather._weatherYype = main.capitalized
//                        
//                        print("KEYHAN: \(newWeather._weatherYype)")
//                    }
//                    
//                    if let main = dict["main"] as? Dictionary<String, AnyObject> {
//                        if let cureentTemp = main["temp"] as? Double {
//                            
//                            let kelvinToCelsiusPre = (cureentTemp - 273.15)
//                            
//                            let kelvinToCelsius = Double(round(kelvinToCelsiusPre))
//                            
//                            newWeather._currentTemp = kelvinToCelsius
//                            
//                            print("KEYHAN: \(newWeather._currentTemp)")
//                        }
//                    }
//                }
//                
//            }
//            
//        } catch let err as NSError {
//            print(err.debugDescription)
//        }
//    }
//}
