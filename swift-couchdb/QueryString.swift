
import Foundation



/**
 * Query string
 */
public class QueryString {
    
    
    
    public init() {
        
    }
    
    
    
    /**
     * encode
     */
    public func encode() -> String {
        
        var mirror = reflect(self)
        var params = [String]()
        
        for var i = 0; i < mirror.count; i++ {
            let (name, child) = mirror[i]
            
            if child.valueType is String.Type {
                params.append(handleString(name, value: child.value))
            }
            
            else if child.valueType is Bool.Type {
                params.append("\(name)=\(child.value)")
            }
            
            else if child.valueType is Int.Type {
                params.append(handleInt(name, value: child.value))
            }
            
            else if child.valueType is [String].Type {
                if let arr = child.value as? [String] {
                    var vals = arr.map() {"\"\($0)\""}
                    var values = ",".join(vals)
                    params.append("\(name)=[\(values)]")
                }
            }
            
            else {
                // handle optionals
                switch child.disposition {
                case .Optional:
                    var sub = reflect(child.value)
                    
                    if sub.count > 0 && sub[0].0 == "Some" {
                        
                        if sub[0].1.valueType is String.Type {
                            params.append(handleString(name, value: sub[0].1.value))
                        }
                        
                        else if sub[0].1.valueType is Int.Type {
                            params.append(handleInt(name, value: sub[0].1.value))
                        }
                        
                    }
                default:
                    break
                }
                
            }
        }
        
        return "&".join(params)
        
    }
    
    // handle String
    private func handleString(key: String, value: Any) -> String {
        return "\(key)=\"\(value)\""
    }
    
    private func handleInt(key: String, value: Any) -> String {
        return "\(key)=\(value)"
    }
    
}