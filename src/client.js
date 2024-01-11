function compiledExps(username, expr, endpoint) {
    var data = new URLSearchParams();
    data.append("user", username);
    data.append("exp", expr);

    fetch(endpoint, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: data
    })
    .then(response => response.json())
    .then(data => {
        // Display server response
        console.log(JSON.stringify(data))
    })
    .catch(error => {
        console.error('Error:', error);
    });
}

function compiledExpListing(endpoint) {

    fetch(endpoint, {
	method: 'GET',
	headers: {
	    'Content-Type': 'application/x-www/form-urlencoded'
	}})
	.then(response => response.json())
	.then(data => {
	    console.log(JSON.stringify(data))
	}).catch(error => {
	    console.error("Error", error)})}

function compiledExpDetail(id, endpoint) {
    var endpoint = endpoint.concat(id.toString())
    fetch(endpoint, {
	method: 'GET',
	headers: {
	    'Content-Type': 'application/x-www/form-urlencoded'
	}})
	.then(response => response.json())
	.then(data => {
	    console.log(JSON.stringify(data))
	}).catch(error => {
	    console.error("Error", error)})}

/*
  == Examples ==
  
compiledExps("koi2", "(if ltrue 2 3)", "http://localhost:4243/scm-compilations")

compiledExpListing("http://localhost:4243/scm-exps")
*/

compiledExpDetail(3, "http://localhost:4243/scm-exp?id=")
