/**
 * Asynchronous AJAX Cart Handler
 * Automatically updates quantities, totals, and navbar badges without refreshing the page.
 */

async function updateCart(productId, action, quantity = 1, event = null) {
    if (event) {
        event.preventDefault();
        event.stopPropagation();
    }

    try {
        const formData = new URLSearchParams();
        formData.append("action", action);
        formData.append("productId", productId);
        formData.append("quantity", quantity);
        formData.append("ajax", "true");

        const response = await fetch("cart", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded",
                "X-Requested-With": "XMLHttpRequest",
                "Accept": "application/json"
            },
            body: formData.toString()
        });

        const data = await response.json();

        if (data.requireLogin) {
            window.location.href = data.redirect || "login.jsp?error=Please login first";
            return;
        }

        if (data.success) {
            // 1. Update Cart Badge Count across navbar
            updateNavbarCartBadge(data.cartCount);

            // 2. Update all button widgets for this product
            updateProductButtonWidgets(productId, data.quantity);
        }
    } catch (err) {
        console.error("Cart AJAX error:", err);
    }
}

async function updateCartItemQuantity(cartItemId, delta, event = null) {
    if (event) {
        event.preventDefault();
        event.stopPropagation();
    }

    const itemRow = document.getElementById("cartItem_" + cartItemId);
    const qtyInput = itemRow ? itemRow.querySelector("input[name='quantity']") : null;
    const currentQty = qtyInput ? parseInt(qtyInput.value) : 1;
    const newQty = currentQty + delta;

    if (newQty <= 0) {
        if (!confirm("Are you sure you want to remove this item from your cart?")) {
            return;
        }
    }

    try {
        const formData = new URLSearchParams();
        formData.append("action", newQty <= 0 ? "remove" : "update");
        formData.append("cartItemId", cartItemId);
        formData.append("quantity", newQty);
        formData.append("ajax", "true");

        const response = await fetch("cart", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded",
                "X-Requested-With": "XMLHttpRequest",
                "Accept": "application/json"
            },
            body: formData.toString()
        });

        const data = await response.json();

        if (data.requireLogin) {
            window.location.href = data.redirect || "login.jsp";
            return;
        }

        if (data.success) {
            // Update Cart Badge
            updateNavbarCartBadge(data.cartCount);

            // Update item row or remove if 0
            if (newQty <= 0) {
                if (itemRow) {
                    itemRow.style.transition = "all 0.3s ease-out";
                    itemRow.style.opacity = "0";
                    itemRow.style.transform = "translateX(20px)";
                    setTimeout(() => {
                        itemRow.remove();
                        if (data.cartCount === 0) {
                            window.location.reload();
                        }
                    }, 300);
                }
            } else {
                if (qtyInput) qtyInput.value = data.quantity;
                const subtotalEl = itemRow.querySelector(".item-subtotal-val");
                if (subtotalEl) subtotalEl.textContent = "₹" + data.itemSubtotal;
            }

            // Update Cart Totals
            const totalEls = document.querySelectorAll(".cart-total-val");
            totalEls.forEach(el => el.textContent = "₹" + data.total);

            const countEls = document.querySelectorAll(".cart-total-count");
            countEls.forEach(el => el.textContent = data.cartCount);
        }
    } catch (err) {
        console.error("Cart item update error:", err);
    }
}

function updateNavbarCartBadge(count) {
    let badges = document.querySelectorAll(".cart-badge");
    const cartNavLinks = document.querySelectorAll("header nav a[href='cart']");

    if (count > 0) {
        if (badges.length === 0) {
            cartNavLinks.forEach(link => {
                const badge = document.createElement("span");
                badge.className = "cart-badge";
                badge.textContent = count;
                link.appendChild(badge);
            });
        } else {
            badges.forEach(b => {
                b.textContent = count;
                b.style.display = "inline-block";
            });
        }
    } else {
        badges.forEach(b => b.remove());
    }
}

function updateProductButtonWidgets(productId, quantity) {
    const containers = document.querySelectorAll("[data-product-widget='" + productId + "']");

    containers.forEach(container => {
        if (quantity > 0) {
            container.innerHTML = `
                <div class="cart-stepper-control">
                    <button type="button" class="stepper-btn" onclick="updateCart(${productId}, 'decrease', 1, event)" title="Decrease">−</button>
                    <span class="stepper-count">${quantity}</span>
                    <button type="button" class="stepper-btn" onclick="updateCart(${productId}, 'add', 1, event)" title="Increase">+</button>
                </div>
            `;
        } else {
            container.innerHTML = `
                <button type="button" class="btn-add-primary" onclick="updateCart(${productId}, 'add', 1, event)">
                    Add
                </button>
            `;
        }
    });
}
