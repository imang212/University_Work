function PostInformation() {
    const data = {
        name: document.getElementById('name').value,
        author: document.getElementById('author').value,
        description: document.getElementById('description').value,
        secret: "1234",
    };
    fetch('/form', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({data}),
    })
    .then(response => response.json())
    .then(data => getStatus(data.task_id))
    .catch(error => {console.error('Error:', error);});
  }
  
  function getStatus_of_task(taskID) {
    fetch(`/form/${taskID}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      },
    })
    .then(response => response.json())
    .then(res => {
      //const html = `
      //  <tr>
      //    <td>${taskID}</td>
      //    <td>${res.task_status}</td>
      //    <td>${res.task_result}</td>
      //  </tr>`;
      //const newRow = document.getElementById('tasks').insertRow(0);
      //newRow.innerHTML = html;
  
      const taskStatus = res.task_status;
      if (taskStatus === 'SUCCESS'){
        document.getElementById("success").innerText = 'Uložení bylo úspěšné'
        return false;
      }
      if (taskStatus === 'FAILURE') {
        document.getElementById("failed").innerText = 'Chyba při komunikaci s databází'
        return false;
      }
      setTimeout(function() {
        getStatus(res.task_id);
      }, 1000);
    })
    .catch(err => console.log(err));
  }
  