<%@ include file="../common/IncludeTop.jsp"%>

<div id="BackLink">
    <a
        href="${pageContext.request.contextPath}/catalog/viewCategory?categoryId=${fn:escapeXml(product.categoryId)}">Return
        to ${fn:escapeXml(product.categoryId)}</a>
</div>

<div id="Catalog">

    <h2>${actionBean.product.name}</h2>

    <table>
        <tr>
            <th>Item ID</th>
            <th>Product ID</th>
            <th>Description</th>
            <th>List Price</th>
            <th>&nbsp;</th>
        </tr>
        <c:forEach var="item" items="${itemList}">
            <tr>
                <td><a
                    href="${pageContext.request.contextPath}/catalog/viewItem?itemId=${fn:escapeXml(item.itemId)}">
                        ${fn:escapeXml(item.itemId)} </a></td>
                <td>${fn:escapeXml(item.product.productId)}</td>
                <td>${fn:escapeXml(item.attribute1)}${fn:escapeXml(item.attribute2)}
                    ${fn:escapeXml(item.attribute3)} ${fn:escapeXml(item.attribute4)}
                    ${fn:escapeXml(item.attribute5)} ${fn:escapeXml(product.name)}</td>
                <td><fmt:formatNumber
                        value="${fn:escapeXml(item.listPrice)}"
                        pattern="$#,##0.00" /></td>
                <td><a
                    href="${pageContext.request.contextPath}/cart/addItemToCart?workingItemId=${fn:escapeXml(item.itemId)}">
                        Add to Cart</a></td>
            </tr>
        </c:forEach>
    </table>

</div>

<%@ include file="../common/IncludeBottom.jsp"%>





