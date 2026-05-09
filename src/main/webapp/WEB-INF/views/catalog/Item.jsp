<%@ include file="../common/IncludeTop.jsp"%>

<div id="BackLink">
    <a
        href="${pageContext.request.contextPath}/catalog/viewProduct?productId=${fn:escapeXml(product.productId)}">Return
        to ${fn:escapeXml(product.productId)}</a>
</div>

<div id="Catalog">

    <table>
        <tr>
            <td>${product.description}<%--  XSS Vulnerable! --%></td>
        </tr>
        <tr>
            <td><b> ${fn:escapeXml(item.itemId)} </b></td>
        </tr>
        <tr>
            <td><b><font size="4">
                        ${fn:escapeXml(item.attribute1)} ${fn:escapeXml(item.attribute2)}
                        ${fn:escapeXml(item.attribute3)} ${fn:escapeXml(item.attribute4)}
                        ${fn:escapeXml(item.attribute5)} ${fn:escapeXml(product.name)} </font></b></td>
        </tr>
        <tr>
            <td>${fn:escapeXml(product.name)}</td>
        </tr>
        <tr>
            <td><c:if test="${item.quantity <= 0}">
        Back ordered.
      </c:if> <c:if test="${item.quantity > 0}">
      	${fn:escapeXml(item.quantity)} in stock.
	  </c:if></td>
        </tr>
        <tr>
            <td><fmt:formatNumber value="${fn:escapeXml(item.listPrice)}"
                    pattern="$#,##0.00" /></td>
        </tr>

        <tr>
            <td><a
                href="${pageContext.request.contextPath}/cart/addItemToCart?workingItemId=${fn:escapeXml(item.itemId)}">
                    Add to Cart</a></td>
        </tr>
    </table>

</div>

<%@ include file="../common/IncludeBottom.jsp"%>



