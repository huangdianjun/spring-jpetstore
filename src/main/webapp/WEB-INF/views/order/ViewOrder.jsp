<%@ include file="../common/IncludeTop.jsp"%>

<div id="BackLink">
    <a href="${pageContext.request.contextPath}/catalog"> Return to
        Main Menu</a>
</div>

<div id="Catalog">

    <table>
        <tr>
            <th align="center" colspan="2">Order #${order.orderId}
                <fmt:formatDate value="${order.orderDate}"
                    pattern="yyyy/MM/dd hh:mm:ss" />
            </th>
        </tr>
        <tr>
            <th colspan="2">Payment Details</th>
        </tr>
        <tr>
            <td>Card Type:</td>
            <td>${fn:escapeXml(order.cardType)}</td>
        </tr>
        <tr>
            <td>Card Number:</td>
            <td>${fn:escapeXml(order.creditCard)}*Fakenumber!</td>
        </tr>
        <tr>
            <td>Expiry Date (MM/YYYY):</td>
            <td>${fn:escapeXml(order.expiryDate)}</td>
        </tr>
        <tr>
            <th colspan="2">Billing Address</th>
        </tr>
        <tr>
            <td>First name:</td>
            <td>${fn:escapeXml(order.billToFirstName)}</td>
        </tr>
        <tr>
            <td>Last name:</td>
            <td>${fn:escapeXml(order.billToLastName)}</td>
        </tr>
        <tr>
            <td>Address 1:</td>
            <td>${fn:escapeXml(order.billAddress1)}</td>
        </tr>
        <tr>
            <td>Address 2:</td>
            <td>${fn:escapeXml(order.billAddress2)}</td>
        </tr>
        <tr>
            <td>City:</td>
            <td>${fn:escapeXml(order.billCity)}</td>
        </tr>
        <tr>
            <td>State:</td>
            <td>${fn:escapeXml(order.billState)}</td>
        </tr>
        <tr>
            <td>Zip:</td>
            <td>${fn:escapeXml(order.billZip)}</td>
        </tr>
        <tr>
            <td>Country:</td>
            <td>${fn:escapeXml(order.billCountry)}</td>
        </tr>
        <tr>
            <th colspan="2">Shipping Address</th>
        </tr>
        <tr>
            <td>First name:</td>
            <td>${fn:escapeXml(order.shipToFirstName)}</td>
        </tr>
        <tr>
            <td>Last name:</td>
            <td>${fn:escapeXml(order.shipToLastName)}</td>
        </tr>
        <tr>
            <td>Address 1:</td>
            <td>${fn:escapeXml(order.shipAddress1)}</td>
        </tr>
        <tr>
            <td>Address 2:</td>
            <td>${fn:escapeXml(order.shipAddress2)}</td>
        </tr>
        <tr>
            <td>City:</td>
            <td>${fn:escapeXml(order.shipCity)}</td>
        </tr>
        <tr>
            <td>State:</td>
            <td>${fn:escapeXml(order.shipState)}</td>
        </tr>
        <tr>
            <td>Zip:</td>
            <td>${fn:escapeXml(order.shipZip)}</td>
        </tr>
        <tr>
            <td>Country:</td>
            <td>${fn:escapeXml(order.shipCountry)}</td>
        </tr>
        <tr>
            <td>Courier:</td>
            <td>${fn:escapeXml(order.courier)}</td>
        </tr>
        <tr>
            <td colspan="2">Status: ${fn:escapeXml(order.status)}</td>
        </tr>
        <tr>
            <td colspan="2">
                <table>
                    <tr>
                        <th>Item ID</th>
                        <th>Description</th>
                        <th>Quantity</th>
                        <th>Price</th>
                        <th>Total Cost</th>
                    </tr>
                    <c:forEach var="lineItem" items="${order.lineItems}">
                        <tr>
                            <td><a
                                href="${pageContext.request.contextPath}/catalog/viewItem?itemId=${fn:escapeXml(lineItem.item.itemId)}">
                                    ${fn:escapeXml(lineItem.item.itemId)} </a></td>
                            <td><c:if
                                    test="${lineItem.item != null}">
                        ${fn:escapeXml(lineItem.item.attribute1)}
                        ${fn:escapeXml(lineItem.item.attribute2)}
                        ${fn:escapeXml(lineItem.item.attribute3)}
                        ${fn:escapeXml(lineItem.item.attribute4)}
                        ${fn:escapeXml(lineItem.item.attribute5)}
                        ${fn:escapeXml(lineItem.item.product.name)}
                    </c:if> <c:if test="${lineItem.item == null}">
                                    <i>{description unavailable}</i>
                                </c:if></td>

                            <td>${fn:escapeXml(lineItem.quantity)}</td>
                            <td><fmt:formatNumber
                                    value="${fn:escapeXml(lineItem.unitPrice)}"
                                    pattern="$#,##0.00" /></td>
                            <td><fmt:formatNumber
                                    value="${fn:escapeXml(lineItem.total)}"
                                    pattern="$#,##0.00" /></td>
                        </tr>
                    </c:forEach>
                    <tr>
                        <th colspan="5">Total: <fmt:formatNumber
                                value="${fn:escapeXml(order.totalPrice)}"
                                pattern="$#,##0.00" /></th>
                    </tr>
                </table>
            </td>
        </tr>

    </table>

</div>

<%@ include file="../common/IncludeBottom.jsp"%>
