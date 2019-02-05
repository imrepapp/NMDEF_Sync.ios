public extension URLResponse {
    var isSuccessStatusCode: Bool {
        return (self as! HTTPURLResponse).statusCode >= 200 && (self as! HTTPURLResponse).statusCode < 300
    }
}