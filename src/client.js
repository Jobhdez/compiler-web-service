function compiledScmExps() {
    var data = new URLSearchParams();
    data.append("user", "koi2");
    data.append("exp", "(if ltrue 1 2)");

    fetch('http://localhost:4243/scm-compilations', {
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

compiledScmExps();
