const bankUI = document.querySelector(".bank-ui");
const overlay = document.getElementById("overlay");
const closeButton = document.getElementById("close");

function toggleBankUI(show) {
    if (show) {
        bankUI.style.display = "block";
        overlay.style.display = "block";
    } else {
        bankUI.style.display = "none";
        overlay.style.display = "none";
    }
}

document.getElementById("deposit").addEventListener("click", () => {
    const amount = parseInt(document.getElementById("amount").value);
    if (amount > 0) {
        fetch(`https://${GetParentResourceName()}/depositMoney`, {
            method: "POST",
            body: JSON.stringify({ amount: amount }),
        }).catch((err) => console.error("Deposit error:", err));
    } else {
        alert("Enter a valid amount to deposit!");
    }
});

document.getElementById("withdraw").addEventListener("click", () => {
    const amount = parseInt(document.getElementById("amount").value);
    if (amount > 0) {
        fetch(`https://${GetParentResourceName()}/withdrawMoney`, {
            method: "POST",
            body: JSON.stringify({ amount: amount }),
        }).catch((err) => console.error("Withdraw error:", err));
    } else {
        alert("Enter a valid amount to withdraw!");
    }
});

closeButton.addEventListener("click", () => {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: "POST",
        body: JSON.stringify({}),
    });
});

window.addEventListener("message", (event) => {
    if (event.data.action === "updateMoney") {
        document.getElementById("cash").textContent = `$${event.data.cash}`;
        document.getElementById("bank").textContent = `$${event.data.bank}`;
    } else if (event.data.action === "showBankUI") {
        document.querySelector(".bank-ui").style.display = "block";
    } else if (event.data.action === "hideBankUI") {
        document.querySelector(".bank-ui").style.display = "none";
    }
});

window.addEventListener("message", (event) => {
    const data = event.data;

    if (data.action === "updateHUD") {
        document.getElementById("hud-cash").textContent = `$${data.cash.toLocaleString()}`;
        document.getElementById("hud-bank").textContent = `$${data.bank.toLocaleString()}`;
    }
});