
import Foundation



/**
 * Query string
 */
open class QueryString {
    
    
    
    public init() {
        
    }
    
    
    
    /**
     * encode
     */
    open func encode() -> String {
        
        let mirror = Mirror(reflecting: self)
        var params = [String]()
        
        for (label, value) in mirror.children {
            
            if type(of: (value)) is String.Type {
                params.append(handleString(label!, value: value))
            }

            else if type(of: (value)) is Bool.Type {
                params.append("\(label!)=\(value)")
            }
            
            else if type(of: (value)) is Int.Type {
                params.append(handleInt(label!, value: value))
            }
            
            else if type(of: (value)) is [String].Type {
                if let arr = value as? [String] {
                    let vals = arr.map() {"\"\($0)\""}
                    let values = vals.joined(separator: ",")
                    params.append("\(label!)=[\(values)]")
                }
            }
            
            else {
                // handle optionals
                let sub = Mirror(reflecting: value)
                
                if let displayStyle = sub.displayStyle {
                    switch displayStyle {
                    case .optional:
                        
                        for (subLabel, subValue) in sub.children {
                            
                            if let subLabel = subLabel {
                                if subLabel == "some" {
                                    
                                    if type(of: (subValue)) is String.Type {
                                        params.append(handleString(label!, value: subValue))
                                    }
                                        
                                    else if type(of: (subValue)) is Int.Type {
                                        params.append(handleInt(label!, value: subValue))
                                    }
                                        
                                    else if type(of: (subValue)) is Bool.Type {
                                        params.append("\(label!)=\(subValue)")
                                    }
                                }
                            }
                            
                        }
                        
                    default:
                        break
                    }
                }
                
            }
        }
        
        return params.joined(separator: "&")
        
    }
    
    // handle String
    fileprivate func handleString(_ key: String, value: Any) -> String {
        return "\(key)=\"\(value)\""
    }
    
    fileprivate func handleInt(_ key: String, value: Any) -> String {
        return "\(key)=\(value)"
    }
    
}
