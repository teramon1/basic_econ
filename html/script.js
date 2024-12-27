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
