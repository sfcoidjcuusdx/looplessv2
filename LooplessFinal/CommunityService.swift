//
//  CommunityService.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


import Foundation

struct CommunityService {
    static let baseURL = "https://mycommunity-production.up.railway.app"

    // MARK: - Date Formatter
    private static var isoFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }

    // MARK: - Fetch Posts
    static func fetchPosts(completion: @escaping ([CommunityPost]) -> Void) {
        guard let url = URL(string: "\(baseURL)/posts") else {
            print("❌ Invalid URL for fetching posts.")
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Error fetching posts:", error)
                completion([])
                return
            }

            guard let data = data else {
                print("❌ No data received when fetching posts.")
                completion([])
                return
            }

            if let rawString = String(data: data, encoding: .utf8) {
                print("📦 Raw fetched posts JSON:\n\(rawString)")
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(isoFormatter)
                let rawPosts = try decoder.decode([CommunityPost].self, from: data)
                DispatchQueue.main.async {
                    completion(rawPosts)
                }
            } catch {
                print("❌ Decoding error:", error)
                completion([])
            }
        }.resume()
    }

    // MARK: - Create Post
    static func createPost(title: String, content: String, username: String, completion: @escaping (CommunityPost?) -> Void) {
        guard let url = URL(string: "\(baseURL)/posts") else {
            print("❌ Invalid URL for creating post.")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let postPayload: [String: Any] = [
            "title": title,
            "content": content,
            "username": username
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postPayload, options: [])
        } catch {
            print("❌ Encoding error:", error)
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ Error posting message:", error)
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ No data received after posting.")
                completion(nil)
                return
            }

            if let rawString = String(data: data, encoding: .utf8) {
                print("📦 Raw response from post:\n\(rawString)")
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(isoFormatter)
                let newPost = try decoder.decode(CommunityPost.self, from: data)
                DispatchQueue.main.async {
                    completion(newPost)
                }
            } catch {
                print("❌ Decoding response failed:", error)
                completion(nil)
            }
        }.resume()
    }
}

