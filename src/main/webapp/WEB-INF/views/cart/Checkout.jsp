<%@ include file="../common/IncludeTop.jsp"%>

<div id="BackLink">
    <a href="${pageContext.request.contextPath}/cart/viewCart">
        Return to Shopping Cart</a>
</div>

<div id="Catalog">
    <table>
        <tr>
            <td>
                <h2>Checkout Summary</h2>

                <table>

                    <tr>
                        <td><b>Item ID</b></td>
                        <td><b>Product ID</b></td>
                        <td><b>Description</b></td>
                        <td><b>In Stock?</b></td>
                        <td><b>Quantity</b></td>
                        <td><b>List Price</b></td>
                        <td><b>Total Cost</b></td>
                    </tr>

                    <c:forEach var="cartItem" items="${cart.cartItems}">
                        <tr>
                            <td><a
                                href="${pageContext.request.contextPath}/catalog/viewItem?itemId=${fn:escapeXml(cartItem.item.itemId)}">
                                    ${fn:escapeXml(cartItem.item.itemId)}</a></td>
                            <td>${fn:escapeXml(cartItem.item.product.productId)}</td>
                            <td>${fn:escapeXml(cartItem.item.attribute1)}
                                ${fn:escapeXml(cartItem.item.attribute2)}
                                ${fn:escapeXml(cartItem.item.attribute3)}
                                ${fn:escapeXml(cartItem.item.attribute4)}
                                ${fn:escapeXml(cartItem.item.attribute5)}
                                ${fn:escapeXml(cartItem.item.product.name)}</td>
                            <td>${fn:escapeXml(cartItem.inStock)}</td>
                            <td>${fn:escapeXml(cartItem.quantity)}</td>
                            <td><fmt:formatNumber
                                    value="${fn:escapeXml(cartItem.item.listPrice)}"
                                    pattern="$#,##0.00" /></td>
                            <td><fmt:formatNumber
                                    value="${fn:escapeXml(cartItem.total)}"
                                    pattern="$#,##0.00" /></td>
                        </tr>
                    </c:forEach>
                    <tr>
                        <td colspan="7">Sub Total: <fmt:formatNumber
                                value="${fn:escapeXml(cart.subTotal)}"
                                pattern="$#,##0.00" /></td>
                    </tr>
                </table>
            <td>&nbsp;</td>

        </tr>
    </table>

</div>

<%@ include file="../common/IncludeBottom.jsp"%>