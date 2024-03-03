let config

$(async () => {
  await $.getJSON('../../config/config.json', function (json) {
      config = json
  });
});


function open({ type }) {
  if (type === "spawn") spawn();
  if (type === "select") charSelect();
  document.body.style.display = "flex";
}

function spawn() {
  document.querySelector("header p").textContent = "Escolha o local que deseja nascer";
  document.querySelector("main").innerHTML = "";
  for(const { id,name, image } of config.locals) {
    document.querySelector("main").innerHTML += createLocals(id, name, image)
  };
}

function charSelect() {
  $.post("http://Q_spawn/generateDisplay", JSON.stringify({}), (data) => {
    document.querySelector("header p").textContent = "Escolha o personagem com qual deseja jogar";
    document.querySelector("main").innerHTML = "";

    var characterList = data["result"].sort((a, b) => (a["id"] > b["id"]) ? 1 : -1);
    for (let i = 0; i < config.maxChars; i++) {
      if (!characterList) {
        document.querySelector("main").innerHTML += createNewChar()
      } else if (characterList[i]) {
        document.querySelector("main").innerHTML += createChar(characterList[i]);
      } else {
        document.querySelector("main").innerHTML += createNewChar();
      }
    }
  })
}

function spawnSelected(id) {
  $.post("http://Q_spawn/spawnChosen", JSON.stringify({id: parseInt(id)}));
}

function optionSelected(id) {
  $.post("http://Q_spawn/characterChosen",JSON.stringify({ id: parseInt(id) }));
}

function createLocals(id,name,image) {
  return `
    <div class="local">
      <div class="image" style="background-image: url('${image}')"></div>
      <div class="description">
        <i class="fa-regular fa-map"></i>
        <div class="name">
          <small>Nascer em</small>
          <span>${name}</span>
        </div>
      </div>
      <button onclick="spawnSelected('${id}')">
        Selecionar
        <i class="fa-duotone fa-wifi"></i>
      </button>
    </div>
  `
}

function createChar(char) { 
  return `
    <div class="person">
      <div class="person-created">
        <img src="./assets/flyer.svg" alt="flyer">
        <h3>${char.name} ${char.firstname}</h3>
        <div class="infos">
          <p>Passaporte</p>
          <p>${char.id}</p>
        </div>
        <div class="infos">
          <p>Nacionalidade</p>
          <p>${char.loc}</p>
        </div>
        <button onclick="optionSelected('${char.id}')">Selecionar <i class="fa-duotone fa-wifi"></i></button>
      </div>
    </div>
  `
}

function createNewChar() {
  return `
    <div class="person">
      <div class="new-person">
        <h4>NOVO <br><span>PERSONAGEM</span></h4>
        <i class="fa-solid fa-user-plus" onclick="checkNewChar()"></i>
        <p>Caso queira adquirir um novo personagem, compre em nossa loja: <span onclick="openStore()">quanticstore.com.br</span></p>
      </div>
    </div>
  `
}

function openStore() {
  window.invokeNative('openUrl', config.url)
}

function checkNewChar() {
  $.post("http://Q_spawn/checkNewCharacter", JSON.stringify({}), (data) => {
    if (data.result){
      newCharModal()
    }
  })
}

function setLocalImages() {
  const localDiv = document.querySelectorAll(".local");
  localDiv[0].querySelector(".image").style.backgroundImage = `url("${config.localImages[0]}")`;
  localDiv[1].querySelector(".image").style.backgroundImage = `url("${config.localImages[1]}")`;
  localDiv[2].querySelector(".image").style.backgroundImage = `url("${config.localImages[2]}")`;
  localDiv[3].querySelector(".image").style.backgroundImage = `url("${config.localImages[3]}")`;
}

function close() {
  document.querySelector("main").innerHTML = "";
  document.body.style.display = 'none';
}

let genre = 'mulher'

function genreSelected(element, name) {
  if (name === 'homem') genre = 'homem';
  if (name === 'mulher') genre = 'mulher';
  document.querySelectorAll('.info button').forEach(button => button.classList.remove('selected'));
  element.classList.add('selected');
}

function start() {
  $.post("http://Q_spawn/newCharacter",JSON.stringify({ 
    name: document.querySelector('#name').value, 
    name2: document.querySelector('#surname').value, 
    sex: genre, 
    idade:Number(document.querySelector('#age').value) 
  }));
  document.querySelector('#name').value = ""  
  document.querySelector('#surname').value = ""   
  document.querySelector('#age').value = "" 
}

function backSelectChar() {
  document.querySelector('#create-char').style.display = 'none';
  document.querySelector('main').style.display = 'flex';
  document.querySelector('header').style.display = 'block';
  charSelect()
  document.querySelector('#name').value = ""  
  document.querySelector('#surname').value = ""   
  document.querySelector('#age').value = "" 
}


function newCharModal() {
  document.querySelector('main').style.display = 'none';
  document.querySelector('header').style.display = 'none';
  document.querySelector('#create-char').style.display = 'flex';
  document.body.style.display = "flex";
}

function somenteNumeros2(e){
	var charCode = e.charCode ? e.charCode : e.keyCode;
    var charkey = String.fromCharCode(e.keyCode)
	if (charCode != 8 && charCode != 9){
        var padrao = '[a-zA-Z]';
		if (charkey.match(padrao)){
			return true;
		}else{
			return false;
		}
	}
}

function somenteNumeros(e){
	var charCode = e.charCode ? e.charCode : e.keyCode;
	if (charCode != 8 && charCode != 9){
		var max = 2;
		var num = $("#age").val();
		if ((charCode < 48 || charCode > 57)||(num.length >= max)){
			return false;
		}
	}
}

window.addEventListener("message", ({ data }) => {
  if (data.action === "open") open(data);
  if (data.action === "close") close();
})