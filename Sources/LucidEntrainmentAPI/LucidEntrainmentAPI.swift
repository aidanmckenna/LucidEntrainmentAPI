import Foundation
public struct EntrainmentAPI: EntrainmentRepositoryFactory {
    
    public static func getRepo() -> EntrainmentRepository {
        return LucidCMSEntrainmentRepository()
    }
}

public protocol EntrainmentRepositoryFactory
{
    static func getRepo()->EntrainmentRepository
}

public struct EntrainmentAsset
{
    let id: String
    let beatFrequency: Double
    let driverFrequency: Double
    let sourceUrl:URL
}


public protocol EntrainmentRepository
{
    func getEntrainmentAsset(beatFrequency: String, driverFrequency: String, completion: @escaping (EntrainmentAsset?, Error?)->Void)
    func createEntrainmentAsset(beatFrequency: String, driverFrequency: String, fileUrl: URL)
}

class LucidCMSEntrainmentRepository: EntrainmentRepository
{
    private static let endpointBaseString: String = "https://lucid-tracks-dot-lucid-cloud-application.appspot.com/v1/api/entrainment/"
    
    func createEntrainmentAsset(beatFrequency: String, driverFrequency: String, fileUrl: URL) {
        return
    }
    
    func getEntrainmentAsset(beatFrequency: String, driverFrequency: String, completion: @escaping (EntrainmentAsset?, Error?) -> Void) {
        
        var urlComponents = URLComponents(string: LucidCMSEntrainmentRepository.endpointBaseString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "ebf", value: beatFrequency),
            URLQueryItem(name: "edf", value: driverFrequency)
        ]
        let request = URLRequest(url:urlComponents.url!)
        let task = URLSession.shared.dataTask(with:request){ data, response, error in
            guard let data = data,                            // is there data
                let response = response as? HTTPURLResponse,  // is there HTTP response
                (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                error == nil else {
                    completion(nil, error)
                    return
            }
            let jsonData = try! JSONSerialization.jsonObject(with: data) as! NSDictionary
            let asset = EntrainmentAsset(id: jsonData["id"] as! String,
                                         beatFrequency: jsonData["beat_frequency"] as! Double,
                                         driverFrequency: jsonData["driver_frequency"] as! Double,
                                         sourceUrl: URL(string: jsonData["track"] as! String)
            completion(asset, nil)
        }.resume()
    }
}

