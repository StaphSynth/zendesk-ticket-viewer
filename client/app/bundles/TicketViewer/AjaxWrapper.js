
export default class Ajax {
}

Ajax.req = function(path, callback) {
  fetch(path)
  .then(response => {
    return response.json();
  })
  .then(data => {
    callback(data);
  })
  .catch(error => {
    console.log(error);
  });
}
