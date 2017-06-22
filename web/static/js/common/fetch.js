require('es6-promise').polyfill()
require('isomorphic-fetch')

var ifetch = function(url, method, body){
  if(method == 'GET'){
    return fetch(url, {method: 'GET'})
        .then(function(response) {
            if (response.status >= 400) {
                throw new Error("Bad response from server");
            }
            return response.json()
        })
 }else if(method == 'DELETE'){
   return fetch(url, {method: 'DELETE', body: JSON.stringify(body)})
      .then(function(response) {
          return response.json()
      })
  }else if(method == 'POST'){
    return fetch(url, {method: 'POST', headers: {}, body: body})
        .then(function(response) {
          // if (response.status >= 400) {
          //   throw {message: "Bad response from server", body: response};
          // }
          return response.json()
        })
  }else if(method == 'JSONPOST'){
    return fetch(url, {method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      }, body: JSON.stringify(body)})
      .then(function(response) {
        return response.json()
      })
  }else if(method == 'JSONPATCH'){
    return fetch(url, {method: 'PATCH',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      }, body: JSON.stringify(body)})
      .then(function(response) {
        return response.json()
      })
  }
}


module.exports = ifetch
