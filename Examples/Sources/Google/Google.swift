// Copyright 2017 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import Dispatch
import SwiftyJSON
import OAuth2

class GoogleSession {
  var connection : Connection

  init(tokenProvider: TokenProvider) throws{
    connection = try Connection(provider:tokenProvider)
  }

  func getMe() throws {
    let sem = DispatchSemaphore(value: 0)

    var parameters = ["requestMask.includeField": "person.names,person.photos"]
    var responseData : Data?
    connection.performRequest(
      method:"GET",
      urlString:"https://people.googleapis.com/v1/people/me",
      parameters: &parameters,
      body: nil) {(data, response, error) in
        responseData = data
        sem.signal()
    }
    _ = sem.wait(timeout: DispatchTime.distantFuture)
    if let data = responseData {
      let response = String(data: data, encoding: .utf8)!
      print(response)
    }
  }

  func getPeople() throws {
    let sem = DispatchSemaphore(value: 0)
    var responseData : Data?
    var parameters = ["requestMask.includeField": "person.names,person.photos"]
    connection.performRequest(
      method:"GET",
      urlString:"https://people.googleapis.com/v1/people/me/connections",
      parameters: &parameters,
      body:nil) {(data, response, error) in
        responseData = data
        sem.signal()
    }
    _ = sem.wait(timeout: DispatchTime.distantFuture)
    if let data = responseData {
      let response = String(data: data, encoding: .utf8)!
      print(response)
    }
  }

  func getData() throws {
    let sem = DispatchSemaphore(value: 0)
    var responseData : Data?
    var parameters : [String:String] = [:]
    let postJSON = ["gqlQuery":["queryString":"select *"]]
    let postData = try JSONSerialization.data(withJSONObject:postJSON)
    connection.performRequest(
      method:"POST",
      urlString:"https://datastore.googleapis.com/v1/projects/hello-86:runQuery",
      parameters: &parameters,
      body: postData) {(data, response, error) in
        responseData = data
        sem.signal()
    }
    _ = sem.wait(timeout: DispatchTime.distantFuture)
    if let data = responseData {
      let response = String(data: data, encoding: .utf8)!
      print(response)
    }
    //var request = Google_Datastore_V1_RunQueryRequest()
    //request.projectId = projectID
    //var query = Google_Datastore_V1_GqlQuery()
    //query.queryString = "select *"
    //request.gqlQuery = query
    //print("\(request)")
    //let result = try service.runquery(request)

  }
}
