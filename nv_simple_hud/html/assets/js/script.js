function show_hud() {$("body").fadeIn(300)}
function hide_hud() {$("body").fadeOut(300)}
function show_speedometer(status) {
    if(status){
        $(".weapon_box").addClass("inCar")
        $(".speedometer").fadeIn(300, function(){});
        $(".speedometer .speed-items").animate({ opacity: 1 }, 300);
    }
    else{
        $(".speedometer").fadeOut(300, function(){$(".weapon_box").removeClass("inCar")});
        $(".speedometer .speed-items").animate({ opacity: 0 }, 300);
    }
}

function show_weapon(status){
    if(status){$(".weapon_box").fadeIn(300)}
    else{$(".weapon_box").fadeOut(300)}
}

function health(num){$(".health .fill").attr("style","height:"+num+"%");$(".health p.px").text(num+"%")}
function armour(num){$(".armour .fill").attr("style","height:"+num+"%");$(".armour p.px").text(num+"%")}
function food(num){$(".food .fill").attr("style","height:"+num+"%");$(".food p.px").text(num+"%")}
function water(num){$(".water .fill").attr("style","height:"+num+"%");$(".water p.px").text(num+"%")}

function speed(num) {
    $({ numberValue: $(".speed p").text() }).animate({ numberValue: num }, {
        duration: 200,
        easing: 'swing',
        step: function () {
            $(".speed p").text(Math.ceil(this.numberValue));
        }
    });
}
function engine(num) {$(".engine .fill").attr("style","height:"+num+"%");$(".engine p.px").text(num+"%")}
function fuel(num){$(".fuel .fill").attr("style","height:"+num+"%");$(".fuel p.px").text(num+"%")}

// Nuevo: Actualizar ID del jugador
window.addEventListener('message', (event) => {
    const status = event.data.status
    const data = event.data.data
    if (status == "info"){
        health(data.health.toFixed(0))
        armour(data.armour.toFixed(0))
        food((data.food * 100).toFixed(0))
        water((data.water * 100).toFixed(0))
        
        // Actualizar ID del jugador en la interfaz
        if (data.playerID !== undefined) {
            document.getElementById('playerID').innerText = `ID: ${data.playerID}`;
        }

		if (data.money !== undefined) {
			document.getElementById('moneyDisplay').innerText = `Dinero: $${data.money}`;
		}

		if (data.bank !== undefined) {
			document.getElementById('bankDisplay').innerText = `Banco: $${data.bank}`;
		}

		if (data.job !== undefined) {
			document.getElementById('playerJob').innerText = `Trabajo: ${data.job}`;
		}

		if (data.jobGrade !== undefined) {
			document.getElementById('playerJobGrade').innerText = `Grado: ${data.jobGrade}`;
		}

		if (data.onlinePlayers !== undefined) {
			document.getElementById('playersOnline').innerText = `Online: ${data.onlinePlayers}`;
		}
    }
    if (status == "visible"){
        if (data){show_hud()}
        else{hide_hud()}
    }
    if (status == "speedometer"){
        const visible = data.visible
        if (!visible){
            show_speedometer(false)
            return
        }
        if (visible){
            show_speedometer(true)
        }
        const speed_num = data.speed.toFixed(0)
        const engine_num = data.engine.toFixed(0)
        const fuel_num = data.fuel.toFixed(0)
        if (data.mph){
            $(".speed span").text("mph")
        }
        speed(speed_num)
        engine(engine_num)
        fuel(fuel_num)
    }
    if (status == "weapon"){
        if (!data.visible){
            show_weapon(false)
            return
        }
        if (data.visible){
            show_weapon(true)
        }
        $(".weapon .fill").attr("style","height:"+(data.ammoInClip/data.maxAmmo)*100+"%")
        $(".weapon p.px").text(`${data.ammoInClip}/${data.totalAmmo}`)
    }
})
