protocol DeferredResult: class
{
    var value: Any? { get }
    
    var onSuccess: ((Any?) -> Void)? { get set }
    var onFailure: ((Error) -> Void)? { get set }
}

//===

public
final
class Promise<T>: DeferredResult
{
    public
    init() { }
    
    //===
    
    var value: Any?
    
    //===
    
    var onSuccess: ((Any?) -> Void)?
    var onFailure: ((Error) -> Void)?
}

//===

public
extension Promise
{
    func success(with result: T)
    {
        value = result
        onSuccess?(result)
    }
    
    func failure(with error: Error)
    {
        onFailure?(error)
    }
}
