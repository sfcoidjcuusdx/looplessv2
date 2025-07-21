//
//  NetworkManager.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//


//
//  NetworkManager.swift
//  loopless
//
//  Created by rafiq kutty on 6/29/25.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    let baseURL = "https://community-api-eb8o.onrender.com"

    // MARK: - Fetch Posts
    func fetchPosts(completion: @escaping ([CommunityPost]) -> Void) {
        guard let url = URL(string: "\(baseURL)/posts") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                print("📥 Fetching posts JSON:\n\(String(data: data, encoding: .utf8) ?? "nil")")
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                do {
                    let posts = try decoder.decode([CommunityPost].self, from: data)
                    DispatchQueue.main.async {
                        completion(posts)
                    }
                } catch {
                    print("❌ Decoding posts failed: \(error)")
                    DispatchQueue.main.async {
                        completion([])
                    }
                }
            } else if let error = error {
                print("❌ Network error while fetching posts: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }.resume()
    }

    // MARK: - Create Post
    func createPost(title: String, content: String, username: String, completion: @escaping (CommunityPost?) -> Void) {
        guard let url = URL(string: "\(baseURL)/posts") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "title": title,
            "content": content,
            "username": username
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("❌ Failed to encode POST body: \(error)")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                print("📤 Sent post. Server response:\n\(String(data: data, encoding: .utf8) ?? "nil")")
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                do {
                    let newPost = try decoder.decode(CommunityPost.self, from: data)
                    DispatchQueue.main.async {
                        completion(newPost)
                    }
                } catch {
                    print("❌ Decoding new post failed: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } else if let error = error {
                print("❌ Network error while posting: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
}

