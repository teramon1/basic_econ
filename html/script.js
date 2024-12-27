window.addEventListener("message", (event) => {
    const data = event.data;

    if (data.action === "updateCash") {
        document.getElementById("cash").innerText = `Cash: $${data.amount.toLocaleString()}`;
    } else if (data.action === "updateBank") {
        document.getElementById("bank").innerText = `Bank: $${data.amount.toLocaleString()}`;
    } else if (data.action === "toggleDisplay") {
        const display = document.getElementById("moneyDisplay");
        display.style.display = display.style.display === "none" ? "block" : "none";
    }
});

document.getElementById("deposit").addEventListener("click", function () {
    const amount = parseInt(document.getElementById("amount").value);
    if (!amount || amount <= 0) {
        alert("Please enter a valid amount.");
        return;
    }
    fetch(`https://${GetParentResourceName()}/depositMoney`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify({ amount }),
    }).then(() => {
        document.getElementById("amount").value = 1;
    });
});

document.getElementById("withdraw").addEventListener("click", function () {
    const amount = parseInt(document.getElementById("amount").value);
    if (!amount || amount <= 0) {
        alert("Please enter a valid amount.");
        return;
    }
    fetch(`https://${GetParentResourceName()}/withdrawMoney`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify({ amount }),
    }).then(() => {
        document.getElementById("amount").value = 1;
    });
});

document.getElementById("close").addEventListener("click", function () {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: "POST",
    });
});

function setControlsVisible(visible) {
    const controls = document.getElementById("bankControls");
    controls.style.display = visible ? "block" : "none";
}

window.addEventListener("message", function (event) {
    if (event.data.action === "showControls") {
        setControlsVisible(true);
    } else if (event.data.action === "hideControls") {
        setControlsVisible(false);
    } else if (event.data.action === "updateCash") {
        document.getElementById("cash").textContent = `Cash: $${event.data.amount}`;
    } else if (event.data.action === "updateBank") {
        document.getElementById("bank").textContent = `Bank: $${event.data.amount}`;
    }
});