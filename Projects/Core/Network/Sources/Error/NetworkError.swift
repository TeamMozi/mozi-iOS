import Foundation

public enum NetworkError: Error, Equatable, Sendable {
    case invalidURL
    case invalidResponse
    case decodingFailed
    case badRequest(message: String?)
    case unauthorized
    case forbidden(message: String?)
    case notFound(message: String?)
    case conflict(message: String?)
    case clientError(statusCode: Int, message: String?)
    case serverError(statusCode: Int, message: String?)
    case transport(message: String)
}
