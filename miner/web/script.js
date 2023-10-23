

let progressCircle = document.querySelector(".progress");
let radius = progressCircle.r.baseVal.value;
let circumference = radius * 2 * Math.PI;
progressCircle.style.strokeDasharray = circumference;




function toggleUI(showUi, progresnumberS, InWorks, levell) {
    const uiContainer = document.getElementById('uiContainer');
    const work = document.getElementById('workbuttonid');
    const workot = document.getElementById('workbuttonoutid');
    const levels = document.getElementById('leveltextnumberid');
    if (showUi) {
        
        uiContainer.removeAttribute('hidden');
        if (levell !== undefined)
        {
            levels.innerHTML = levell;
        }
        else {
            levels.innerHTML = "0";
        }
        if (progresnumberS !== undefined)
        {
            setProgress(progresnumberS);
        }
        else {
            setProgress(0);
        }
        
    } else {
        uiContainer.setAttribute('hidden', 'true');
    }
    if (InWorks) {
        work.setAttribute('hidden', 'true');
        workot.removeAttribute('hidden');
    } else {
        workot.setAttribute('hidden', 'true');
        work.removeAttribute('hidden');
    }
}




window.addEventListener('message', function (event) {
    if (event.data.showUi !== undefined) {
        toggleUI(event.data.showUi, event.data.progresnumberS, event.data.InWorks, event.data.levell);
    }
});



function setProgress(percent) {
    progressCircle.style.strokeDashoffset = circumference - (percent / -1000) * circumference;
}




$(function () {
    document.onkeyup = function (data) {
        if (data.which == 27) {
            $.post("https://miner/exit", JSON.stringify({
                showUI: false
            }));
            return;
        }
    }
    $("#workbuttonid").click(function (){
        $.post("https://miner/workui", JSON.stringify({}));
        return;
    });   
    $("#workbuttonoutid").click(function (){
        $.post("https://miner/workui", JSON.stringify({}));
        return;
    });    
});

